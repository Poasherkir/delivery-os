import 'dart:io';

import 'package:delivery_os/app/startup.dart';
import 'package:delivery_os/core/device/device_id_store.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:delivery_os/data/db/encryption/database_reset.dart';
import 'package:delivery_os/data/db/encryption/encrypted_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A key store backed by a field, standing in for the platform keystore.
final class _MemoryKeyStore implements DatabaseKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async => value = key;

  @override
  Future<void> delete() async => value = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File file;
  late _MemoryKeyStore store;
  late DatabaseKeyProvider keys;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('reset_');
    file = File('${dir.path}/app.db');
    store = _MemoryKeyStore();
    keys = DatabaseKeyProvider(store);
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // A handle may still be open on Windows; the temp directory is disposable.
    }
  });

  /// Runs the real startup sequence against the real encrypted opener.
  Future<StartupResult> launch() async {
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 1, 6, 15));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    return runStartup(
      openExecutor: () => openEncryptedDatabase(file: file, keys: keys),
      deviceIds: DeviceIdStore(await SharedPreferences.getInstance(), uuid),
      clock: clock,
      uuid: uuid,
    );
  }

  Future<int> countUsers(AppDatabase db) async =>
      (await db.customSelect('SELECT count(*) c FROM users').getSingle())
          .read<int>('c');

  group('the happy path ends somewhere usable', () {
    test('delete, regenerate, reopen, and the app works', () async {
      // Not merely "the file is gone". Asserting absence would pass for a reset
      // that destroyed the database and left nothing behind, which is the
      // failure this whole flow exists to avoid.
      final StartupResult first = await launch();
      await first.database.customStatement(
        "UPDATE users SET display_name = 'Malik'",
      );
      final String oldUser = first.user.id;
      final String oldKey = store.value!;
      await first.database.close();

      final String newKey = await DatabaseReset(file: file, keys: keys).run();

      expect(newKey, isNot(oldKey), reason: 'the key must actually rotate');
      expect(store.value, newKey);

      // And the app comes back up on the new key, seeded and writable.
      final StartupResult second = await launch();
      addTearDown(second.database.close);

      expect(await countUsers(second.database), 1);
      expect(
        second.user.id,
        isNot(oldUser),
        reason: 'a reset starts over; the old owner id is gone with its data',
      );
      expect(second.user.displayName, isNull, reason: 'the old row is gone');

      // Usable, not merely open.
      await second.database.customStatement(
        "UPDATE users SET display_name = 'Amine'",
      );
      expect(
        (await second.database
                .customSelect('SELECT display_name FROM users')
                .getSingle())
            .read<String>('display_name'),
        'Amine',
      );
    });

    test('the new database is still encrypted', () async {
      // A reset that silently produced a plaintext database would look like a
      // success and leave a list of Algerian households readable on disk.
      final StartupResult first = await launch();
      await first.database.close();

      await DatabaseReset(file: file, keys: keys).run();

      final StartupResult second = await launch();
      addTearDown(second.database.close);

      expect(looksLikePlaintextSqlite(file), isFalse);
    });

    test('the write-ahead log goes too, when there is one', () async {
      // WAL keeps committed pages outside the main file until a checkpoint, so
      // deleting only app.db would leave recoverable pages of the data the
      // driver just asked to destroy.
      //
      // The first version of this test closed the database cleanly and then
      // asserted the sidecars were absent — which they already were, because a
      // clean close checkpoints and removes them. It was a check against an
      // empty subject set: it would have passed against a `run()` that deleted
      // nothing but app.db.
      //
      // The state that actually matters is an *unclean* shutdown, which is the
      // normal case here: a driver reaching the reset has usually just had the
      // app fail to open. That leaves the sidecars behind, so this creates
      // them and asserts they were there before checking they are gone.
      final StartupResult first = await launch();
      await first.database.customStatement(
        "UPDATE users SET display_name = 'Malik'",
      );
      await first.database.close();

      File('${file.path}-wal').writeAsStringSync('leftover committed pages');
      File('${file.path}-shm').writeAsStringSync('leftover shared index');
      expect(
        File('${file.path}-wal').existsSync(),
        isTrue,
        reason: 'the subject set must be non-empty for this to check anything',
      );

      await DatabaseReset(file: file, keys: keys).run();

      expect(file.existsSync(), isFalse);
      expect(File('${file.path}-wal').existsSync(), isFalse);
      expect(File('${file.path}-shm').existsSync(), isFalse);
    });
  });

  group('an interrupted reset', () {
    test('leaves a fresh install, not the screen he was escaping', () async {
      // The window the forced order creates: the file is gone and the key is
      // not yet replaced. Simulated by doing exactly the first half and then
      // launching, which is what a process death between the two steps looks
      // like from the next launch's point of view.
      //
      // Safe by construction — with no file, obtain(databaseExists: false)
      // returns the key already in the store rather than refusing. But "safe by
      // construction" is the claim, and this is the test rather than the
      // assumption.
      final StartupResult first = await launch();
      final String oldUser = first.user.id;
      await first.database.close();

      // First half only. The key is deliberately left untouched.
      for (final String p in <String>[
        file.path,
        '${file.path}-wal',
        '${file.path}-shm',
      ]) {
        if (File(p).existsSync()) {
          File(p).deleteSync();
        }
      }
      expect(store.value, isNotNull, reason: 'the old key is still there');

      final StartupResult second = await launch();
      addTearDown(second.database.close);

      expect(await countUsers(second.database), 1);
      expect(second.user.id, isNot(oldUser));
    });

    test('and does not throw DatabaseKeyMissingError', () async {
      // The specific failure that would strand him. That error is correct when
      // a database exists with no key; here there is no database, so it must
      // not fire.
      final StartupResult first = await launch();
      await first.database.close();
      file.deleteSync();

      await expectLater(launch(), completes);
    });

    test('completing the reset afterwards still works', () async {
      // The driver retries. The file is already gone, so run() must not trip
      // over its own first half.
      final StartupResult first = await launch();
      await first.database.close();
      file.deleteSync();

      final String key = await DatabaseReset(file: file, keys: keys).run();

      expect(key, hasLength(64));
      expect(store.value, key);
    });
  });

  group('the refusal that protects live data', () {
    test('reset will not regenerate while a database file exists', () async {
      // The second lock on the same door. If the delete silently failed — a
      // permission error, a file still held open — regenerating here would make
      // the surviving database permanently unreadable. It throws instead.
      final StartupResult first = await launch();
      await first.database.close();
      final String liveKey = store.value!;

      await expectLater(
        keys.regenerateForEmptyDatabase(databaseExists: true),
        throwsA(isA<DatabaseKeyGenerationRefusedError>()),
      );

      expect(store.value, liveKey, reason: 'the live key must be untouched');
      expect(file.existsSync(), isTrue);
    });
  });
}

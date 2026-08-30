import 'dart:math';

import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:test/test.dart';

/// A key store that records what was asked of it.
final class _FakeKeyStore implements DatabaseKeyStore {
  _FakeKeyStore([this.value]);

  String? value;
  int writes = 0;
  int deletes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async {
    writes++;
    value = key;
  }

  @override
  Future<void> delete() async {
    deletes++;
    value = null;
  }
}

void main() {
  group('the key that already exists is always returned', () {
    test('whether or not a database is on disk', () async {
      for (final bool exists in <bool>[true, false]) {
        final _FakeKeyStore store = _FakeKeyStore('a' * 64);
        final DatabaseKeyProvider keys = DatabaseKeyProvider(store);

        expect(await keys.obtain(databaseExists: exists), 'a' * 64);
        expect(store.writes, 0, reason: 'nothing should have been written');
      }
    });
  });

  group('first launch', () {
    test('generates and stores a key when there is no database', () async {
      final _FakeKeyStore store = _FakeKeyStore();
      final DatabaseKeyProvider keys = DatabaseKeyProvider(store);

      final String key = await keys.obtain(databaseExists: false);

      expect(key, hasLength(64));
      expect(store.value, key);
      expect(store.writes, 1);
    });

    test('the key is 256 bits of lowercase hex', () async {
      final String key = await DatabaseKeyProvider(
        _FakeKeyStore(),
      ).obtain(databaseExists: false);

      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(DatabaseKeyProvider.keyLengthBytes * 2, key.length);
    });

    test('two keys are not the same key', () async {
      final Set<String> keys = <String>{};
      for (int i = 0; i < 50; i++) {
        keys.add(
          await DatabaseKeyProvider(
            _FakeKeyStore(),
          ).obtain(databaseExists: false),
        );
      }
      expect(keys, hasLength(50));
    });

    test('a seeded Random makes it reproducible, for fixtures only', () async {
      Future<String> run() => DatabaseKeyProvider(
        _FakeKeyStore(),
        random: Random(20260830),
      ).obtain(databaseExists: false);

      expect(await run(), await run());
    });
  });

  group('a database with no key is never re-keyed', () {
    // The rule the whole class exists for. A read-or-create helper that falls
    // through to "create" when the read fails — a keystore hiccup, a transient
    // platform-channel exception — would mint a fresh key and leave the
    // driver's database permanently unreadable, with no way for anyone to know
    // it happened.
    test('obtain throws rather than generating', () async {
      final _FakeKeyStore store = _FakeKeyStore();
      final DatabaseKeyProvider keys = DatabaseKeyProvider(store);

      await expectLater(
        keys.obtain(databaseExists: true),
        throwsA(isA<DatabaseKeyMissingError>()),
      );
    });

    test('and writes nothing on the way out', () async {
      // The assertion that matters more than the throw: a partial write here
      // would replace the real key with a useless one.
      final _FakeKeyStore store = _FakeKeyStore();

      await expectLater(
        DatabaseKeyProvider(store).obtain(databaseExists: true),
        throwsA(isA<DatabaseKeyMissingError>()),
      );

      expect(store.writes, 0);
      expect(store.deletes, 0);
      expect(store.value, isNull);
    });

    test('the error says what is at stake', () async {
      // This message is what a bug report will contain.
      final Object error = await DatabaseKeyProvider(_FakeKeyStore())
          .obtain(databaseExists: true)
          .then<Object>((_) => 'no error', onError: (Object e) => e);

      expect(error, isA<DatabaseKeyMissingError>());
      expect(error.toString(), contains('permanently unreadable'));
    });
  });

  group('deliberate regeneration', () {
    test('refuses while a database file exists', () async {
      // Even on the explicit path. A user-confirmed reset deletes the file
      // first; if the file is still there, the confirmation has not been acted
      // on and generating now would strand it.
      final _FakeKeyStore store = _FakeKeyStore();

      await expectLater(
        DatabaseKeyProvider(
          store,
        ).regenerateForEmptyDatabase(databaseExists: true),
        throwsA(isA<DatabaseKeyGenerationRefusedError>()),
      );
      expect(store.writes, 0);
    });

    test('proceeds once the file is gone', () async {
      final _FakeKeyStore store = _FakeKeyStore('old' * 21 + 'a');
      final String fresh = await DatabaseKeyProvider(
        store,
      ).regenerateForEmptyDatabase(databaseExists: false);

      expect(fresh, hasLength(64));
      expect(store.value, fresh);
    });
  });
}

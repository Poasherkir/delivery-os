import 'dart:io';

import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:delivery_os/data/db/encryption/encrypted_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:test/test.dart';

/// A key store backed by a plain field, standing in for the platform keystore.
///
/// The keystore itself is a plugin and cannot run here. Everything else —
/// whether the file is really encrypted, whether a wrong key is rejected,
/// whether an existing database is ever re-keyed — is testable on the host,
/// because `package:sqlite3` bundles the SQLCipher build on every platform.
final class _MemoryKeyStore implements DatabaseKeyStore {
  _MemoryKeyStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async => value = key;

  @override
  Future<void> delete() async => value = null;
}

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('delivery_os_crypt_');
    file = File('${dir.path}/app.db');
  });

  tearDown(() => dir.delete(recursive: true));

  Future<AppDatabase> open(DatabaseKeyStore store) async {
    final AppDatabase db = AppDatabase(
      await openEncryptedDatabase(file: file, keys: DatabaseKeyProvider(store)),
    );
    // drift is lazy; force the connection and the setup callback.
    await db.customSelect('SELECT 1').get();
    return db;
  }

  Future<void> seed(AppDatabase db) => db.customStatement(
    'INSERT INTO users (id, display_name, locale, created_at, updated_at) '
    "VALUES ('u1', 'Malik', 'ar', 0, 0)",
  );

  test('an encrypted file has no SQLite header', () async {
    // The whole point. A leaked database is a list of Algerian households,
    // their addresses, and when they receive valuable cash-on-delivery
    // parcels (§13).
    final _MemoryKeyStore store = _MemoryKeyStore();
    final AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    expect(file.existsSync(), isTrue);
    expect(
      looksLikePlaintextSqlite(file),
      isFalse,
      reason: 'the database was written unencrypted',
    );
  });

  test('the right key reads the data back', () async {
    final _MemoryKeyStore store = _MemoryKeyStore();
    AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    // A new process would do exactly this: same stored key, same file.
    db = await open(store);
    final QueryRow row = await db
        .customSelect('SELECT display_name FROM users')
        .getSingle();

    expect(row.read<String>('display_name'), 'Malik');
    await db.close();
  });

  test('a wrong key fails instead of returning an empty database', () async {
    // The failure that must never look like success. If a wrong key produced
    // an empty-but-working database, the app would show a driver zero orders
    // and zero money and give no hint that anything was wrong.
    final _MemoryKeyStore store = _MemoryKeyStore();
    final AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    final _MemoryKeyStore wrong = _MemoryKeyStore('b' * 64);
    expect(() => open(wrong), throwsA(isA<DatabaseUnreadableException>()));
  });

  test('no key at all fails the same way', () async {
    final _MemoryKeyStore store = _MemoryKeyStore();
    final AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    // A key that is well-formed but simply never wrote this file.
    final _MemoryKeyStore other = _MemoryKeyStore(
      DatabaseKeyProvider.generateKey(),
    );
    expect(() => open(other), throwsA(isA<DatabaseUnreadableException>()));
  });

  test('the failure names the file and keeps the underlying error', () async {
    final _MemoryKeyStore store = _MemoryKeyStore();
    final AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    try {
      await open(_MemoryKeyStore('c' * 64));
      fail('expected DatabaseUnreadableException');
    } on DatabaseUnreadableException catch (e) {
      expect(e.path, file.path);
      expect(e.toString(), contains('could not be decrypted'));
      expect(e.cause, isNotNull);
    }
  });

  test('an existing database with a lost key is never re-keyed', () async {
    // The scenario the whole design is arranged around: the file survives, the
    // keystore entry does not. Opening must fail loudly with the file intact,
    // not mint a fresh key and leave a driver's history unreadable forever.
    final _MemoryKeyStore store = _MemoryKeyStore();
    final AppDatabase db = await open(store);
    await seed(db);
    await db.close();

    final int sizeBefore = file.lengthSync();
    final _MemoryKeyStore emptied = _MemoryKeyStore();

    await expectLater(
      openEncryptedDatabase(file: file, keys: DatabaseKeyProvider(emptied)),
      throwsA(isA<DatabaseKeyMissingError>()),
    );

    // Nothing was generated, and nothing touched the file.
    expect(emptied.value, isNull);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), sizeBefore);
  });

  test('the key survives a restart, and so does the data', () async {
    // Standing in for a process restart: the store persists, everything else
    // is rebuilt.
    final _MemoryKeyStore store = _MemoryKeyStore();

    AppDatabase db = await open(store);
    await seed(db);
    await db.close();
    final String? afterFirst = store.value;

    for (int restart = 0; restart < 3; restart++) {
      db = await open(store);
      expect(
        (await db.customSelect('SELECT count(*) c FROM users').getSingle())
            .read<int>('c'),
        1,
      );
      await db.close();
    }

    expect(store.value, afterFirst, reason: 'the key was rotated silently');
  });

  test('the schema is created inside the encrypted file', () async {
    final AppDatabase db = await open(_MemoryKeyStore());
    final List<QueryRow> tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();

    // The twenty declared tables, plus customers_fts and the five shadow
    // tables SQLite creates for it. Asserted as "at least the twenty" rather
    // than an exact count: what belongs in the database is
    // schema_entities_test's job, and duplicating the number here would mean
    // two places to edit and one of them going stale.
    expect(tables.length, greaterThanOrEqualTo(20));
    expect(
      tables.map((QueryRow r) => r.read<String>('name')),
      containsAll(<String>['users', 'customers', 'orders', 'customers_fts']),
    );
    await db.close();
  });
}

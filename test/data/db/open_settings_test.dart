import 'dart:io';

import 'package:delivery_os/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Asserts the connection settings **from an opened database**, never from the
/// call site that sets them.
///
/// Every one of these is per-connection and a no-op in the wrong place —
/// `PRAGMA foreign_keys` is silently ignored inside a transaction, and
/// `journal_mode` cannot change on an in-memory database. They are the kind of
/// setup that survives a refactor in name only, so the test opens a real file
/// and asks SQLite what it actually did.
void main() {
  late Directory dir;
  late AppDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('delivery_os_open_');
    db = AppDatabase(NativeDatabase(File('${dir.path}/app.db')));
    // Force the connection open; drift is lazy.
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<Object?> pragma(String name) async {
    final QueryRow row = await db.customSelect('PRAGMA $name').getSingle();
    return row.data.values.first;
  }

  test('foreign keys are enforced', () async {
    // Without this, every REFERENCES clause in the schema is decoration.
    expect(await pragma('foreign_keys'), 1);
  });

  test('the journal is WAL', () async {
    // The phone is dropped, run flat, and killed by an OEM task manager.
    expect(await pragma('journal_mode'), 'wal');
  });

  test('synchronous is FULL, not NORMAL', () async {
    // 2 is FULL, 1 is NORMAL. With WAL and NORMAL, a power loss can lose the
    // last committed transaction — here, a delivery and the cash collected
    // with it. Deliberately the slower setting.
    expect(await pragma('synchronous'), 2);
  });

  test('a foreign key violation actually throws', () async {
    // The end-to-end proof. The pragma reading 1 is necessary but not
    // sufficient: this is what it buys.
    expect(
      () => db.customStatement(
        'INSERT INTO companies '
        '(id, owner_id, name, is_active, created_at, updated_at, version) '
        "VALUES ('a', 'nobody', 'Ghost', 1, 0, 0, 1)",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the settings survive a reopen', () async {
    // beforeOpen runs per connection. A second open must configure itself the
    // same way, or the guarantees hold only for the first session after
    // install.
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/app.db')));
    await db.customSelect('SELECT 1').get();

    expect(await pragma('foreign_keys'), 1);
    expect(await pragma('journal_mode'), 'wal');
    expect(await pragma('synchronous'), 2);
  });

  group('the schema is created whole', () {
    test('all twenty tables exist', () async {
      final List<QueryRow> tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%'",
          )
          .get();

      expect(
        tables.map((QueryRow r) => r.read<String>('name')).toSet(),
        <String>{
          'users',
          'companies',
          'payment_rules',
          'wilayas',
          'communes',
          'customers',
          'customer_addresses',
          'batches',
          'orders',
          'delivery_attempts',
          'proof_of_delivery',
          'routes',
          'route_stops',
          'matrix_cache',
          'expenses',
          'daily_settlements',
          'settlement_adjustments',
          'remittances',
          'outbox',
          'audit_logs',
        },
      );
    });

    test('every §6.3 index that SQLite can express is present', () async {
      final Set<String> indexes =
          (await db
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'index' "
                    "AND name LIKE 'idx_%'",
                  )
                  .get())
              .map((QueryRow r) => r.read<String>('name'))
              .toSet();

      expect(indexes, <String>{
        'idx_orders_owner_status',
        'idx_orders_batch',
        'idx_orders_tracking',
        'idx_batches_owner_date',
        'idx_customers_owner_phone',
        'idx_addr_commune',
        'idx_expenses_owner_date',
        'idx_settlements_owner_date',
        'idx_remit_owner_company',
        'idx_outbox_pending',
      });
    });

    test('the partial indexes kept their WHERE clause', () async {
      // Partial indexes carry over from Postgres to SQLite unchanged, and the
      // WHERE clause is the whole point: an index over every soft-deleted row
      // ever is not the index §6.3 asked for.
      final Map<String, String> sql = <String, String>{
        for (final QueryRow r
            in await db
                .customSelect(
                  "SELECT name, sql FROM sqlite_master WHERE type = 'index' "
                  'AND sql IS NOT NULL',
                )
                .get())
          r.read<String>('name'): r.read<String>('sql'),
      };

      expect(
        sql['idx_orders_owner_status'],
        contains('WHERE deleted_at IS NULL'),
      );
      expect(sql['idx_orders_batch'], contains('WHERE deleted_at IS NULL'));
      expect(
        sql['idx_customers_owner_phone'],
        contains('WHERE deleted_at IS NULL'),
      );
      expect(sql['idx_outbox_pending'], contains('WHERE synced_at IS NULL'));
    });

    test('the customer phone index is unique', () async {
      final String sql =
          (await db
                  .customSelect(
                    'SELECT sql FROM sqlite_master WHERE name = '
                    "'idx_customers_owner_phone'",
                  )
                  .getSingle())
              .read<String>('sql');

      expect(sql, contains('UNIQUE'));
    });
  });

  test('a soft-deleted customer no longer blocks the same number', () async {
    // What the partial unique index buys over a table constraint. A driver
    // re-adding a number they deleted must not be refused by a row they cannot
    // see.
    Future<void> insertCustomer(String id, {bool deleted = false}) =>
        db.customStatement(
          'INSERT INTO customers (id, owner_id, phone_e164, display_name, '
          'risk_flag, total_orders, total_delivered, total_failed, '
          'created_at, updated_at, deleted_at, version) '
          "VALUES ('$id', 'owner', '+213550123456', 'Amine', 'none', "
          '0, 0, 0, 0, 0, ${deleted ? 1 : 'NULL'}, 1)',
        );

    await db.customStatement('PRAGMA foreign_keys = OFF');

    await insertCustomer('c1', deleted: true);
    // A second live row is fine, because the first is deleted.
    await insertCustomer('c2');
    // A third live one is not.
    expect(() => insertCustomer('c3'), throwsA(isA<SqliteException>()));
  });
}

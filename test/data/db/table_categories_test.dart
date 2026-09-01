import 'package:delivery_os/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Invariant 3, over every table, read from the live column list.
///
/// This existed once as a throwaway script during the M0 gate. It ran, printed
/// `CATEGORY VIOLATIONS: none`, and was deleted — so the audit that proved the
/// categories hold left nothing behind, and every table written afterwards was
/// unguarded. An audit that proves something and leaves nothing behind is a
/// measurement, not a guard.
///
/// Which columns a table carries is decided by its category, and the category
/// is a design decision made *before* the table is written. The point of
/// checking all twenty rather than a sample is that the failure this catches is
/// a new table quietly acquiring the wrong shape — which by definition happens
/// to the table nobody thought to add to a sample.
///
/// A new table fails the `every table is categorised` test until it is listed
/// here. That is deliberate: adding a line to one of these lists is the moment
/// the category decision gets made, and it is visible in the diff.

/// All five audit columns, soft delete, version bumped on every write.
const List<String> _ownedMutable = <String>[
  'companies',
  'customers',
  'customer_addresses',
  'batches',
  'orders',
  'expenses',
  'remittances',
  'routes',
];

/// `owner_id` + `created_at` only. Never updated, so `updated_at` and `version`
/// would be lies and a soft delete would be a rewrite of history.
const List<String> _appendOnly = <String>[
  'payment_rules',
  'delivery_attempts',
  'proof_of_delivery',
  'daily_settlements',
  'settlement_adjustments',
  'audit_logs',
];

/// Ships inside the APK. Not user data, never syncs.
const List<String> _bundledReference = <String>['wilayas', 'communes'];

/// Droppable at any moment with zero data loss. Not even `owner_id`.
const List<String> _pureCache = <String>['matrix_cache'];

/// Mutates, never syncs, hard deletion allowed.
const List<String> _localMachinery = <String>['outbox'];

/// The two deliberate exceptions.
const List<String> _exceptions = <String>['route_stops', 'users'];

const List<String> _allAuditColumns = <String>[
  'owner_id',
  'created_at',
  'updated_at',
  'deleted_at',
  'version',
];

void main() {
  late AppDatabase db;
  late Map<String, Set<String>> columns;

  setUpAll(() {
    db = AppDatabase(NativeDatabase.memory());
    columns = <String, Set<String>>{
      for (final TableInfo<Table, Object?> t in db.allTables)
        t.actualTableName: t.$columns
            .map((GeneratedColumn<Object?> c) => c.name)
            .toSet(),
    };
  });

  tearDownAll(() => db.close());

  void mustHave(String table, List<String> required) {
    for (final String column in required) {
      expect(
        columns[table],
        contains(column),
        reason: '$table is missing $column',
      );
    }
  }

  void mustNotHave(String table, List<String> forbidden) {
    for (final String column in forbidden) {
      expect(
        columns[table],
        isNot(contains(column)),
        reason: '$table carries $column, which its category forbids',
      );
    }
  }

  test('every table is categorised', () {
    // The test that makes the rest of the file self-maintaining. A table added
    // without a category decision fails here rather than silently escaping
    // every check below.
    final Set<String> categorised = <String>{
      ..._ownedMutable,
      ..._appendOnly,
      ..._bundledReference,
      ..._pureCache,
      ..._localMachinery,
      ..._exceptions,
    };

    expect(
      columns.keys.toSet().difference(categorised),
      isEmpty,
      reason:
          'these tables have no category. Decide which of the five they are '
          'and add them to the list — that decision is what determines their '
          'columns, and making it here puts it in the diff.',
    );
    expect(
      categorised.difference(columns.keys.toSet()),
      isEmpty,
      reason: 'these categorised tables no longer exist',
    );
  });

  group('owned mutable entities carry all five', () {
    for (final String table in _ownedMutable) {
      test(table, () => mustHave(table, _allAuditColumns));
    }
  });

  group('append-only records carry two, and only two', () {
    for (final String table in _appendOnly) {
      test(table, () {
        mustHave(table, <String>['owner_id', 'created_at']);
        // The absences are the invariant. A row that can be updated breaks
        // every settlement computed from it.
        mustNotHave(table, <String>['updated_at', 'deleted_at', 'version']);
      });
    }
  });

  group('bundled reference data carries no audit columns at all', () {
    for (final String table in _bundledReference) {
      test(table, () => mustNotHave(table, _allAuditColumns));
    }
  });

  group('the pure cache carries nothing, not even an owner', () {
    for (final String table in _pureCache) {
      test(table, () => mustNotHave(table, _allAuditColumns));
    }
  });

  group('local machinery', () {
    for (final String table in _localMachinery) {
      test(table, () {
        mustHave(table, <String>['created_at']);
        // Not an owned entity: it never syncs, and tombstoning a queue row
        // means nothing.
        mustNotHave(table, <String>['owner_id', 'version', 'deleted_at']);
      });
    }
  });

  group('the two deliberate exceptions', () {
    test('route_stops has timestamps but no version and no soft delete', () {
      // Stops mutate, but they are owned by their route and re-optimization
      // replaces them wholesale. `status` was deliberately removed: every value
      // is derivable, and two copies of one fact drift apart.
      mustHave('route_stops', <String>['created_at', 'updated_at']);
      mustNotHave('route_stops', <String>[
        'owner_id',
        'version',
        'deleted_at',
        'status',
      ]);
    });

    test('users has timestamps but is not owned and has no version', () {
      // It *is* the owner, and an account-less MVP has exactly one.
      mustHave('users', <String>['created_at', 'updated_at', 'deleted_at']);
      mustNotHave('users', <String>['owner_id', 'version']);
    });
  });

  test('every owner_id is a foreign key to users, read from the DDL', () {
    // The FK cannot live on the mixin — drift will not resolve a `references`
    // written there — so each table overrides ownerId. Reading it back out of
    // sqlite_master is what stops that override from being something a table
    // has to remember.
    return db
        .customSelect("SELECT name, sql FROM sqlite_master WHERE type='table'")
        .get()
        .then((List<QueryRow> rows) {
          final List<String> missing = <String>[
            for (final QueryRow row in rows)
              if (row.read<String>('sql').contains('owner_id') &&
                  !row.read<String>('sql').contains('REFERENCES users'))
                row.read<String>('name'),
          ];
          expect(
            missing,
            isEmpty,
            reason:
                'owner_id with no foreign key to users: ${missing.join(', ')}',
          );
        });
  });
}

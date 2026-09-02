import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/customer_search_index.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Everything SQLite actually holds, against an allowlist.
///
/// **Replaces `validateDropped: true` on the migration harness, and is stronger
/// than it was.** That flag could only say "the live database has something the
/// dump does not", and it stopped being usable when the FTS5 index arrived:
/// drift 2.34 cannot model a virtual table, so the index, its three triggers
/// and SQLite's five shadow tables are all invisible to `schema dump`. Relaxing
/// the flag and leaving it there would have quietly removed the protection.
///
/// This checks both directions and names what moved. Almost all of it is
/// *derived* from drift's own entity list rather than typed out, so adding a
/// table does not mean editing this file — only an entity drift cannot see
/// needs a deliberate line, which is exactly the set worth reviewing.
void main() {
  late AppDatabase db;

  setUpAll(() => db = AppDatabase(NativeDatabase.memory()));
  tearDownAll(() => db.close());

  /// The bookkeeping tables SQLite creates for an FTS5 index. Not ours, not
  /// optional, and not visible to drift.
  Set<String> shadowTablesFor(String fts) => <String>{
    '${fts}_data',
    '${fts}_idx',
    '${fts}_content',
    '${fts}_docsize',
    '${fts}_config',
  };

  Future<Set<String>> liveEntities() async {
    final List<QueryRow> rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%'",
        )
        .get();
    return <String>{for (final QueryRow row in rows) row.read<String>('name')};
  }

  test('the database holds exactly what it is supposed to', () async {
    final Set<String> expected = <String>{
      // Everything drift declares: tables, indexes, triggers. Derived, so a
      // new table needs no edit here.
      for (final DatabaseSchemaEntity e in db.allSchemaEntities) e.entityName,

      // The entities drift cannot model. Each is a deliberate line, and the
      // reason is in customer_search_index.dart.
      ...customerSearchEntities,
      ...shadowTablesFor('customers_fts'),
    };

    final Set<String> live = await liveEntities();

    expect(
      live,
      isNotEmpty,
      reason: 'sqlite_master came back empty, so this checked nothing',
    );
    expect(
      live.difference(expected),
      isEmpty,
      reason:
          'the database contains entities nothing declares. If they are '
          'deliberate, add them to the allowlist with a reason.',
    );
    expect(
      expected.difference(live),
      isEmpty,
      reason:
          'declared entities are missing from the database. A migration that '
          'stopped creating one would look like a success everywhere else.',
    );
  });

  test('the search index and its triggers are all present', () async {
    // Named separately from the set comparison so losing the index reports as
    // "search is gone" rather than as one line in a diff of forty names.
    final Set<String> live = await liveEntities();

    for (final String entity in customerSearchEntities) {
      expect(
        live,
        contains(entity),
        reason:
            '$entity is missing; customer search would silently return '
            'nothing rather than fail',
      );
    }
  });

  test('the index is a trigram fts5 table, not a default one', () async {
    // The tokenizer is the whole reason this index exists. A default fts5
    // table would still answer queries — it would just stop matching a
    // substring of a phone number, which is the case it was built for, and
    // nothing else would notice.
    final QueryRow row = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name = 'customers_fts'",
        )
        .getSingle();
    final String sql = row.read<String>('sql').toLowerCase();

    expect(sql, contains('using fts5'));
    expect(sql, contains('trigram'));
  });
}

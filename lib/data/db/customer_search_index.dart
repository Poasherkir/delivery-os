/// The FTS5 index over customers, as raw SQL.
///
/// **Raw SQL because drift 2.34 will not model it.** A `CREATE VIRTUAL TABLE`
/// in an included `.drift` file is parsed — the triggers beside it generate
/// fine — but no table is emitted, and the triggers then land in
/// `allSchemaEntities` ahead of `customers`, so `createAll` builds a trigger on
/// a table that does not exist yet. Verified by trying it, including with the
/// tokenizer option removed to rule that out.
///
/// The consequence is that these entities are invisible to
/// `drift_dev schema dump`, so the migration harness cannot compare them
/// against a reference. `schema_entities_test` covers that gap with an explicit
/// allowlist of everything in `sqlite_master`, which is a stronger check than
/// the `validateDropped` flag it replaces: it catches extra *and* missing
/// entities, and names them.
library;

/// **Trigram, not the default tokenizer.**
///
/// The default splits on non-alphanumeric boundaries and matches whole tokens
/// or prefixes, so `+213550111111` is one token and searching `550111` finds
/// nothing — a prefix query `550111*` matches only tokens that *start* that
/// way. A driver reads the last digits off a parcel far more often than the
/// first, so infix matching is the requirement, and trigram is the only
/// tokenizer that provides it. Needs SQLite 3.34+; SQLCipher 4.18 is 3.53.
///
/// Standalone rather than `content=customers`: external-content mode requires
/// the indexed columns to exist on the content table, and the searchable phone
/// here is a coalesce of two columns that never both hold a value.
const String createCustomerSearchIndex =
    'CREATE VIRTUAL TABLE IF NOT EXISTS customers_fts USING fts5('
    'customer_id UNINDEXED, '
    'display_name, '
    'phone, '
    "tokenize = 'trigram case_sensitive 0')";

/// Kept current by triggers rather than by the DAO, so a write that bypasses
/// `CustomerDao` cannot leave the index and the table out of step. The outbox
/// has its own guard for the same reason: neither should rely on a future
/// method remembering.
///
/// `phone` merges `phone_e164` and `phone_raw` deliberately — the customer a
/// driver hunts for by typing digits off a parcel is often precisely the one
/// whose number never parsed.
const List<String> createCustomerSearchTriggers = <String>[
  'CREATE TRIGGER IF NOT EXISTS customers_fts_insert '
      'AFTER INSERT ON customers BEGIN '
      'INSERT INTO customers_fts (customer_id, display_name, phone) '
      "VALUES (new.id, new.display_name, coalesce(new.phone_e164, new.phone_raw, '')); "
      'END',

  // Delete-then-insert: an FTS5 row is not updated in place, and a soft delete
  // arrives here as an ordinary UPDATE, so this path runs far more often than
  // the DELETE trigger does.
  'CREATE TRIGGER IF NOT EXISTS customers_fts_update '
      'AFTER UPDATE ON customers BEGIN '
      'DELETE FROM customers_fts WHERE customer_id = old.id; '
      'INSERT INTO customers_fts (customer_id, display_name, phone) '
      "VALUES (new.id, new.display_name, coalesce(new.phone_e164, new.phone_raw, '')); "
      'END',

  // Nothing hard-deletes a customer today. This exists so the index cannot
  // outlive its rows if something ever does.
  'CREATE TRIGGER IF NOT EXISTS customers_fts_delete '
      'AFTER DELETE ON customers BEGIN '
      'DELETE FROM customers_fts WHERE customer_id = old.id; '
      'END',
];

/// Fills the index from rows that already exist.
///
/// Only meaningful in the v2 → v3 migration: on a fresh database the triggers
/// are in place before the first customer is written, so there is nothing to
/// backfill and this inserts zero rows.
const String backfillCustomerSearchIndex =
    'INSERT INTO customers_fts (customer_id, display_name, phone) '
    "SELECT id, display_name, coalesce(phone_e164, phone_raw, '') "
    'FROM customers';

/// Every entity this file creates, for the schema allowlist.
const List<String> customerSearchEntities = <String>[
  'customers_fts',
  'customers_fts_insert',
  'customers_fts_update',
  'customers_fts_delete',
];

import 'package:drift/drift.dart';

import 'converters.dart';

/// A UUIDv7 text primary key.
///
/// Invariant 2. Client-generated, because offline creation cannot wait for a
/// server to assign an id and two devices would both mint `41`. Stored as
/// TEXT: SQLite has no UUID type, and the canonical 36-character form sorts
/// lexicographically in the same order as it sorts chronologically, so
/// `ORDER BY id` is a valid tiebreak.
mixin UuidPrimaryKey on Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The five audit columns every **owned mutable entity** carries.
///
/// Invariant 3, first category: `companies`, `customers`, `customer_addresses`,
/// `batches`, `orders`, `expenses`, `remittances`, `routes`. Deletes are soft
/// and [version] increments on every write.
///
/// Dormant in the MVP — nothing reads [version] or [deletedAt] yet. They are
/// here because adding them later means a migration across a driver's live
/// money data, and because sync at V2 is impossible without them.
///
/// The stamping is not left to each DAO to remember: see `EntityStamper`.
mixin OwnedMutableColumns on Table {
  /// The driver. Becomes the RLS predicate at V2 (§14).
  TextColumn get ownerId => text().withLength(min: 36, max: 36)();

  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();

  IntColumn get updatedAt => integer().map(const UtcMillisecondsConverter())();

  /// Soft delete. Null means live.
  IntColumn get deletedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  /// Incremented on every write. Starts at 1.
  IntColumn get version => integer()();
}

/// The two columns an **append-only record** carries.
///
/// Invariant 3, second category: `payment_rules`, `delivery_attempts`,
/// `proof_of_delivery`, `daily_settlements`, `settlement_adjustments`,
/// `audit_logs`, `outbox`.
///
/// Deliberately no `updated_at`, no `version`, no soft delete. These rows are
/// never updated, so an `updated_at` would be a lie and a soft delete would be
/// a rewrite of history — which is exactly what invariant 7 forbids for
/// settlements.
mixin AppendOnlyColumns on Table {
  TextColumn get ownerId => text().withLength(min: 36, max: 36)();

  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();
}

/// The two columns `route_stops` carries, and no others.
///
/// Invariant 3's first deliberate exception. Stops mutate — `arrived_at`,
/// `status` — but they are owned by their route rather than by the driver
/// directly, and re-optimization replaces a route's stops wholesale rather
/// than editing them. So there is no `version` to increment against and no
/// soft delete to perform: a stop that is gone is gone with its route.
mixin RouteStopColumns on Table {
  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();

  IntColumn get updatedAt => integer().map(const UtcMillisecondsConverter())();
}

/// The three columns `users` carries.
///
/// Invariant 3's second deliberate exception: no `owner_id`, because this row
/// *is* the owner, and no `version`, because in an account-less MVP there is
/// exactly one of them and nothing to reconcile.
mixin UserColumns on Table {
  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();

  IntColumn get updatedAt => integer().map(const UtcMillisecondsConverter())();

  IntColumn get deletedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();
}

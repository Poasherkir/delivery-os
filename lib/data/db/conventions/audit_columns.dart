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

import 'package:drift/drift.dart';

import 'converters.dart';

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
  ///
  /// Each owned table overrides this to add the foreign key to `users`;
  /// drift cannot resolve a `references` written inside a mixin. A guard
  /// test reads the generated schema and fails on an owned table whose
  /// owner_id carries no foreign key, so the override is not remembered.
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
  /// See [OwnedMutableColumns.ownerId].
  TextColumn get ownerId => text().withLength(min: 36, max: 36)();

  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();
}

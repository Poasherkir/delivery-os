import 'package:drift/drift.dart';

import '../../../domain/value_objects/ledger_enums.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/owner_columns.dart';
import 'users.dart';

/// The queue of local writes that will one day be sent to a server.
///
/// **Nothing sends it. It is written anyway** (invariant 5). Every mutation
/// writes a row here inside the same transaction as the entity write, from the
/// first commit of the MVP. That costs almost nothing now and saves a
/// whole-app refactor at V2, when the alternative is retrofitting an outbox
/// through every repository that already exists.
///
/// **Local machinery** — invariant 3's fifth category. It mutates ([attempts],
/// [lastError], [syncedAt] are all written during a sync pass) so it is not
/// append-only; it never syncs and has no `version` so it is not an owned
/// entity; and a synced row is **hard-deleted or trimmed by age**, because
/// tombstoning a queue row means nothing.
///
/// [id] doubles as the idempotency key (§7.1). A command replayed after a
/// connection drops must not be applied twice, and the row's own id is what the
/// server dedupes on.
class Outbox extends Table with UuidPrimaryKey {
  TextColumn get entityType => text().withLength(min: 1, max: 60)();

  TextColumn get entityId => text().withLength(min: 36, max: 36)();

  /// **Commands, not state diffs** (§11.2). `order.deliver { collected, at }`
  /// replays correctly whatever else changed; `{ status: 'delivered' }` does
  /// not, because it silently overwrites what another device did.
  TextColumn get operation => text().map(
    const EnumTextConverter<OutboxOperation>(
      OutboxOperation.values,
      'OutboxOperation',
    ),
  )();

  /// Raw JSON. Whatever the command carried, kept exactly as recorded — this
  /// is replayed verbatim, so parsing it through a live model would let a
  /// refactor change what a queued write means.
  TextColumn get payload => text()();

  /// Persisted at first launch (§11.5). Distinguishes two devices belonging to
  /// the same driver, which is the case the idempotency key has to survive.
  TextColumn get deviceId => text().withLength(min: 1, max: 64)();

  IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  /// Null until the row has been accepted by a server. Non-null rows are
  /// eligible for trimming.
  IntColumn get syncedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();
}

/// An immutable record of every money and status mutation.
///
/// Append-only, and never deleted. Two things depend on it:
///
/// * A `remittances` edit is allowed precisely *because* it lands here. That
///   table is hand-entered cash where typos are certain, so the control is the
///   audit trail rather than immutability.
/// * A pin demotion writes one, because losing a confidence-4 pin is a
///   material change to the geocoding asset and has to be attributable
///   (§10.5).
class AuditLogs extends Table with UuidPrimaryKey, AppendOnlyColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get entityType => text().withLength(min: 1, max: 60)();

  TextColumn get entityId => text().withLength(min: 36, max: 36)();

  /// What happened: `remittance.amend`, `pin.demote`, `order.deliver`.
  TextColumn get action => text().withLength(min: 1, max: 60)();

  /// Raw JSON, both of them, and nullable — a creation has no before, a
  /// deletion has no after. Stored as recorded so an audit entry stays
  /// readable after the model that produced it has changed.
  TextColumn get before => text().nullable()();

  TextColumn get after => text().nullable()();

  /// When the change happened, as distinct from when the row was written.
  IntColumn get occurredAt => integer().map(const UtcMillisecondsConverter())();
}

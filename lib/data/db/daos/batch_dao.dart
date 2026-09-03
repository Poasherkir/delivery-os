import 'dart:convert';

// Drift's own `Batch` is the batched-statements API and is never used here;
// the row class of the same name is. Hidden rather than prefixed so the row
// keeps reading as `Batch`, which is what it is.
import 'package:drift/drift.dart' hide Batch;

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/repositories/batch_repository.dart'
    show BatchNotOpenException;
import '../../../domain/value_objects/batch_status.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../app_database.dart';
import '../conventions/entity_stamp.dart';

/// Find-or-create for the day's batch. One method, on purpose.
///
/// `orders.batch_id` is NOT NULL, so order entry cannot work without a batch —
/// that is why this exists at M1 and it is the whole reason. Closing, settling,
/// reopening, listing and every batch screen belong to M2 and are absent rather
/// than stubbed, because a `close()` written now would be written without the
/// money engine that decides what closing means.
final class BatchDao {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory BatchDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => BatchDao._(database, clock, uuid, deviceId);

  const BatchDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  /// The open batch for this company and day, creating it if there is none.
  ///
  /// Idempotent, and it has to be: every order entered today runs this, and
  /// `(owner_id, company_id, service_date)` is unique, so a second batch beside
  /// the first is not a duplicate row — it is a constraint violation in the
  /// middle of the driver's fastest path.
  ///
  /// The lookup and the insert share one transaction. Split across two, a
  /// re-import racing an entry would both see nothing and both insert.
  ///
  /// **Queues an outbox row only when it creates one.** Finding the existing
  /// batch is not a mutation, and a queued `create` on every order would replay
  /// at V2 as a hundred attempts to make the same batch.
  ///
  /// Throws [BatchNotOpenException] if the day's batch is closed, settled or
  /// deleted. Nothing in M1 can produce any of those states — there is no
  /// method that closes a batch — so reaching it means the database says
  /// something this app could not have written, and inventing an answer here
  /// would mean silently appending orders to a settled batch. That is invariant
  /// 7, and M2 owns the real answer.
  Future<Batch> ensureOpenBatch({
    required String ownerId,
    required String companyId,
    required String serviceDate,
  }) {
    return _db.transaction(() async {
      final Batch? existing =
          await (_db.select(_db.batches)..where(
                ($BatchesTable b) =>
                    b.ownerId.equals(ownerId) &
                    b.companyId.equals(companyId) &
                    b.serviceDate.equals(serviceDate),
              ))
              .getSingleOrNull();

      if (existing != null) {
        if (existing.status != BatchStatus.open || existing.deletedAt != null) {
          throw BatchNotOpenException(
            batchId: existing.id,
            status: existing.status,
            isDeleted: existing.deletedAt != null,
          );
        }
        return existing;
      }

      final String id = _uuid.next();
      final EntityStamp stamp = EntityStamper(_clock).forInsert();

      final Batch created = await _db
          .into(_db.batches)
          .insertReturning(
            BatchesCompanion.insert(
              id: id,
              ownerId: ownerId,
              companyId: companyId,
              serviceDate: serviceDate,
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          );

      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              id: _uuid.next(),
              entityType: 'batch',
              entityId: id,
              operation: OutboxOperation.create,
              payload: jsonEncode(<String, Object?>{
                'company_id': companyId,
                'service_date': serviceDate,
              }),
              deviceId: _deviceId,
              createdAt: stamp.updatedAt,
            ),
          );

      return created;
    });
  }
}

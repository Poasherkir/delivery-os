import 'dart:convert';

// Drift's own `Batch` is the batched-statements API and is never used here;
// the row class of the same name is. Hidden rather than prefixed so the row
// keeps reading as `Batch`, which is what it is.
import 'package:drift/drift.dart' hide Batch;

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/repositories/batch_repository.dart'
    show
        BatchHasOpenOrdersException,
        BatchNotClosedException,
        BatchNotOpenException;
import '../../../domain/state/order_status.dart';
import '../../../domain/value_objects/batch_status.dart';
import '../../../domain/value_objects/centimes.dart';
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

  /// Every batch for a service date, whatever its status.
  ///
  /// Includes the closed, because the batch list's whole job is to show a day
  /// that is finished as finished. Excludes the soft-deleted, which nothing
  /// creates.
  Future<List<Batch>> forDate({
    required String ownerId,
    required String serviceDate,
  }) {
    return (_db.select(_db.batches)
          ..where(
            ($BatchesTable b) =>
                b.ownerId.equals(ownerId) &
                b.serviceDate.equals(serviceDate) &
                b.deletedAt.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$BatchesTable>>[
            ($BatchesTable b) => OrderingTerm(expression: b.id),
          ]))
        .get();
  }

  Future<Batch?> byId(String id) => (_db.select(
    _db.batches,
  )..where(($BatchesTable b) => b.id.equals(id))).getSingleOrNull();

  /// Every batch for a day, with its company and its parcel counts.
  ///
  /// One query. The alternative — list the batches, then count orders per
  /// batch — is a round trip per company, on a screen a driver opens to decide
  /// whether the day is finished.
  ///
  /// The open count is computed in the same pass with a conditional sum rather
  /// than a second query, because it and the total are two views of one set and
  /// fetching them separately could disagree if a write landed between them.
  Future<List<BatchSummaryRow>> summariesForDate({
    required String ownerId,
    required String serviceDate,
  }) async {
    final List<String> holding = <String>[
      for (final OrderStatus status in OrderStatus.values)
        if (status.isOpen) status.name,
    ];
    final String placeholders = List<String>.generate(
      holding.length,
      (int i) => '?${i + 3}',
    ).join(', ');

    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT b.id, b.service_date, b.status, b.version, '
          'cmp.name AS company_name, '
          'count(o.id) AS total_orders, '
          'coalesce(sum(CASE WHEN o.status IN ($placeholders) THEN 1 ELSE 0 '
          'END), 0) AS open_orders, '
          'coalesce(sum(o.cod_amount), 0) AS expected_collection '
          'FROM batches b '
          'JOIN companies cmp ON cmp.id = b.company_id '
          'LEFT JOIN orders o ON o.batch_id = b.id AND o.deleted_at IS NULL '
          'WHERE b.owner_id = ?1 AND b.service_date = ?2 '
          'AND b.deleted_at IS NULL '
          'GROUP BY b.id '
          'ORDER BY cmp.name, b.id',
          variables: <Variable<Object>>[
            Variable<String>(ownerId),
            Variable<String>(serviceDate),
            for (final String status in holding) Variable<String>(status),
          ],
          readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
            _db.batches,
            _db.companies,
            _db.orders,
          },
        )
        .get();

    return rows
        .map(
          (QueryRow r) => (
            id: r.read<String>('id'),
            companyName: r.read<String>('company_name'),
            serviceDate: r.read<String>('service_date'),
            status: _db.batches.status.converter.fromSql(
              r.read<String>('status'),
            ),
            version: r.read<int>('version'),
            totalOrders: r.read<int>('total_orders'),
            openOrders: r.read<int>('open_orders'),
            expectedCollection: Centimes(r.read<int>('expected_collection')),
          ),
        )
        .toList();
  }

  /// Closes a batch: the day's deliveries are finished, the money is not yet
  /// confirmed.
  ///
  /// **Refuses while any order is still open.** `OrderStatus.isOpen` covers
  /// `pending`, `onRoute`, `arrived` and `failed`, and the last of those is the
  /// reason this check is not merely tidiness: `failed` means the disposition
  /// is undecided, so the money is undecided, so the day cannot be totalled.
  /// §12.3 states it as the settlement precondition; enforcing it one step
  /// earlier means a batch never reaches M3 in a state M3 has to reject.
  ///
  /// Throws [BatchNotOpenException] if the batch is not currently open —
  /// closing a settled batch would be rewriting a day whose money is already
  /// confirmed, which is invariant 7.
  ///
  /// Throws [BatchHasOpenOrdersException] naming how many are unresolved, so a
  /// screen can say what is left rather than only that it refused.
  Future<Batch> close(Batch current) {
    return _db.transaction(() async {
      final Batch batch = await _requireOpen(current.id);
      final int open = await _openOrderCount(batch.id);
      if (open > 0) {
        throw BatchHasOpenOrdersException(batchId: batch.id, openOrders: open);
      }

      final EntityStamp stamp = EntityStamper(_clock).forUpdate(batch.stamp);
      await (_db.update(
        _db.batches,
      )..where(($BatchesTable b) => b.id.equals(batch.id))).write(
        BatchesCompanion(
          status: const Value<BatchStatus>(BatchStatus.closed),
          closedAt: Value<DateTime?>(stamp.updatedAt),
          updatedAt: Value<DateTime>(stamp.updatedAt),
          version: Value<int>(stamp.version),
        ),
      );

      await _queue(
        batch.id,
        OutboxOperation.update,
        stamp.updatedAt,
        <String, Object?>{'status': BatchStatus.closed.name},
      );

      return (_db.select(
        _db.batches,
      )..where(($BatchesTable b) => b.id.equals(batch.id))).getSingle();
    });
  }

  /// Reopens a closed batch, so a parcel the driver forgot can still be added.
  ///
  /// **A settled batch is never reopened.** Once `daily_settlements` holds a
  /// row the numbers are frozen and corrections become
  /// `settlement_adjustments` (invariant 7); reopening would let an edit
  /// silently contradict a settlement already computed from it. Closed is a
  /// pause, settled is a fact.
  ///
  /// `closed_at` is cleared, because it records when the day finished and the
  /// day has not finished. The version still increments — a reopen is a write.
  Future<Batch> reopen(Batch current) {
    return _db.transaction(() async {
      final Batch? batch = await byId(current.id);
      if (batch == null || batch.deletedAt != null) {
        throw StateError('batch ${current.id} no longer exists');
      }
      if (batch.status != BatchStatus.closed) {
        throw BatchNotClosedException(batchId: batch.id, status: batch.status);
      }

      final EntityStamp stamp = EntityStamper(_clock).forUpdate(batch.stamp);
      await (_db.update(
        _db.batches,
      )..where(($BatchesTable b) => b.id.equals(batch.id))).write(
        BatchesCompanion(
          status: const Value<BatchStatus>(BatchStatus.open),
          closedAt: const Value<DateTime?>(null),
          updatedAt: Value<DateTime>(stamp.updatedAt),
          version: Value<int>(stamp.version),
        ),
      );

      await _queue(
        batch.id,
        OutboxOperation.update,
        stamp.updatedAt,
        <String, Object?>{'status': BatchStatus.open.name},
      );

      return (_db.select(
        _db.batches,
      )..where(($BatchesTable b) => b.id.equals(batch.id))).getSingle();
    });
  }

  /// How many of a batch's live orders still hold it open.
  ///
  /// Counted in SQL rather than by fetching and filtering: a batch is fifteen
  /// rows today and a re-import could make it far more, and this runs on every
  /// close attempt.
  Future<int> _openOrderCount(String batchId) async {
    final List<String> holding = <String>[
      for (final OrderStatus status in OrderStatus.values)
        if (status.isOpen) status.name,
    ];

    final QueryRow row = await _db
        .customSelect(
          'SELECT count(*) AS c FROM orders '
          'WHERE batch_id = ?1 AND deleted_at IS NULL '
          'AND status IN (${List<String>.filled(holding.length, '?').join(', ')})',
          variables: <Variable<Object>>[
            Variable<String>(batchId),
            for (final String status in holding) Variable<String>(status),
          ],
          readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
            _db.orders,
          },
        )
        .getSingle();

    return row.read<int>('c');
  }

  Future<Batch> _requireOpen(String id) async {
    final Batch? batch = await byId(id);
    if (batch == null) {
      throw StateError('batch $id no longer exists');
    }
    if (batch.status != BatchStatus.open || batch.deletedAt != null) {
      throw BatchNotOpenException(
        batchId: batch.id,
        status: batch.status,
        isDeleted: batch.deletedAt != null,
      );
    }
    return batch;
  }

  Future<void> _queue(
    String batchId,
    OutboxOperation operation,
    DateTime at,
    Map<String, Object?> payload,
  ) {
    return _db
        .into(_db.outbox)
        .insert(
          OutboxCompanion.insert(
            id: _uuid.next(),
            entityType: 'batch',
            entityId: batchId,
            operation: operation,
            payload: jsonEncode(payload),
            deviceId: _deviceId,
            createdAt: at,
          ),
        );
  }
}

/// One joined batch row, before it crosses into `domain/`.
typedef BatchSummaryRow = ({
  String id,
  String companyName,
  String serviceDate,
  BatchStatus status,
  int version,
  int totalOrders,
  int openOrders,
  Centimes expectedCollection,
});

/// The audit columns as an [EntityStamp], so a DAO never assembles one by hand.
extension BatchStamp on Batch {
  EntityStamp get stamp => EntityStamp(
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
  );
}

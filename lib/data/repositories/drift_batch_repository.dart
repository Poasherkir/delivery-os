import '../../core/time/clock.dart';
import '../../core/time/service_day.dart';
import '../../domain/entities/batch.dart';
import '../../domain/entities/batch_summary.dart';
import '../../domain/repositories/batch_repository.dart';
import '../db/app_database.dart' as db;
import '../db/daos/batch_dao.dart';

/// [BatchRepository] against the local database.
///
/// This is where the service date stops being the caller's problem. The DAO
/// takes a date because a DAO should not read a clock to decide what row to
/// write; the repository supplies today's when the caller does not name one,
/// which is every caller until M2's batch screen exists.
final class DriftBatchRepository implements BatchRepository {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftBatchRepository({
    required BatchDao dao,
    required Clock clock,
    required String ownerId,
  }) => DriftBatchRepository._(dao, clock, ownerId);

  const DriftBatchRepository._(this._dao, this._clock, this._ownerId);

  final BatchDao _dao;
  final Clock _clock;
  final String _ownerId;

  @override
  Future<Batch> ensureOpenBatch({
    required String companyId,
    String? serviceDate,
  }) async => _toDomain(
    await _dao.ensureOpenBatch(
      ownerId: _ownerId,
      companyId: companyId,
      serviceDate: serviceDate ?? ServiceDay.from(_clock.nowUtc()),
    ),
  );

  @override
  Future<List<BatchSummary>> summariesForDate({String? serviceDate}) async {
    final List<BatchSummaryRow> rows = await _dao.summariesForDate(
      ownerId: _ownerId,
      serviceDate: serviceDate ?? ServiceDay.from(_clock.nowUtc()),
    );

    return rows
        .map(
          (BatchSummaryRow r) => BatchSummary(
            id: r.id,
            companyName: r.companyName,
            serviceDate: r.serviceDate,
            status: r.status,
            version: r.version,
            totalOrders: r.totalOrders,
            openOrders: r.openOrders,
            expectedCollection: r.expectedCollection,
          ),
        )
        .toList();
  }

  @override
  Future<void> close(String batchId) async =>
      _dao.close(await _require(batchId));

  @override
  Future<void> reopen(String batchId) async =>
      _dao.reopen(await _require(batchId));

  /// The stored row behind an id, re-read rather than reconstructed.
  ///
  /// Same reasoning as `DriftCustomerRepository._row`: the DAO stamps from the
  /// version it is handed, and a row rebuilt from a summary that has been on
  /// screen for a minute would carry a stale one.
  Future<db.Batch> _require(String batchId) async {
    final db.Batch? row = await _dao.byId(batchId);
    if (row == null) {
      throw StateError('batch $batchId no longer exists');
    }
    return row;
  }

  Batch _toDomain(db.Batch row) => Batch(
    id: row.id,
    companyId: row.companyId,
    serviceDate: row.serviceDate,
    status: row.status,
    version: row.version,
  );
}

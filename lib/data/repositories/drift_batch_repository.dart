import '../../core/time/clock.dart';
import '../../core/time/service_day.dart';
import '../../domain/entities/batch.dart';
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

  Batch _toDomain(db.Batch row) => Batch(
    id: row.id,
    companyId: row.companyId,
    serviceDate: row.serviceDate,
    status: row.status,
    version: row.version,
  );
}

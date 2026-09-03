import '../entities/batch.dart';
import '../value_objects/batch_status.dart';

/// Raised when the day's batch exists but cannot take orders.
///
/// Lives here rather than in `data/` because the layer that has to say
/// something to the driver is `features/`, and `features/` may not import
/// `data/`. A named failure rather than a bare exception for the same reason
/// `DuplicatePhoneException` is one: the caller has to tell this apart from a
/// write that simply failed.
///
/// Nothing in M1 can produce it. There is no method that closes a batch, so a
/// closed one means the database holds something this app did not write, and
/// the correct response is to stop rather than to append orders to a settled
/// day's work (invariant 7).
final class BatchNotOpenException implements Exception {
  const BatchNotOpenException({
    required this.batchId,
    required this.status,
    required this.isDeleted,
  });

  final String batchId;
  final BatchStatus status;
  final bool isDeleted;

  @override
  String toString() =>
      'BatchNotOpenException($batchId, ${status.name}'
      '${isDeleted ? ', deleted' : ''})';
}

/// The day's batch, as `features/` sees it.
///
/// One method. Batch lifecycle — closing, settling, reopening, listing, the
/// batch screens — is M2, and this interface stays this size until then. A
/// `close()` declared now would be declared without the money engine that
/// decides what closing means.
abstract interface class BatchRepository {
  /// The open batch for [companyId] on [serviceDate], creating it if there is
  /// none.
  ///
  /// [serviceDate] defaults to the current service day. It is a parameter and
  /// not a fixed derivation because **the derived date is a default, not a
  /// constraint** — a driver entering tomorrow's orders tonight is a real case.
  /// Choosing the date is a batch screen's job in M2; nothing on the entry path
  /// asks, and until that screen exists every caller takes the default.
  ///
  /// Throws [BatchNotOpenException] when the day's batch is closed, settled or
  /// deleted.
  Future<Batch> ensureOpenBatch({
    required String companyId,
    String? serviceDate,
  });
}

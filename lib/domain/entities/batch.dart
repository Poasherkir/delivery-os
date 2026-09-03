import 'package:meta/meta.dart';

import '../value_objects/batch_status.dart';

/// One driver, one company, one service date.
///
/// The unit of daily work and the unit of settlement. A driver working two
/// companies in one day has two batches and one route.
///
/// What a screen can do with this in M1 is read [id] — it is the batch an order
/// is filed under. [status] is carried because a batch that is not open is a
/// thing the entry flow has to be able to say out loud, not because anything
/// here can change it.
@immutable
final class Batch {
  const Batch({
    required this.id,
    required this.companyId,
    required this.serviceDate,
    required this.status,
    required this.version,
  });

  final String id;
  final String companyId;

  /// The business day, `YYYY-MM-DD`.
  ///
  /// A string rather than a `DateTime` because it is a day, not an instant, and
  /// the difference is the whole point: a delivery at 00:30 belongs to the
  /// previous working day. `ServiceDay` derives it.
  final String serviceDate;

  final BatchStatus status;

  /// Carried so a later write can be stamped without re-reading the row.
  final int version;

  /// Whether orders may still be added.
  bool get isOpen => status == BatchStatus.open;

  @override
  bool operator ==(Object other) =>
      other is Batch && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() => 'Batch($id, v$version, $serviceDate, ${status.name})';
}

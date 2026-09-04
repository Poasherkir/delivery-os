import 'package:meta/meta.dart';

import '../value_objects/batch_status.dart';
import '../value_objects/centimes.dart';

/// One row of the batch list: a company's work for a day, and where it stands.
///
/// A read model. The counts are the point — a driver looking at a batch needs
/// to know whether it can be closed *before* tapping close, and the only thing
/// that decides that is how many parcels are still unresolved. Showing the
/// refusal reason up front is cheaper than a refusal.
@immutable
final class BatchSummary {
  const BatchSummary({
    required this.id,
    required this.companyName,
    required this.serviceDate,
    required this.status,
    required this.version,
    required this.totalOrders,
    required this.openOrders,
    required this.expectedCollection,
  });

  final String id;
  final String companyName;
  final String serviceDate;
  final BatchStatus status;

  /// Carried so a close or reopen can be stamped without re-reading the row.
  final int version;

  /// Live parcels in the batch, whatever their status.
  final int totalOrders;

  /// How many still hold the batch open — `pending`, `onRoute`, `arrived`,
  /// `failed`. `failed` counts because its disposition is undecided, so the
  /// money is undecided.
  final int openOrders;

  /// The sum of what is owed at the doors, in centimes.
  ///
  /// **Not a settlement figure.** It is the total of `cod_amount` as entered
  /// off the manifest, which is what the driver expects to collect; what was
  /// actually collected, and what of it is theirs, is M3's to compute. Named
  /// `expected` so the two cannot be confused at a glance.
  final Centimes expectedCollection;

  /// Whether closing would succeed.
  ///
  /// Derived rather than stored, and deliberately the same rule the DAO
  /// enforces — a screen that decided this differently would offer a button
  /// that fails.
  bool get canClose => status == BatchStatus.open && openOrders == 0;

  /// How many parcels are finished.
  int get resolvedOrders => totalOrders - openOrders;

  @override
  bool operator ==(Object other) =>
      other is BatchSummary && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() =>
      'BatchSummary($id, $serviceDate, ${status.name}, '
      '$resolvedOrders/$totalOrders)';
}

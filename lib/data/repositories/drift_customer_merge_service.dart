import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_merge_service.dart';
import '../db/app_database.dart' as db;
import '../db/customer_merge.dart';

/// [CustomerMergeService] against the local database.
final class DriftCustomerMergeService implements CustomerMergeService {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftCustomerMergeService({required CustomerMerge merge}) =>
      DriftCustomerMergeService._(merge);

  const DriftCustomerMergeService._(this._merge);

  final CustomerMerge _merge;

  @override
  Future<Customer> merge({
    required String survivorId,
    required String loserId,
  }) async {
    final db.Customer row = await _merge.run(
      survivorId: survivorId,
      loserId: loserId,
    );
    return Customer(
      id: row.id,
      displayName: row.displayName,
      version: row.version,
      phone: row.phoneE164,
      phoneRaw: row.phoneRaw,
      phoneAlt: row.phoneAlt,
      notes: row.notes,
      riskFlag: row.riskFlag,
      totalOrders: row.totalOrders,
      totalDelivered: row.totalDelivered,
      totalFailed: row.totalFailed,
      lastDeliveredAt: row.lastDeliveredAt,
    );
  }
}

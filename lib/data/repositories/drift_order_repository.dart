import '../../core/time/clock.dart';
import '../../core/time/service_day.dart';
import '../../domain/entities/customer_history.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/value_objects/centimes.dart';
import '../../domain/value_objects/delivery_type.dart';
import '../db/app_database.dart' as db;
import '../db/daos/order_dao.dart';

/// [OrderRepository] against the local database.
///
/// The Drift row is imported under a prefix because both types are correctly
/// called `Order`, the same collision the customer and company repositories
/// have. Neither is renamed to dodge it.
final class DriftOrderRepository implements OrderRepository {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftOrderRepository({
    required OrderDao dao,
    required Clock clock,
    required String ownerId,
  }) => DriftOrderRepository._(dao, clock, ownerId);

  const DriftOrderRepository._(this._dao, this._clock, this._ownerId);

  final OrderDao _dao;

  /// Only so today's date can be derived. A DAO should not read a clock to
  /// decide which rows to return, the same split `DriftBatchRepository` makes.
  final Clock _clock;

  final String _ownerId;

  @override
  Future<List<Order>> forBatch(String batchId) async =>
      (await _dao.forBatch(batchId)).map(_toDomain).toList();

  @override
  Future<List<OrderSummary>> summariesForDate({String? serviceDate}) async {
    final List<OrderSummaryRow> rows = await _dao.summariesForDate(
      ownerId: _ownerId,
      serviceDate: serviceDate ?? ServiceDay.from(_clock.nowUtc()),
    );

    return rows.map(_summary).toList();
  }

  @override
  Future<Order?> findByTracking({
    required String companyId,
    required String trackingNumber,
  }) async {
    final db.Order? row = await _dao.findByTracking(
      ownerId: _ownerId,
      companyId: companyId,
      trackingNumber: trackingNumber.trim(),
    );
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Order> create({
    required String batchId,
    required String companyId,
    required String trackingNumber,
    String? customerId,
    String? addressId,
    Centimes codAmount = Centimes.zero,
    DeliveryType deliveryType = DeliveryType.home,
    String? notes,
  }) async {
    final String tracking = trackingNumber.trim();

    // Checked before writing rather than catching the constraint violation, so
    // the caller gets the order that already holds the number. A bare "unique
    // constraint failed" would make the UI go and look for it to say anything
    // useful, and scanning the same parcel twice is the ordinary way this
    // happens rather than an exceptional one.
    //
    // This is a check-then-act and the unique key is still the real guarantee:
    // two concurrent creates would leave one of them throwing, which is
    // correct. There is one driver on one phone, so the race is theoretical.
    final Order? existing = await findByTracking(
      companyId: companyId,
      trackingNumber: tracking,
    );
    if (existing != null) {
      throw DuplicateTrackingException(existing);
    }

    return _toDomain(
      await _dao.create(
        ownerId: _ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: tracking,
        customerId: customerId,
        addressId: addressId,
        codAmount: codAmount,
        deliveryType: deliveryType,
        notes: notes,
      ),
    );
  }

  @override
  Future<void> softDelete(Order current) async {
    final db.Order? row = await _dao.byId(current.id);
    if (row == null) {
      throw StateError('order ${current.id} no longer exists');
    }
    await _dao.softDelete(row);
  }

  @override
  Future<CustomerHistory> historyForCustomer(
    String customerId, {
    int? limit = CustomerHistory.defaultWindow,
  }) async {
    // Two queries, deliberately. The count is what lets the screen say it is
    // showing part of the history; deriving it from the window's length would
    // make a full page indistinguishable from a truncated one.
    final List<OrderSummaryRow> rows = await _dao.historyForCustomer(
      ownerId: _ownerId,
      customerId: customerId,
      limit: limit,
    );
    final int total = await _dao.historyCountForCustomer(
      ownerId: _ownerId,
      customerId: customerId,
    );

    return CustomerHistory(recent: rows.map(_summary).toList(), total: total);
  }

  OrderSummary _summary(OrderSummaryRow r) => OrderSummary(
    id: r.id,
    trackingNumber: r.trackingNumber,
    status: r.status,
    deliveryType: r.deliveryType,
    codAmount: r.codAmount,
    companyName: r.companyName,
    serviceDate: r.serviceDate,
    customerName: r.customerName,
    communeNameFr: r.communeNameFr,
    communeNameAr: r.communeNameAr,
    addressDetail: r.addressDetail,
  );

  Order _toDomain(db.Order row) => Order(
    id: row.id,
    batchId: row.batchId,
    companyId: row.companyId,
    trackingNumber: row.trackingNumber,
    status: row.status,
    version: row.version,
    customerId: row.customerId,
    addressId: row.addressId,
    codAmount: row.codAmount,
    deliveryType: row.deliveryType,
    notes: row.notes,
  );
}

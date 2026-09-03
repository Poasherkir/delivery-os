import '../entities/customer_history.dart';
import '../entities/order.dart';
import '../entities/order_summary.dart';
import '../value_objects/centimes.dart';
import '../value_objects/delivery_type.dart';

/// Raised when a tracking number is already in this company's orders.
///
/// A named failure rather than a bare exception, for the reason
/// `DuplicatePhoneException` is one: the entry flow has to tell this apart from
/// a write that simply failed, because this one has a good answer for the
/// driver — the parcel is already entered, here it is.
///
/// Scanning the same parcel twice is the ordinary way this happens. It is not
/// an error on the driver's part and the copy does not treat it as one.
final class DuplicateTrackingException implements Exception {
  const DuplicateTrackingException(this.existing);

  /// The order already carrying the number, so the UI can show it rather than
  /// making the driver go and look.
  final Order existing;

  @override
  String toString() => 'DuplicateTrackingException(${existing.id})';
}

/// Reading and writing orders, as `features/` sees it.
///
/// Small, and it stays small until M2. There is no `edit` and no status change:
/// every status change goes through `OrderStateMachine.transitionTo` inside the
/// flow that owns it (invariant 6), and those flows — delivered, failed,
/// rescheduled — are M2. What M1 owes is getting a parcel into the day's batch
/// and showing that it landed.
abstract interface class OrderRepository {
  /// A batch's live orders, newest first.
  Future<List<Order>> forBatch(String batchId);

  /// Today's parcels, newest first, across every company.
  ///
  /// [serviceDate] defaults to the current service day. A driver working two
  /// companies in one morning has two batches and one list — the batch is the
  /// settlement unit, not a thing to navigate between.
  Future<List<OrderSummary>> summariesForDate({String? serviceDate});

  /// One customer's parcels, most recent first, with a count of all of them.
  ///
  /// [limit] defaults to [CustomerHistory.defaultWindow]; null loads
  /// everything and is only reached by an explicit "see all". A detail view a
  /// driver taps into mid-round must not open by fetching a year of history.
  Future<CustomerHistory> historyForCustomer(
    String customerId, {
    int? limit = CustomerHistory.defaultWindow,
  });

  /// The order carrying this tracking number for this company, or null.
  Future<Order?> findByTracking({
    required String companyId,
    required String trackingNumber,
  });

  /// Adds an order to a batch.
  ///
  /// Throws [DuplicateTrackingException] when the company already has an order
  /// with this tracking number, carrying that order so the caller can offer it.
  ///
  /// [customerId] and [addressId] are optional because a parcel can be entered
  /// before its customer record exists. A phone that will not parse must not
  /// stop a driver standing in an agency at 07:00, and neither must a customer
  /// they have not finished typing.
  Future<Order> create({
    required String batchId,
    required String companyId,
    required String trackingNumber,
    String? customerId,
    String? addressId,
    Centimes codAmount,
    DeliveryType deliveryType,
    String? notes,
  });

  /// Soft-deletes an order. The row survives; a settlement is built from it.
  Future<void> softDelete(Order current);
}

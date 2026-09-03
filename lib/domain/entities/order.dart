import 'package:meta/meta.dart';

import '../state/order_status.dart';
import '../value_objects/centimes.dart';
import '../value_objects/delivery_type.dart';

/// One parcel.
///
/// What `features/` needs to render a row in today's list and nothing more.
/// Six of the seven money columns are absent because they are not yet
/// computed — the money engine fills them at M3 — and a field carried here
/// before it holds anything would be read as though it did.
@immutable
final class Order {
  const Order({
    required this.id,
    required this.batchId,
    required this.companyId,
    required this.trackingNumber,
    required this.status,
    required this.version,
    this.customerId,
    this.addressId,
    this.codAmount = Centimes.zero,
    this.deliveryType = DeliveryType.home,
    this.notes,
  });

  final String id;
  final String batchId;
  final String companyId;

  /// Unique per company, never globally. Two companies use the same numbers.
  final String trackingNumber;

  final OrderStatus status;

  /// Carried so a later write can be stamped without re-reading the row.
  final int version;

  /// Null when the parcel arrived before its customer record did.
  final String? customerId;

  final String? addressId;

  /// What the customer owes at the door.
  final Centimes codAmount;

  final DeliveryType deliveryType;
  final String? notes;

  /// Whether anyone has been attached to this parcel yet.
  ///
  /// Derived rather than stored. An order without a customer is enterable but
  /// not deliverable, and the list has to be able to say so.
  bool get needsCustomer => customerId == null;

  @override
  bool operator ==(Object other) =>
      other is Order && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  /// The tracking number is deliberately included and the customer is
  /// deliberately not.
  ///
  /// A tracking number is the company's own reference for a parcel and is
  /// printed on the outside of it; it identifies a package, not a household.
  /// The customer id is a bare UUID and would say nothing anyway, so it is left
  /// out rather than carried as noise.
  @override
  String toString() => 'Order($id, v$version, $trackingNumber, ${status.name})';
}

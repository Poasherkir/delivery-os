import 'package:meta/meta.dart';

import '../state/order_status.dart';
import '../value_objects/centimes.dart';
import '../value_objects/delivery_type.dart';

/// One row of today's list.
///
/// A read model, not an entity. It is assembled from a join across five tables
/// and there is no `OrderSummary` anywhere in the database — which is the
/// point: the list needs a customer's name and a commune's name, and making the
/// screen fetch those per row would be five queries a parcel on the screen a
/// driver opens most.
///
/// Both commune names travel, for the reason `Commune` carries both: which one
/// to show is decided from the active locale, and only the widget knows it.
@immutable
final class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.deliveryType,
    required this.codAmount,
    required this.companyName,
    this.customerName,
    this.communeNameFr,
    this.communeNameAr,
    this.addressDetail,
  });

  final String id;
  final String trackingNumber;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final Centimes codAmount;

  /// Which company's manifest this came off. Shown when the day has more than
  /// one, and a driver working two in a morning needs to tell them apart.
  final String companyName;

  /// Null when the parcel was entered before anyone was attached to it.
  final String? customerName;

  final String? communeNameFr;
  final String? communeNameAr;

  /// The cité, the block, the floor. Carried so a row can show where, not only
  /// who — and deliberately never put in [toString].
  final String? addressDetail;

  /// Whether a person still has to be attached before this can be delivered.
  bool get needsCustomer => customerName == null;

  /// Whether anyone knows where this goes.
  ///
  /// A parcel can be entered with neither, and both are things the list has to
  /// be able to show as missing rather than as blank.
  bool get needsAddress => communeNameFr == null;

  /// The commune, in the caller's language.
  ///
  /// Takes the choice rather than the locale: `domain/` cannot see a
  /// `BuildContext` and must not learn to.
  String? commune({required bool arabic}) =>
      arabic ? communeNameAr : communeNameFr;

  @override
  bool operator ==(Object other) => other is OrderSummary && other.id == id;

  @override
  int get hashCode => id.hashCode;

  /// The tracking number identifies a package. The customer's name, their
  /// commune and their street do not appear: together they are a household,
  /// and this string can reach a log line.
  @override
  String toString() => 'OrderSummary($id, $trackingNumber, ${status.name})';
}

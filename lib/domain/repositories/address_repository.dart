import '../entities/address.dart';

/// Reading and writing customer addresses, as `features/` sees it.
///
/// Small, and shaped by the one screen that uses it. Entry captures a commune
/// and a line of free text; everything else on the row — coordinates, the
/// confidence tier, the confirmed-delivery count — is written by the delivery
/// flow at M2, when a real GPS fix exists to write.
///
/// No `makePrimary` and no `edit`: managing a customer's several addresses is
/// the customer profile screen's job, and it is a separate task. What is here
/// is what entry needs — the addresses to offer, and a way to add one.
abstract interface class AddressRepository {
  /// A customer's live addresses, the primary one first.
  ///
  /// Primary first because entry offers the top one by default, and the
  /// address a driver has been to five times should be that default rather
  /// than whichever was typed most recently.
  Future<List<Address>> forCustomer(String customerId);

  /// Adds an address. The first one a customer gets is primary automatically.
  ///
  /// No coordinates, so it lands at `GeoConfidence.none` — tier 0, which
  /// invariant 9 never routes. That is not a defect: a driver who knows the
  /// building does not need a pin, and the pin arrives on its own the first
  /// time a delivery is confirmed there. Refusing to store an address without
  /// coordinates would refuse most of them.
  Future<Address> create({
    required String customerId,
    required int wilayaCode,
    required int communeId,
    String? detail,
    String? label,
  });
}

/// Where the customer takes delivery.
///
/// Roughly half of Algerian COD volume is stop-desk (§1.4), so this is not a
/// minor flag: a stop-desk parcel must never enter the route optimizer, or the
/// driver's route is wrong on day one. It stays in the batch and in the money.
enum DeliveryType {
  /// To the customer's address. Goes on the route.
  home,

  /// The customer collects at the agency. Never routed.
  stopdesk;

  /// Whether this parcel is a candidate for the optimizer.
  ///
  /// Necessary, not sufficient: a home delivery also needs a routable
  /// coordinate (`GeoConfidence.isRoutable`, invariant 9).
  bool get isRoutable => this == home;
}

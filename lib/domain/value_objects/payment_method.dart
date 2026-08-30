/// How the customer paid.
///
/// Cash dominates — this is a cash-on-delivery market — but the others occur
/// and the settlement has to account for them, because only cash affects the
/// driver's cash-on-hand figure.
enum PaymentMethod {
  cash,
  card,
  transfer,
  other;

  /// Whether collecting this increases the cash the driver is carrying.
  ///
  /// The cash-on-hand figure (§12.4) is the number a driver holding several
  /// hundred thousand dinars is most anxious about, and a card payment that
  /// counted toward it would make that number a lie.
  bool get isCash => this == cash;
}

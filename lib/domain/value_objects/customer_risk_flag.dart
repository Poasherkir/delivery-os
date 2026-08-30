/// How much trouble a customer has been.
///
/// TEXT by name rather than the `SMALLINT 0/1/2` the schema originally carried.
/// An ordinal silently reassigns every row when the enum is reordered, and a
/// bare `2` in a database browser at 7am tells nobody anything.
///
/// Only ever raised by a human. Nothing in the app infers a risk flag from
/// delivery history — a customer who was out twice is not a problem customer,
/// and a rule that decided otherwise would quietly build a blacklist nobody
/// agreed to.
enum CustomerRiskFlag {
  /// The default. Most customers.
  none,

  /// Worth a phone call before setting out.
  watch,

  /// Repeated refusals or abuse. Surfaced prominently before the driver goes.
  problem;

  bool get needsAttention => this != none;
}

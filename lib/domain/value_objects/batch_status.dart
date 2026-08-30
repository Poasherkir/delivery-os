/// The lifecycle of one day's work for one company.
///
/// A batch is the unit of settlement: one driver, one company, one service
/// date (§2.1). A driver working two companies in one day has two batches and
/// one route.
enum BatchStatus {
  /// Orders can still be added, edited and delivered.
  open,

  /// The driver has finished the day's deliveries but not yet confirmed the
  /// money. Every order must be in a closed state to get here.
  closed,

  /// The money is confirmed and hashed into `daily_settlements`. The batch and
  /// its orders are read-only from this point; corrections become
  /// `settlement_adjustments` rows, never edits (invariant 7).
  settled;

  /// Whether the batch and its orders may still be written to.
  bool get isEditable => this != settled;
}

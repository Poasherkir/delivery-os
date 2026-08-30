/// The lifecycle of one day's route.
///
/// One route per driver per day, spanning every batch (§2.1) — a driver working
/// three companies drives one route, not three.
///
/// Three values, and deliberately no more. `optimizing` is a UI state with no
/// business being persisted, and `assigned` is meaningless with one driver.
enum RouteStatus {
  /// Optimized but not started. Stops can still be reordered and pinned.
  draft,

  /// The driver is driving it. Re-optimization from here only reorders the
  /// stops still ahead (§10.1).
  active,

  /// Every stop is resolved. The route is history.
  completed;

  /// Whether the driver is currently on this route.
  ///
  /// Location is read foreground-only, while a route is active, and never in
  /// the background (invariant 11). This is the flag that gates it.
  bool get isDriving => this == active;
}

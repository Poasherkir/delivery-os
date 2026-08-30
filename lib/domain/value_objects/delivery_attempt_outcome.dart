/// What happened at the door on one delivery attempt.
///
/// **A different axis from `OrderStatus`, and deliberately a different type.**
/// An attempt records what happened at a moment; the status records where the
/// parcel now stands. One `refused` attempt does not by itself decide whether
/// the order ends up rescheduled or returned — the driver decides that at the
/// end of the day, and that decision is what the money depends on.
///
/// **Provisional.** Collapsed from the eight sketched in §6.2, where `absent`
/// overlapped `noAnswer` and `rescheduled` overlapped `postponed`. Additions
/// come from observed field failures, not imagined ones: the real taxonomy is
/// one of the things to check against an actual bordereau before M1 hardens
/// ingestion.
///
/// Stored as TEXT by name, like every enum here.
enum DeliveryAttemptOutcome {
  /// Handed over, money collected.
  delivered,

  /// Nobody answered the phone or the door.
  noAnswer,

  /// The customer was there and declined the parcel.
  refused,

  /// The address was wrong or could not be found.
  wrongAddress,

  /// The customer asked for a different day or time.
  postponed,

  /// The merchant cancelled while the parcel was out.
  cancelled;

  /// Whether this attempt is the one that completes the order.
  bool get isSuccess => this == delivered;
}

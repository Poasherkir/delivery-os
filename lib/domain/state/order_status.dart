/// Where a parcel stands.
///
/// Eight states, and every transition between them goes through
/// `OrderStateMachine.transitionTo` (invariant 6, arriving in M2). Status is
/// never assigned directly.
///
/// Stored as TEXT by name. Never as an ordinal: inserting a state into the
/// middle of this enum would silently reassign every existing row, turning
/// delivered orders into something else with no error anywhere.
///
/// **`settled` is not here, deliberately.** Settlement is a fact about the
/// *batch*, held in `batches.status`. An order that was both `delivered` and
/// inside a settled batch would lose its delivery outcome, and with it the
/// ability to reproduce the settlement computed from it. Order immutability
/// after settlement follows from the batch's status, not from overwriting the
/// order's. `assigned` and `optimizing` are absent for their own reasons: one
/// driver makes assignment meaningless, and `optimizing` is a UI state with no
/// business being persisted.
enum OrderStatus {
  /// In a batch, not yet on a route.
  pending,

  /// On the active route.
  onRoute,

  /// The driver is at the stop.
  arrived,

  /// Terminal. The parcel reached the customer and the money was collected.
  delivered,

  /// An attempt failed and the **disposition is not yet decided**.
  ///
  /// Deliberately not terminal. At the end of the day the driver resolves every
  /// `failed` order into [rescheduled] or [returnedToAgency], and the
  /// difference is financial rather than cosmetic: a rescheduled parcel is
  /// still in the driver's possession and has earned nothing yet, while a
  /// returned one triggers the retour fee in the rule spec.
  failed,

  /// Deferred to a future date. Leaves today's batch and reappears in a new one.
  rescheduled,

  /// Terminal. The parcel went back to the company.
  returnedToAgency,

  /// Terminal. Cancelled by the merchant, at any point before delivery.
  cancelled;

  /// The order is finished forever and will not change again.
  bool get isTerminal =>
      this == delivered || this == returnedToAgency || this == cancelled;

  /// The order no longer holds its batch open.
  ///
  /// **A batch cannot be settled while any of its orders is open.** That is the
  /// settlement precondition in §12.3, and the reason every [failed] order has
  /// to be resolved before the day closes: `failed` means the disposition is
  /// still unknown, so the money is still unknown, so the batch cannot be
  /// totalled.
  ///
  /// [rescheduled] closes the batch without being terminal — the parcel leaves
  /// today's batch for a future one, so today's numbers are complete even
  /// though the order is not.
  bool get closesTheBatch => isTerminal || this == rescheduled;

  /// The complement of [closesTheBatch]: `pending`, `onRoute`, `arrived`,
  /// `failed`.
  bool get isOpen => !closesTheBatch;

  /// Which of the four display buckets this belongs to.
  ///
  /// Four buckets, not eight colours — colour is never the only signal, and
  /// eight hues that stay distinguishable in sunlight and under
  /// colour-blindness is not a solvable problem. Icon and label carry the
  /// specific state.
  OrderStatusTone get tone => switch (this) {
    // A customer asking for another day is not a problem and is not coloured
    // like one.
    OrderStatus.pending || OrderStatus.rescheduled => OrderStatusTone.neutral,
    OrderStatus.onRoute || OrderStatus.arrived => OrderStatusTone.inProgress,
    OrderStatus.delivered => OrderStatusTone.success,
    OrderStatus.failed ||
    OrderStatus.returnedToAgency ||
    OrderStatus.cancelled => OrderStatusTone.problem,
  };
}

/// The four display buckets from the UI rules, mapped onto the status tokens in
/// `ColorTokens`.
enum OrderStatusTone { neutral, inProgress, success, problem }

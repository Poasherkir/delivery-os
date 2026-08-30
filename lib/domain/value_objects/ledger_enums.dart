/// What the driver spent money on.
///
/// The five in §6.2. Expenses come off the driver's own earnings, never off
/// the company's amount, which is why they are a separate table rather than
/// another column on the order.
enum ExpenseCategory {
  /// Almost always the largest, and the one a per-kilometre earnings figure
  /// is measured against in V1.5.
  fuel,
  parking,
  maintenance,
  food,
  other,
}

/// How cash physically reached the company.
///
/// A *versement*. Only [cash] leaves the driver carrying less — the others
/// settle the balance without touching what is in the bag, which matters
/// because cash on hand is a security concern as well as an accounting one
/// (§1.3).
enum RemittanceMethod {
  /// Handed over at the agency.
  cash,

  /// Bank transfer.
  bank,

  /// Algérie Poste CCP account.
  ccp,

  /// BaridiMob, Algérie Poste's mobile app.
  baridimob,
}

/// What a queued outbox row will ask the server to do, when sync exists.
///
/// **Commands, not state diffs** (§11.2). Recording
/// `order.deliver { collected: 640000, at: T }` replays correctly regardless of
/// what else changed in the meantime; recording `{ status: 'delivered' }` does
/// not, because it silently overwrites whatever a second device did.
enum OutboxOperation {
  create,
  update,
  delete,

  /// An intent rather than a mutation. The shape that makes offline replay
  /// safe, and the reason this enum exists at all in a build that never sends
  /// anything.
  command,
}

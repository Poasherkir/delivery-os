/// The app's only source of "now".
///
/// Every timestamp this app records — `created_at`, `occurred_at`,
/// `confirmed_at`, and the millisecond inside every UUIDv7 — comes through
/// here rather than from `DateTime.now()`. Two reasons, and the second is the
/// one that matters:
///
/// * A settlement is a snapshot with a content hash. A test that cannot fix
///   the instant cannot produce a stable hash, so it ends up asserting on
///   everything except the thing that matters.
/// * Retrofitting a time source through DAOs and repositories later is exactly
///   the churn M0 exists to prevent, which is why this lands before anything
///   writes a row.
///
/// Always UTC. §6.1: timestamps are `TIMESTAMPTZ` and always UTC; the business
/// day is a separate `service_date` column, because a delivery at 00:30 belongs
/// to the previous working day. That cutoff is a business rule nobody has set
/// yet, so service-day logic is deliberately not here — it arrives with the
/// batch work in M2, once the cutoff hour is a decision rather than a guess.
abstract interface class Clock {
  /// The current instant, in UTC.
  DateTime nowUtc();
}

/// Reads the device clock. The implementation the app runs on.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// A clock that does not move unless told to.
///
/// Lives in `lib/` rather than `test/` on purpose: integration tests under
/// `integration_test/` need it too, and they cannot import from `test/`.
final class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  /// Starts at the Unix epoch. Convenient when the absolute instant is
  /// irrelevant and only the ordering matters.
  FixedClock.epoch() : _instant = DateTime.utc(1970);

  DateTime _instant;

  @override
  DateTime nowUtc() => _instant;

  /// Moves the clock forward, or backward with a negative duration.
  void advance(Duration by) => _instant = _instant.add(by);

  /// Jumps to a specific instant.
  set instant(DateTime value) => _instant = value.toUtc();
}

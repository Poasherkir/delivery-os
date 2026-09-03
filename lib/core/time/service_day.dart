/// Which working day an instant belongs to.
///
/// A delivery at 00:30 belongs to the previous working day, so the business
/// date is not the calendar date and cannot be derived by truncating a
/// timestamp. §6.1 keeps them as separate columns for exactly this reason:
/// `created_at` is an instant, `service_date` is a day's work.
///
/// **The derived date is a default, not a constraint.** A driver entering
/// tomorrow's orders tonight is a real case, and it is not a cutoff problem —
/// it is "the batch has a date and the date can be chosen". Choosing it belongs
/// to batch management in M2. Nothing on the entry path asks, because a date
/// field on a screen measured with a stopwatch is friction bought for a case
/// that has its own answer elsewhere.
abstract final class ServiceDay {
  /// **Provisional.** The hour a new working day begins, local time.
  ///
  /// Nobody delivers at 03:00, so anything between 02:00 and 05:00 is safe and
  /// the value only matters for the after-midnight case it exists to handle: a
  /// driver settling up at 00:30 is closing yesterday, not opening today.
  ///
  /// Provisional means it can move without anything else changing — it is one
  /// constant read in one place, not a rule spread through queries. If a real
  /// driver's day turns out to start at 05:00, this line is the change.
  static const int cutoffHour = 4;

  /// Algeria is UTC+1 all year and observes no daylight saving.
  ///
  /// Hard-coded rather than read from the device, deliberately. A phone whose
  /// timezone is wrong — set by hand, or still on the last country's — would
  /// otherwise silently file a day's work under the wrong date, and the
  /// settlement built from it would be short by a day's orders with nothing
  /// anywhere to notice. Every driver this app has is in Algeria.
  static const Duration utcOffset = Duration(hours: 1);

  /// The service date for [instant], as `YYYY-MM-DD`.
  ///
  /// Takes UTC because [Clock] only produces UTC. Converting here rather than
  /// at each call site means the offset is applied exactly once.
  static String from(DateTime instant) {
    final DateTime local = instant.toUtc().add(utcOffset);

    // Before the cutoff the work still belongs to the day that has just ended.
    final DateTime day = local.hour < cutoffHour
        ? local.subtract(const Duration(days: 1))
        : local;

    return format(day);
  }

  /// Formats a date as `YYYY-MM-DD`, the shape `service_date` stores.
  ///
  /// Zero-padded, because a text column sorts lexicographically and `2026-9-3`
  /// would sort after `2026-10-01`.
  static String format(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

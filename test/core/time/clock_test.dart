import 'package:delivery_os/core/time/clock.dart';
import 'package:test/test.dart';

void main() {
  group('SystemClock', () {
    test('returns UTC, never local', () {
      // A local timestamp written to a TIMESTAMPTZ column is a silent
      // one-hour error in Algeria, and worse for a driver who crosses a
      // timezone or changes device settings mid-day.
      expect(const SystemClock().nowUtc().isUtc, isTrue);
    });

    test('moves forward', () {
      final DateTime first = const SystemClock().nowUtc();
      final DateTime second = const SystemClock().nowUtc();
      expect(second.isBefore(first), isFalse);
    });

    test('is close to the device clock', () {
      final DateTime reference = DateTime.now().toUtc();
      final Duration drift = const SystemClock()
          .nowUtc()
          .difference(reference)
          .abs();
      expect(drift.inSeconds, lessThan(5));
    });
  });

  group('FixedClock', () {
    test('does not move on its own', () {
      // The property everything else depends on: same instant, every call.
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28, 7, 30));

      expect(clock.nowUtc(), clock.nowUtc());
      expect(clock.nowUtc(), DateTime.utc(2026, 8, 28, 7, 30));
    });

    test('normalizes a local instant to UTC', () {
      final DateTime local = DateTime(2026, 8, 28, 7, 30);
      final FixedClock clock = FixedClock(local);

      expect(clock.nowUtc().isUtc, isTrue);
      expect(clock.nowUtc(), local.toUtc());
    });

    test('advances by exactly what it is given', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28, 7, 30));

      clock.advance(const Duration(hours: 9, minutes: 15));
      expect(clock.nowUtc(), DateTime.utc(2026, 8, 28, 16, 45));

      clock.advance(const Duration(milliseconds: 1));
      expect(clock.nowUtc().millisecond, 1);
    });

    test('can be moved backward', () {
      // Not a normal operation, but a test replaying a day out of order needs
      // it, and forbidding it would only push callers to build a new clock.
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28, 12));

      clock.advance(const Duration(hours: -5));
      expect(clock.nowUtc(), DateTime.utc(2026, 8, 28, 7));
    });

    test('jumps to a set instant, in UTC', () {
      final FixedClock clock = FixedClock.epoch();

      clock.instant = DateTime(2026, 8, 28, 7, 30);
      expect(clock.nowUtc().isUtc, isTrue);
      expect(clock.nowUtc(), DateTime(2026, 8, 28, 7, 30).toUtc());
    });

    test('epoch starts at the Unix epoch', () {
      expect(FixedClock.epoch().nowUtc(), DateTime.utc(1970));
      expect(FixedClock.epoch().nowUtc().millisecondsSinceEpoch, 0);
    });
  });

  test('both satisfy the interface', () {
    // So a caller can hold a Clock without knowing which it has.
    final List<Clock> clocks = <Clock>[const SystemClock(), FixedClock.epoch()];
    for (final Clock clock in clocks) {
      expect(clock.nowUtc().isUtc, isTrue);
    }
  });
}

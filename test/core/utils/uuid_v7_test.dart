import 'dart:math';

import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:test/test.dart';

/// Canonical UUID form: 8-4-4-4-12 lowercase hex.
final RegExp _canonical = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

String _hex(String uuid) => uuid.replaceAll('-', '');

/// The 48-bit `unix_ts_ms` field: the first six bytes (RFC 9562 §5.7).
int _timestampMillis(String uuid) =>
    int.parse(_hex(uuid).substring(0, 12), radix: 16);

/// The version nibble: first nibble of byte 6.
int _version(String uuid) => int.parse(_hex(uuid).substring(12, 13), radix: 16);

/// The variant: top bits of byte 8.
int _variantByte(String uuid) =>
    int.parse(_hex(uuid).substring(16, 18), radix: 16);

void main() {
  group('format, per RFC 9562', () {
    test('is canonical 8-4-4-4-12 lowercase hex', () {
      final UuidV7Generator generator = UuidV7Generator();
      for (int i = 0; i < 100; i++) {
        expect(_canonical.hasMatch(generator.next()), isTrue);
      }
    });

    test('the version nibble is 7', () {
      final UuidV7Generator generator = UuidV7Generator();
      for (int i = 0; i < 100; i++) {
        expect(_version(generator.next()), 7);
      }
    });

    test('the variant is 0b10', () {
      // §4.1: the two most significant bits of byte 8 are 1 and 0, so the byte
      // lands in 0x80..0xBF.
      final UuidV7Generator generator = UuidV7Generator();
      for (int i = 0; i < 100; i++) {
        final int byte = _variantByte(generator.next());
        expect(
          byte & 0xC0,
          0x80,
          reason: 'byte 8 was 0x${byte.toRadixString(16)}',
        );
      }
    });
  });

  group('the timestamp comes from the Clock', () {
    test('carries exactly the injected instant', () {
      // The reason Clock is wired in at all: a test can state the millisecond
      // and read it straight back out of the id.
      final DateTime instant = DateTime.utc(2026, 8, 28, 7, 30, 15, 250);
      final UuidV7Generator generator = UuidV7Generator(
        clock: FixedClock(instant),
      );

      expect(
        _timestampMillis(generator.next()),
        instant.millisecondsSinceEpoch,
      );
    });

    test('follows the clock forward', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28, 7));
      final UuidV7Generator generator = UuidV7Generator(clock: clock);

      final int first = _timestampMillis(generator.next());
      clock.advance(const Duration(hours: 9));
      final int second = _timestampMillis(generator.next());

      expect(second - first, const Duration(hours: 9).inMilliseconds);
    });

    test('the system clock stamps roughly now', () {
      final int before = DateTime.now().toUtc().millisecondsSinceEpoch;
      final int stamped = _timestampMillis(UuidV7Generator().next());
      final int after = DateTime.now().toUtc().millisecondsSinceEpoch;

      expect(stamped, greaterThanOrEqualTo(before));
      expect(stamped, lessThanOrEqualTo(after));
    });
  });

  group('ordering', () {
    test('10 000 ids from a frozen clock still sort into creation order', () {
      // The property the uuid package alone does not provide. With a fixed
      // clock every id shares a timestamp, so ordering rests entirely on the
      // counter — and a settlement test that fixes the instant would otherwise
      // get ids in no order whatsoever.
      final UuidV7Generator generator = UuidV7Generator(
        clock: FixedClock(DateTime.utc(2026, 8, 28)),
      );

      final List<String> ids = List<String>.generate(
        10000,
        (_) => generator.next(),
      );

      for (int i = 1; i < ids.length; i++) {
        expect(
          ids[i].compareTo(ids[i - 1]),
          greaterThan(0),
          reason: 'id $i did not sort after id ${i - 1}',
        );
      }
    });

    test('sorting a shuffled batch restores creation order', () {
      final UuidV7Generator generator = UuidV7Generator(
        clock: FixedClock(DateTime.utc(2026, 8, 28)),
      );
      final List<String> created = List<String>.generate(
        500,
        (_) => generator.next(),
      );

      final List<String> shuffled = List<String>.of(created)
        ..shuffle(Random(20260828));
      expect(shuffled, isNot(created));

      expect(shuffled..sort(), created);
    });

    test('a backwards clock never emits a lower id', () {
      // NTP corrections and users changing the device time both happen. Ids
      // are the creation order; a backwards jump must not reorder history.
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28, 12));
      final UuidV7Generator generator = UuidV7Generator(clock: clock);

      final String before = generator.next();
      clock.advance(const Duration(hours: -5));
      final String after = generator.next();

      expect(after.compareTo(before), greaterThan(0));
      expect(
        _timestampMillis(after),
        greaterThanOrEqualTo(_timestampMillis(before)),
      );
    });

    test('counter overflow rolls the stamp forward rather than repeating', () {
      // rand_a is 12 bits, so more than ~4096 ids in one millisecond exhausts
      // it. The stamp advances instead of the order breaking.
      final DateTime instant = DateTime.utc(2026, 8, 28);
      final UuidV7Generator generator = UuidV7Generator(
        clock: FixedClock(instant),
      );

      final List<String> ids = List<String>.generate(
        9000,
        (_) => generator.next(),
      );

      for (int i = 1; i < ids.length; i++) {
        expect(ids[i].compareTo(ids[i - 1]), greaterThan(0), reason: 'at $i');
      }
      expect(
        _timestampMillis(ids.last),
        greaterThan(instant.millisecondsSinceEpoch),
      );
    });
  });

  group('uniqueness', () {
    test('50 000 ids collide zero times', () {
      final UuidV7Generator generator = UuidV7Generator();
      final Set<String> seen = <String>{};
      for (int i = 0; i < 50000; i++) {
        expect(seen.add(generator.next()), isTrue, reason: 'collision at $i');
      }
    });

    test('two generators on the same frozen clock do not collide', () {
      // Stands in for two devices: same wall clock, independent randomness.
      final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 28));
      final UuidV7Generator a = UuidV7Generator(clock: clock);
      final UuidV7Generator b = UuidV7Generator(clock: clock);

      final Set<String> ids = <String>{
        for (int i = 0; i < 1000; i++) ...<String>[a.next(), b.next()],
      };

      expect(ids, hasLength(2000));
    });
  });

  test('a seeded Random makes generation reproducible', () {
    // So a fixture can produce the same ids on every run.
    List<String> run() {
      final UuidV7Generator generator = UuidV7Generator(
        clock: FixedClock(DateTime.utc(2026, 8, 28)),
        random: Random(20260828),
      );
      return List<String>.generate(20, (_) => generator.next());
    }

    expect(run(), run());
  });
}

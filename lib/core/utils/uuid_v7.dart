import 'dart:math';

import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

import '../time/clock.dart';

/// Generates UUIDv7 identifiers: time-ordered, client-side, collision-free.
///
/// Invariant 2. Every primary key in this app is one of these. Auto-increment
/// is impossible for an offline-first app — two devices would both mint id 41 —
/// and a random UUIDv4 would scatter inserts across the whole index, which
/// matters on a phone reading yesterday's orders off a B-tree.
///
/// **Monotonic within a millisecond, which the `uuid` package alone is not.**
/// That package fills `rand_a` with random bytes, so two ids minted in the same
/// millisecond have no defined order — and under a [FixedClock], where *every*
/// id shares one timestamp, they have no order at all. Since fixing the clock
/// is the entire point of injecting one, this generator supplies `rand_a`
/// itself as a counter (RFC 9562 §6.2, "fixed bit-length dedicated counter")
/// and lets the package own the byte layout, version and variant nibbles, and
/// hex formatting — the parts that are easy to get subtly wrong.
///
/// Not thread-safe, and does not need to be: Dart isolates do not share it.
/// One instance per app, held by a provider.
final class UuidV7Generator {
  /// Routed through a private positional constructor so the fields can stay
  /// private: Dart forbids a named parameter called `_clock`, which is what an
  /// initializing formal would require.
  factory UuidV7Generator({
    Clock clock = const SystemClock(),
    Random? random,
  }) => UuidV7Generator._(clock, random ?? Random.secure());

  UuidV7Generator._(this._clock, this._random);

  final Clock _clock;
  final Random _random;

  static const Uuid _uuid = Uuid();

  /// The millisecond the last id was stamped with. Never decreases.
  int _lastMillis = -1;

  /// 12 bits of `rand_a`, incremented for every id sharing [_lastMillis].
  int _counter = 0;

  /// `rand_a` is 12 bits.
  static const int _counterMask = 0xFFF;

  /// A fresh millisecond seeds the counter in its lower half, leaving at least
  /// 2048 increments of headroom before overflow. Seeding at zero would make
  /// consecutive ids guessable; seeding across the full range would overflow
  /// almost immediately on a busy millisecond.
  static const int _counterSeedRange = 0x800;

  /// The next identifier, in canonical lowercase 8-4-4-4-12 form.
  String next() {
    final int now = _clock.nowUtc().millisecondsSinceEpoch;

    if (now > _lastMillis) {
      _lastMillis = now;
      _counter = _random.nextInt(_counterSeedRange);
    } else {
      // Same millisecond — or the device clock went backwards, after an NTP
      // correction or a user changing the time. Either way the stamp must not
      // decrease: ids are the creation order, and a backwards jump would
      // silently reorder history.
      _counter++;
      if (_counter > _counterMask) {
        _lastMillis++;
        _counter = _random.nextInt(_counterSeedRange);
      }
    }

    return _uuid.v7(config: V7Options(_lastMillis, _randomTail()));
  }

  /// The ten bytes the package writes into positions 6..15.
  ///
  /// The first two carry the counter, becoming `rand_a` once the package masks
  /// in the version nibble. The rest are random and become `rand_b`, the top
  /// two bits of which the package overwrites with the variant.
  List<int> _randomTail() => <int>[
    (_counter >> 8) & 0x0F,
    _counter & 0xFF,
    for (int i = 0; i < 8; i++) _random.nextInt(256),
  ];
}

import 'dart:math' as math;

import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:test/test.dart';

const Centimes _c0 = Centimes.zero;

void main() {
  group('construction', () {
    test('wraps a raw centime count', () {
      expect(const Centimes(30000).value, 30000);
      expect(_c0.value, 0);
    });

    test('fromDinars multiplies by 100', () {
      expect(Centimes.fromDinars(300), const Centimes(30000));
      expect(Centimes.fromDinars(0), _c0);
      expect(Centimes.fromDinars(-12), const Centimes(-1200));
    });

    test('reports its sign', () {
      expect(_c0.isZero, isTrue);
      expect(const Centimes(1).isZero, isFalse);
      expect(const Centimes(-1).isZero, isFalse);
      expect(_c0.isPositive, isFalse);
      expect(_c0.isNegative, isFalse);
      expect(const Centimes(1).isPositive, isTrue);
    });

    test('negative amounts are legal', () {
      // settlement_adjustments.amount is signed by design. Non-negativity of a
      // commission is the rule engine's job, not this type's.
      expect(const Centimes(-5000).value, -5000);
      expect(const Centimes(-5000).isNegative, isTrue);
      expect(const Centimes(-5000).isPositive, isFalse);
    });
  });

  group('arithmetic', () {
    test('adds and subtracts', () {
      expect(
        const Centimes(30000) + const Centimes(1250),
        const Centimes(31250),
      );
      expect(
        const Centimes(30000) - const Centimes(1250),
        const Centimes(28750),
      );
      expect(
        const Centimes(1000) - const Centimes(2500),
        const Centimes(-1500),
      );
    });

    test('negates', () {
      expect(-const Centimes(4200), const Centimes(-4200));
      expect(-const Centimes(-4200), const Centimes(4200));
      expect(-_c0, _c0);
    });

    test('takes an absolute value', () {
      expect(const Centimes(-4200).abs(), const Centimes(4200));
      expect(const Centimes(4200).abs(), const Centimes(4200));
      expect(_c0.abs(), _c0);
    });

    test('multiplies by a whole count exactly', () {
      // Five parcels at the same fee. No rounding rule needed: integer
      // multiplication cannot lose a centime.
      expect(const Centimes(25000) * 5, const Centimes(125000));
      expect(const Centimes(25000) * 0, _c0);
      expect(const Centimes(25000) * -2, const Centimes(-50000));
    });

    test('sums an iterable, and an empty one is zero', () {
      expect(
        Centimes.sum(const <Centimes>[
          Centimes(30000),
          Centimes(25000),
          Centimes(-1250),
        ]),
        const Centimes(53750),
      );
      expect(Centimes.sum(const <Centimes>[]), _c0);
    });

    test('addition is associative over a generated batch', () {
      // The settlement invariant depends on this holding for any grouping.
      final math.Random random = math.Random(20260828);
      for (int trial = 0; trial < 200; trial++) {
        final List<Centimes> amounts = List<Centimes>.generate(
          1 + random.nextInt(40),
          (_) => Centimes(random.nextInt(2000000) - 1000000),
        );

        final int split = random.nextInt(amounts.length);
        final Centimes whole = Centimes.sum(amounts);
        final Centimes halves =
            Centimes.sum(amounts.take(split)) +
            Centimes.sum(amounts.skip(split));

        expect(halves, whole);
      }
    });
  });

  group('comparison', () {
    test('orders by value', () {
      expect(const Centimes(100) < const Centimes(200), isTrue);
      expect(const Centimes(200) <= const Centimes(200), isTrue);
      expect(const Centimes(300) > const Centimes(200), isTrue);
      expect(const Centimes(200) >= const Centimes(300), isFalse);
      expect(const Centimes(-100) < _c0, isTrue);
    });

    test('sorts', () {
      final List<Centimes> amounts = <Centimes>[
        const Centimes(300),
        const Centimes(-100),
        _c0,
      ]..sort();

      expect(amounts, const <Centimes>[
        Centimes(-100),
        Centimes(0),
        Centimes(300),
      ]);
    });

    test('equality is by value, and hashes agree', () {
      expect(const Centimes(4200), const Centimes(4200));
      expect(const Centimes(4200), isNot(const Centimes(4201)));
      expect(const Centimes(4200).hashCode, const Centimes(4200).hashCode);

      // Equal amounts collapse in a Set, so Centimes is safe as a map key.
      // Built by insertion rather than as a literal, because a literal with a
      // repeated element is a lint — and here the repetition is the point.
      final Set<Centimes> unique = <Centimes>{};
      unique.add(const Centimes(1));
      unique.add(const Centimes(1));
      expect(unique, hasLength(1));
    });

    test('is never equal to a bare int', () {
      // The reason this is a class and not an extension type: an erased type
      // would let an int through wherever the static type is lost.
      expect(const Centimes(4200), isNot(4200));
      expect(const Centimes(0), isNot(0));
    });
  });

  group('percentage', () {
    test('computes whole percentages', () {
      expect(
        const Centimes(100000).percentage(basisPoints: 1500),
        const Centimes(15000),
      );
      expect(
        const Centimes(100000).percentage(basisPoints: 10000),
        const Centimes(100000),
      );
      expect(const Centimes(100000).percentage(basisPoints: 0), _c0);
    });

    test('handles fractional rates', () {
      // 2.5% of 4 000,00 DA
      expect(
        const Centimes(400000).percentage(basisPoints: 250),
        const Centimes(10000),
      );
    });

    test('rounds half to even, positive', () {
      // 1 centime at 50% is exactly 0.5 -> 0, which is even.
      expect(const Centimes(1).percentage(basisPoints: 5000), _c0);
      // 3 at 50% is exactly 1.5 -> 2, which is even.
      expect(
        const Centimes(3).percentage(basisPoints: 5000),
        const Centimes(2),
      );
      // 5 at 50% is exactly 2.5 -> 2.
      expect(
        const Centimes(5).percentage(basisPoints: 5000),
        const Centimes(2),
      );
      // 7 at 50% is exactly 3.5 -> 4.
      expect(
        const Centimes(7).percentage(basisPoints: 5000),
        const Centimes(4),
      );
    });

    test('rounds half to even, negative — symmetrically', () {
      // Half-up would round -0.5 to -1 and 0.5 to 1, biasing away from zero in
      // both directions. Half-even is symmetric.
      expect(const Centimes(-1).percentage(basisPoints: 5000), _c0);
      expect(
        const Centimes(-3).percentage(basisPoints: 5000),
        const Centimes(-2),
      );
      expect(
        const Centimes(-5).percentage(basisPoints: 5000),
        const Centimes(-2),
      );
      expect(
        const Centimes(-7).percentage(basisPoints: 5000),
        const Centimes(-4),
      );
    });

    test('rounds away from the midpoint normally', () {
      // 0.6 -> 1, not 0.
      expect(
        const Centimes(6).percentage(basisPoints: 1000),
        const Centimes(1),
      );
      // 0.4 -> 0.
      expect(const Centimes(4).percentage(basisPoints: 1000), _c0);
      expect(
        const Centimes(-6).percentage(basisPoints: 1000),
        const Centimes(-1),
      );
    });

    test('is unbiased across many midpoints', () {
      // The whole point of half-even, stated as strongly as it can be: take
      // every odd centime count from 1 to 199 and halve it, so every single
      // case lands exactly on a midpoint.
      int rounded = 0;
      int halfUp = 0;
      for (int odd = 1; odd < 200; odd += 2) {
        rounded += Centimes(odd).percentage(basisPoints: 5000).value;
        halfUp += (odd + 1) ~/ 2;
      }

      // The first 100 odd numbers sum to 100^2, so the exact, unrounded total
      // is 10000 / 2. Half-even reproduces it precisely: the roundings cancel.
      const int exact = 10000 ~/ 2;
      expect(rounded, exact);

      // Half-up rounds every one of the 100 midpoints away from zero and lands
      // 50 centimes high. That drift, on a real batch, is the discrepancy that
      // makes a driver stop trusting the totals.
      expect(halfUp, exact + 50);
    });
  });

  group('allocate', () {
    test('splits evenly when it divides', () {
      expect(const Centimes(30000).allocate(<int>[1, 1, 1]), const <Centimes>[
        Centimes(10000),
        Centimes(10000),
        Centimes(10000),
      ]);
    });

    test('sums exactly when it does not divide', () {
      // The failure this exists to prevent: 33 + 33 + 33 = 99, one centime
      // gone, surfacing later as an unexplained settlement discrepancy.
      final List<Centimes> parts = const Centimes(100).allocate(<int>[1, 1, 1]);

      expect(Centimes.sum(parts), const Centimes(100));
      expect(parts.map((Centimes c) => c.value), <int>[33, 33, 34]);
    });

    test('honours weighting', () {
      final List<Centimes> parts = const Centimes(
        100000,
      ).allocate(<int>[7, 2, 1]);

      expect(parts.map((Centimes c) => c.value), <int>[70000, 20000, 10000]);
      expect(Centimes.sum(parts), const Centimes(100000));
    });

    test('gives a zero ratio nothing, without losing its share', () {
      final List<Centimes> parts = const Centimes(100).allocate(<int>[1, 0, 1]);

      expect(parts[1], _c0);
      expect(Centimes.sum(parts), const Centimes(100));
    });

    test('sums exactly for negative amounts', () {
      final List<Centimes> parts = const Centimes(
        -100,
      ).allocate(<int>[1, 1, 1]);

      expect(Centimes.sum(parts), const Centimes(-100));
    });

    test('sums exactly for any generated split', () {
      // The property that matters, not the particular remainder placement.
      final math.Random random = math.Random(20260828);

      for (int trial = 0; trial < 500; trial++) {
        final Centimes amount = Centimes(random.nextInt(4000000) - 2000000);
        final List<int> ratios = List<int>.generate(
          1 + random.nextInt(8),
          (_) => random.nextInt(10),
        );
        if (ratios.every((int r) => r == 0)) {
          ratios[0] = 1;
        }

        final List<Centimes> parts = amount.allocate(ratios);

        expect(parts, hasLength(ratios.length));
        expect(
          Centimes.sum(parts),
          amount,
          reason: 'allocate($ratios) of $amount did not sum back',
        );
      }
    });

    test('is deterministic', () {
      expect(
        const Centimes(1000).allocate(<int>[3, 5, 7]),
        const Centimes(1000).allocate(<int>[3, 5, 7]),
      );
    });

    test('returns an unmodifiable list', () {
      final List<Centimes> parts = const Centimes(100).allocate(<int>[1, 1]);
      expect(() => parts.add(_c0), throwsUnsupportedError);
    });

    test('rejects ratios it cannot split by', () {
      expect(() => _c0.allocate(<int>[]), throwsArgumentError);
      expect(() => _c0.allocate(<int>[0, 0]), throwsArgumentError);
      expect(() => _c0.allocate(<int>[1, -1]), throwsArgumentError);
    });
  });

  group('overflow throws rather than wrapping', () {
    // Dart wraps silently at 64 bits. For money that is the worst failure
    // available: totals that balance against a number nobody counted.
    final Centimes max = Centimes(Centimes.maxValue);
    final Centimes min = Centimes(Centimes.minValue);

    test('on addition', () {
      expect(
        () => max + const Centimes(1),
        throwsA(isA<CentimesOverflowError>()),
      );
      expect(
        () => min + const Centimes(-1),
        throwsA(isA<CentimesOverflowError>()),
      );
    });

    test('on subtraction', () {
      expect(
        () => min - const Centimes(1),
        throwsA(isA<CentimesOverflowError>()),
      );
      expect(
        () => max - const Centimes(-1),
        throwsA(isA<CentimesOverflowError>()),
      );
    });

    test('on negation of the minimum value', () {
      // There is no positive counterpart to minValue in two's complement.
      expect(() => -min, throwsA(isA<CentimesOverflowError>()));
      expect(() => min.abs(), throwsA(isA<CentimesOverflowError>()));
    });

    test('on multiplication', () {
      expect(() => max * 2, throwsA(isA<CentimesOverflowError>()));
      expect(() => min * 2, throwsA(isA<CentimesOverflowError>()));
      expect(() => min * -1, throwsA(isA<CentimesOverflowError>()));
    });

    test('on fromDinars', () {
      expect(
        () => Centimes.fromDinars(Centimes.maxValue),
        throwsA(isA<CentimesOverflowError>()),
      );
    });

    test('on percentage, before rounding', () {
      // value * basisPoints is the intermediate that overflows, not the result.
      expect(
        () => max.percentage(basisPoints: 10000),
        throwsA(isA<CentimesOverflowError>()),
      );
    });

    test('on allocate', () {
      expect(
        () => max.allocate(<int>[1, 1]),
        throwsA(isA<CentimesOverflowError>()),
      );
    });

    test('but not at the boundary itself', () {
      expect(max + _c0, max);
      expect(min - _c0, min);
      expect(max * 1, max);
    });

    test('names the operation that overflowed', () {
      expect(
        () => max + const Centimes(1),
        throwsA(
          isA<CentimesOverflowError>().having(
            (CentimesOverflowError e) => e.toString(),
            'message',
            contains('+'),
          ),
        ),
      );
    });
  });

  group('the API keeps floating point out', () {
    test('toString is raw centimes, not a formatted amount', () {
      // Deliberately not displayable, so it cannot leak into a screen.
      expect(const Centimes(123456).toString(), 'Centimes(123456)');
      expect(const Centimes(-1).toString(), 'Centimes(-1)');
    });

    test('there is no division operator and no toDouble', () {
      // Enforced by the compiler: uncommenting either line below fails to
      // build. Recorded here so the omission reads as deliberate rather than
      // forgotten.
      //   Centimes(100) / 3;
      //   Centimes(100).toDouble();
      expect(const Centimes(100).value, isA<int>());
    });
  });
}

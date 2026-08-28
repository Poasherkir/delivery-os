/// Thrown when an operation would exceed the range of a 64-bit integer.
///
/// Dart's `int` wraps silently on overflow. For a money type that is the worst
/// possible failure: a settlement would balance against a number that is not
/// the one anybody counted. Every arithmetic path here checks first and throws.
final class CentimesOverflowError extends Error {
  CentimesOverflowError(this.operation);

  final String operation;

  @override
  String toString() => 'CentimesOverflowError: $operation overflowed 64 bits';
}

/// A signed monetary amount, in centimes.
///
/// 100 centimes = 1 dinar. This is the only representation of money in the
/// app (invariant 1): never `double`, never `num`, never decimal strings.
///
/// Four deliberate choices, each of which was tempting to make the other way:
///
/// * **A plain class, not an extension type.** An extension type would avoid
///   the allocation, but it is erased at runtime — `is Centimes` stops working,
///   the Drift converter gets awkward, and a bare `int` slips through anywhere
///   the static type is lost. This app handles hundreds of orders a day, not
///   millions of rows, so runtime type identity is worth more than the
///   allocation.
/// * **No division operator.** There is deliberately no `/` and no `~/`.
///   Silent centime loss is the exact failure this type exists to prevent, and
///   an operator invites it at every call site. Use [percentage] or [allocate],
///   which are explicit about where the remainder goes.
/// * **No `toDouble()`,** not even for tests. If it existed it would get used,
///   and then a `double` is in a money path. Assert on [Centimes] or on
///   [value].
/// * **No formatting.** Rendering an amount needs a locale, digit shapes and a
///   currency suffix, none of which belong in `domain/`. That lives in
///   `core/money/` and is not needed until a screen draws money.
final class Centimes implements Comparable<Centimes> {
  const Centimes(this.value);

  /// Convenience for fixtures and rule specs, where amounts are quoted in whole
  /// dinars. `Centimes.fromDinars(300)` is 30 000 centimes.
  factory Centimes.fromDinars(int dinars) =>
      Centimes(_multiply(dinars, centimesPerDinar, 'fromDinars'));

  static const Centimes zero = Centimes(0);

  static const int centimesPerDinar = 100;

  /// 1 basis point = 0.01%. 15% is 1500; 2.5% is 250.
  static const int basisPointsPerUnit = 10000;

  static const int _maxValue = 9223372036854775807;
  static const int _minValue = -9223372036854775807 - 1;

  /// The amount, in centimes. Signed: [Centimes] permits negatives because
  /// `settlement_adjustments.amount` is signed by design. Non-negativity of a
  /// commission is a rule-engine concern, enforced by its property tests, not
  /// by this type.
  final int value;

  bool get isZero => value == 0;

  bool get isNegative => value < 0;

  bool get isPositive => value > 0;

  Centimes abs() => value < 0 ? Centimes(_negate(value, 'abs')) : this;

  Centimes operator +(Centimes other) =>
      Centimes(_add(value, other.value, '+'));

  Centimes operator -(Centimes other) =>
      Centimes(_subtract(value, other.value, '-'));

  Centimes operator -() => Centimes(_negate(value, 'unary -'));

  /// Scalar multiplication by a count — five parcels at the same fee. Exact:
  /// integer multiplication cannot lose a centime, so this needs no rounding
  /// rule and is safe as an operator.
  Centimes operator *(int factor) => Centimes(_multiply(value, factor, '*'));

  bool operator <(Centimes other) => value < other.value;

  bool operator <=(Centimes other) => value <= other.value;

  bool operator >(Centimes other) => value > other.value;

  bool operator >=(Centimes other) => value >= other.value;

  /// A fraction of this amount, rounded **half to even**, once.
  ///
  /// This is one of only two places in the app where a monetary value is
  /// rounded, and a rule evaluation may reach a rounding step at most once per
  /// order (invariant 1). Every other component is a residual derived by
  /// subtraction.
  ///
  /// Half-even rather than half-up because half-up is biased away from zero:
  /// over a few hundred orders a systematic bias is exactly the drift that
  /// makes a driver stop trusting the totals.
  Centimes percentage({required int basisPoints}) => Centimes(
    _divideRoundHalfEven(
      _multiply(value, basisPoints, 'percentage'),
      basisPointsPerUnit,
    ),
  );

  /// Splits this amount across [ratios] so that the parts sum **exactly** back
  /// to it, with no centime created or lost.
  ///
  /// Naive per-part rounding does not have this property: three ways of 100
  /// centimes gives 33 + 33 + 33 = 99, and the missing centime turns up as an
  /// unexplained discrepancy in a settlement.
  ///
  /// The remainder is distributed deterministically by accumulating floored
  /// cumulative shares, which means later ratios absorb it. Deterministic
  /// matters more than which end receives it: the same inputs must always
  /// produce the same split, on device and on a server.
  ///
  /// Ratios must be non-negative and sum to more than zero. A zero ratio
  /// receives nothing.
  ///
  /// **Order the ratios so the company's bucket is last.** Because the
  /// remainder lands on later ratios, and a sub-dinar remainder has to land
  /// somewhere, it should favour the driver. A driver who comes up short by
  /// centimes notices and stops trusting the app; a company that gains
  /// centimes never complains. This is a convention for callers — the rule
  /// engine in M3 — not something this method can enforce.
  ///
  /// [maxValue] and [minValue] are bounds, never sentinels: nothing in this
  /// codebase uses them to mean "unlimited" or "unset". Absence is `null`.
  List<Centimes> allocate(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios', 'must not be empty');
    }

    int total = 0;
    for (final int ratio in ratios) {
      if (ratio < 0) {
        throw ArgumentError.value(ratios, 'ratios', 'must all be non-negative');
      }
      total = _add(total, ratio, 'allocate');
    }
    if (total == 0) {
      throw ArgumentError.value(ratios, 'ratios', 'must sum to more than zero');
    }

    final List<Centimes> parts = <Centimes>[];
    int running = 0;
    int allocated = 0;

    for (final int ratio in ratios) {
      running += ratio;
      final int cumulative = _divideFloor(
        _multiply(value, running, 'allocate'),
        total,
      );
      parts.add(Centimes(cumulative - allocated));
      allocated = cumulative;
    }

    return List<Centimes>.unmodifiable(parts);
  }

  /// Total of [amounts], zero for an empty iterable.
  static Centimes sum(Iterable<Centimes> amounts) {
    int total = 0;
    for (final Centimes amount in amounts) {
      total = _add(total, amount.value, 'sum');
    }
    return Centimes(total);
  }

  @override
  int compareTo(Centimes other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is Centimes && other.value == value;

  @override
  int get hashCode => value.hashCode;

  /// Developer-facing only. Raw centimes, deliberately not a formatted amount,
  /// so this can never be mistaken for something displayable.
  @override
  String toString() => 'Centimes($value)';

  // --- checked arithmetic ---------------------------------------------------
  //
  // Dart has no checked integer arithmetic and wraps silently at 64 bits.

  static int _add(int a, int b, String operation) {
    final int sum = a + b;
    // Overflow iff the operands share a sign that the result does not.
    if (((a ^ sum) & (b ^ sum)) < 0) {
      throw CentimesOverflowError(operation);
    }
    return sum;
  }

  static int _subtract(int a, int b, String operation) {
    final int difference = a - b;
    if (((a ^ b) & (a ^ difference)) < 0) {
      throw CentimesOverflowError(operation);
    }
    return difference;
  }

  static int _negate(int a, String operation) {
    if (a == _minValue) {
      throw CentimesOverflowError(operation);
    }
    return -a;
  }

  static int _multiply(int a, int b, String operation) {
    if (a == 0 || b == 0) {
      return 0;
    }
    // -1 is special-cased because the division check below cannot distinguish
    // minValue * -1 (which overflows) from a legitimate result.
    if (a == -1) {
      return _negate(b, operation);
    }
    if (b == -1) {
      return _negate(a, operation);
    }

    final int product = a * b;
    if (product ~/ b != a) {
      throw CentimesOverflowError(operation);
    }
    return product;
  }

  /// Integer division rounding half to even. [divisor] must be positive.
  static int _divideRoundHalfEven(int dividend, int divisor) {
    assert(divisor > 0, 'divisor must be positive');

    final int quotient = dividend ~/ divisor;
    final int remainder = dividend.remainder(divisor);
    if (remainder == 0) {
      return quotient;
    }

    final int twiceRemainder = remainder.abs() * 2;
    final int away = dividend.isNegative ? quotient - 1 : quotient + 1;

    if (twiceRemainder > divisor) {
      return away;
    }
    if (twiceRemainder < divisor) {
      return quotient;
    }
    // Exactly half: take whichever neighbour is even.
    return quotient.isEven ? quotient : away;
  }

  /// Integer division rounding toward negative infinity. [divisor] must be
  /// positive. Dart's `~/` truncates toward zero, which would break the
  /// exact-sum property of [allocate] for negative amounts.
  static int _divideFloor(int dividend, int divisor) {
    assert(divisor > 0, 'divisor must be positive');

    final int quotient = dividend ~/ divisor;
    if (dividend.isNegative && dividend.remainder(divisor) != 0) {
      return quotient - 1;
    }
    return quotient;
  }

  static int get maxValue => _maxValue;

  static int get minValue => _minValue;
}

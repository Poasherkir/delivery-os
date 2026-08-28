/// Spacing and sizing tokens, on a 4pt grid with a 2pt hairline step.
///
/// The scale is deliberately dense at the small end: this is a
/// high-information-density logistics interface, and most of the work happens
/// between 8 and 16.
abstract final class SpaceTokens {
  static const double none = 0;

  /// Hairline separation inside a chip or between a label and its value.
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  /// Minimum tap target. Non-negotiable — the driver is holding a parcel.
  static const double minTapTarget = 48;

  /// The primary action on any screen is the largest tappable thing on it, and
  /// it is never smaller than this.
  static const double primaryActionHeight = 56;

  /// Every one of the spacing steps, in order.
  ///
  /// Not test-only: the debug token gallery enumerates these, and a
  /// gallery that lists tokens by hand drifts from the ones that exist.
  static const List<double> scale = <double>[
    none,
    space2,
    space4,
    space8,
    space12,
    space16,
    space20,
    space24,
    space32,
    space40,
    space48,
    space64,
  ];
}

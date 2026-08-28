/// Corner radii. Small throughout — logistics software, not a consumer toy.
abstract final class RadiusTokens {
  static const double none = 0;

  /// Chips, badges, small inputs.
  static const double small = 4;

  /// Cards, rows, buttons.
  static const double medium = 8;

  /// Sheets and modals.
  static const double large = 12;

  /// Fully rounded — status pills only.
  static const double pill = 999;

  /// Every one of the radii, in order.
  ///
  /// Not test-only: the debug token gallery enumerates these, and a
  /// gallery that lists tokens by hand drifts from the ones that exist.
  static const List<double> scale = <double>[none, small, medium, large, pill];
}

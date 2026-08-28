import 'package:flutter/material.dart';

import 'tokens/tokens.dart';

/// Carries the design tokens that [ColorScheme] has no room for — the four
/// status buckets, the money pair, and the elevation scale — through the
/// widget tree.
///
/// [ColorScheme] covers surfaces, text and the accent. Everything else in
/// [ColorTokens] is domain vocabulary Material has no equivalent for, and
/// hanging it off the theme is what lets a widget read it without importing
/// the light or dark instance directly and losing the ability to switch.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({required this.colors});

  final ColorTokens colors;

  @override
  AppTokens copyWith({ColorTokens? colors}) =>
      AppTokens(colors: colors ?? this.colors);

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    // Deliberately not interpolated. Cross-fading 28 semantic colours during a
    // theme switch produces momentary combinations that were never contrast
    // checked, and the switch is not something the driver watches.
    if (other == null) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

extension AppTokensX on BuildContext {
  /// The semantic colours for the active theme.
  ///
  /// Falls back to the brightness-matched instance when the extension is
  /// absent, so a widget still renders correctly under a bare `MaterialApp`
  /// in a test rather than throwing.
  ColorTokens get colors =>
      Theme.of(this).extension<AppTokens>()?.colors ??
      (Theme.of(this).brightness == Brightness.dark
          ? ColorTokens.dark
          : ColorTokens.light);
}

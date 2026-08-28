import 'package:flutter/animation.dart';

/// Motion tokens. Short, functional, never decorative.
///
/// Durations are capped because animation on a mid-range phone costs frames the
/// driver notices, and because nothing in this app benefits from being watched.
abstract final class MotionTokens {
  /// No animation. State changes the driver triggers should feel instant.
  static const Duration instant = Duration.zero;

  /// Pressed states, checkbox and chip toggles.
  static const Duration fast = Duration(milliseconds: 120);

  /// Sheets, expansion, the default.
  static const Duration base = Duration(milliseconds: 180);

  /// Full-screen transitions. The ceiling.
  static const Duration slow = Duration(milliseconds: 260);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve entering = Curves.easeOut;
  static const Curve exiting = Curves.easeIn;

  /// Every one of the durations, in order.
  ///
  /// Not test-only: the debug token gallery enumerates these, and a
  /// gallery that lists tokens by hand drifts from the ones that exist.
  static const List<Duration> scale = <Duration>[instant, fast, base, slow];
}

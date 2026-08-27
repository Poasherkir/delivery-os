import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Elevation expressed as **borders and separators**, not shadows.
///
/// Density in this interface comes from rules and spacing. Shadow opacity stays
/// at or below 0.10 at every level and is zero for the two levels that carry
/// almost all of the UI; the tokens exist so that depth is a deliberate,
/// bounded choice rather than an ad-hoc `BoxShadow` somebody pastes in.
///
/// Colour is not part of an elevation: the border and shadow colours come from
/// [ColorTokens], so one definition serves both themes.
@immutable
class ElevationToken {
  const ElevationToken({
    required this.name,
    required this.borderWidth,
    required this.offsetY,
    required this.blur,
    required this.opacity,
  });

  final String name;
  final double borderWidth;
  final double offsetY;
  final double blur;
  final double opacity;

  /// Shadows for this level in [color]. Empty when the level is border-only,
  /// which is the common case.
  List<BoxShadow> shadows(Color color) => opacity == 0
      ? const <BoxShadow>[]
      : <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: opacity),
            offset: Offset(0, offsetY),
            blurRadius: blur,
          ),
        ];
}

abstract final class ElevationTokens {
  /// Content sitting directly on its surface. Most of the app.
  static const ElevationToken flat = ElevationToken(
    name: 'flat',
    borderWidth: 0,
    offsetY: 0,
    blur: 0,
    opacity: 0,
  );

  /// Cards and list rows. A 1px rule and nothing else.
  static const ElevationToken resting = ElevationToken(
    name: 'resting',
    borderWidth: 1,
    offsetY: 0,
    blur: 0,
    opacity: 0,
  );

  /// Sticky headers and the next-stop card, where a hairline is not enough to
  /// separate scrolling content passing underneath.
  static const ElevationToken raised = ElevationToken(
    name: 'raised',
    borderWidth: 1,
    offsetY: 1,
    blur: 2,
    opacity: 0.04,
  );

  /// Modals and bottom sheets. The only level with a visible shadow.
  static const ElevationToken overlay = ElevationToken(
    name: 'overlay',
    borderWidth: 1,
    offsetY: 4,
    blur: 12,
    opacity: 0.10,
  );

  /// Upper bound on shadow opacity, asserted in the token tests so "just a
  /// slightly stronger shadow" cannot drift in one commit at a time.
  static const double maxOpacity = 0.10;

  @visibleForTesting
  static const List<ElevationToken> scale = <ElevationToken>[
    flat,
    resting,
    raised,
    overlay,
  ];
}

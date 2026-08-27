import 'package:flutter/painting.dart';

/// Typography tokens.
///
/// IBM Plex Sans with IBM Plex Sans Arabic as the fallback: one superfamily, so
/// AR and FR share a design. Both faces are bundled (see `pubspec.yaml`);
/// nothing is fetched at runtime.
///
/// Two properties of these faces were measured, not assumed, and both shape
/// what follows (`test/core/theme/font_metrics_test.dart`):
///
/// 1. **Digits are already tabular.** Every digit is 600/1000 em in every
///    weight of both faces, and comma and period match across the pair. Neither
///    face ships a `tnum` feature, so [FontFeature.tabularFigures] would be a
///    no-op — it is deliberately absent here rather than cargo-culted in.
///
/// 2. **The faces disagree on vertical metrics.** Arabic line boxes come out
///    ~2px taller at every size, and `TextStyle.height` alone does not fix it.
///    Every style must be painted with its [strutFor] strut, which forces the
///    line box and makes AR and FR identical. A `Text` without that strut will
///    shift the layout on locale switch.
abstract final class TypeTokens {
  static const String family = 'IBMPlexSans';
  static const List<String> fallback = <String>['IBMPlexSansArabic'];

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;

  /// Below this size a regular weight goes muddy outdoors; use [medium] or
  /// heavier. Asserted in the token tests.
  static const double minSizeForRegularWeight = 14;

  static TextStyle _style(double size, double height, FontWeight weight) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        height: height,
        fontWeight: weight,
        leadingDistribution: TextLeadingDistribution.even,
      );

  // ---- Prose scale -------------------------------------------------------
  static final TextStyle display = _style(32, 1.20, semiBold);
  static final TextStyle headline = _style(24, 1.25, semiBold);
  static final TextStyle title = _style(20, 1.30, semiBold);
  static final TextStyle subtitle = _style(17, 1.35, medium);
  static final TextStyle body = _style(16, 1.45, regular);
  static final TextStyle bodySmall = _style(14, 1.45, regular);
  static final TextStyle label = _style(13, 1.35, medium);
  static final TextStyle caption = _style(12, 1.35, medium);

  // ---- Money -------------------------------------------------------------
  // A separate ramp because dinar amounts are read in columns, not in prose.
  // Tabular alignment comes from the face itself, not from a font feature.
  static final TextStyle moneyLarge = _style(28, 1.20, semiBold);
  static final TextStyle moneyMedium = _style(20, 1.25, semiBold);
  static final TextStyle moneyBody = _style(16, 1.35, medium);
  static final TextStyle moneySmall = _style(14, 1.35, medium);

  /// The forced strut for [style]. Every dinar amount and every localized
  /// string should be painted with this, or AR and FR line boxes diverge.
  static StrutStyle strutFor(TextStyle style) => StrutStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: style.fontSize,
    height: style.height,
    forceStrutHeight: true,
  );

  /// Prose scale, largest first. Used by the token gallery and the tests.
  static Map<String, TextStyle> get prose => <String, TextStyle>{
    'display': display,
    'headline': headline,
    'title': title,
    'subtitle': subtitle,
    'body': body,
    'bodySmall': bodySmall,
    'label': label,
    'caption': caption,
  };

  /// Money scale, largest first.
  static Map<String, TextStyle> get money => <String, TextStyle>{
    'moneyLarge': moneyLarge,
    'moneyMedium': moneyMedium,
    'moneyBody': moneyBody,
    'moneySmall': moneySmall,
  };

  static Map<String, TextStyle> get all => <String, TextStyle>{
    ...prose,
    ...money,
  };
}

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

  /// Absolute floor. Nothing that carries information renders below this — an
  /// outdoor, one-handed app does not get to solve density problems with small
  /// type. Decoration may go smaller; content may not.
  static const double minInformationalSize = 12;

  /// Captions and metadata stop here, a step above the absolute floor.
  static const double captionFloor = 13;

  /// Multiplier applied to every size when the active locale is Arabic.
  ///
  /// Arabic set at the same nominal size reads smaller than Latin, and this
  /// app's primary audience reads Arabic in direct sunlight. **This is a hook,
  /// not a measurement.** It is deliberately 1.0 — the value comes from
  /// looking at a real device outdoors, not from a specimen on a monitor.
  /// Changing this one number rescales the whole Arabic UI, strut included.
  static const double arabicSizeMultiplier = 1.0;

  /// The size multiplier for [locale]'s script. 1.0 for anything non-Arabic,
  /// including a null locale (widget tests without a `Localizations` ancestor).
  static double scriptMultiplierFor(Locale? locale) =>
      locale?.languageCode == 'ar' ? arabicSizeMultiplier : 1.0;

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
  static final TextStyle bodySmall = _style(15, 1.45, regular);
  static final TextStyle label = _style(14, 1.35, medium);
  static final TextStyle caption = _style(13, 1.35, medium);

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
    for (final AppTextStyle s in AppTextStyle.values)
      if (!s.isMoney) s.name: s.style,
  };

  /// Money scale, largest first.
  static Map<String, TextStyle> get money => <String, TextStyle>{
    for (final AppTextStyle s in AppTextStyle.values)
      if (s.isMoney) s.name: s.style,
  };

  static Map<String, TextStyle> get all => <String, TextStyle>{
    for (final AppTextStyle s in AppTextStyle.values) s.name: s.style,
  };
}

/// The sanctioned text styles, in scale order.
///
/// This enum — not a bare [TextStyle] — is what `AppText` accepts, so a call
/// site cannot invent a size, and every string is painted with the strut that
/// keeps AR and FR line boxes identical.
enum AppTextStyle {
  display,
  headline,
  title,
  subtitle,
  body,
  bodySmall,
  label,
  caption,
  moneyLarge,
  moneyMedium,
  moneyBody,
  moneySmall;

  /// Whether this step belongs to the money ramp, which is read in columns
  /// rather than in prose.
  bool get isMoney => name.startsWith('money');

  TextStyle get style => switch (this) {
    AppTextStyle.display => TypeTokens.display,
    AppTextStyle.headline => TypeTokens.headline,
    AppTextStyle.title => TypeTokens.title,
    AppTextStyle.subtitle => TypeTokens.subtitle,
    AppTextStyle.body => TypeTokens.body,
    AppTextStyle.bodySmall => TypeTokens.bodySmall,
    AppTextStyle.label => TypeTokens.label,
    AppTextStyle.caption => TypeTokens.caption,
    AppTextStyle.moneyLarge => TypeTokens.moneyLarge,
    AppTextStyle.moneyMedium => TypeTokens.moneyMedium,
    AppTextStyle.moneyBody => TypeTokens.moneyBody,
    AppTextStyle.moneySmall => TypeTokens.moneySmall,
  };

  /// The forced strut for this step. Never paint one without the other.
  StrutStyle get strut => TypeTokens.strutFor(style);
}

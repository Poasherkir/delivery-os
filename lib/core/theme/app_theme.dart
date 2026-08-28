import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'tokens/tokens.dart';

/// Light and dark themes, built only from the tokens in `tokens/`.
///
/// No colour, size, radius or duration is written here — every value is a
/// token reference, so the palette has exactly one definition. The one
/// exception is [Colors.transparent], used to switch off Material 3's
/// elevation tint: depth in this app is carried by borders, and a tint would
/// fight them.
abstract final class AppTheme {
  static ThemeData light() => _build(ColorTokens.light, Brightness.light);

  static ThemeData dark() => _build(ColorTokens.dark, Brightness.dark);

  static ThemeData _build(ColorTokens c, Brightness brightness) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.accentSubtle,
      onPrimaryContainer: c.accent,
      // There is no second accent. Mapping secondary and tertiary onto
      // neutrals means a component that reaches for them cannot smuggle a
      // competing hue into the interface.
      secondary: c.borderStrong,
      onSecondary: c.textInverse,
      secondaryContainer: c.surfaceSunken,
      onSecondaryContainer: c.textPrimary,
      tertiary: c.borderStrong,
      onTertiary: c.textInverse,
      tertiaryContainer: c.surfaceSunken,
      onTertiaryContainer: c.textPrimary,
      error: c.statusProblemFg,
      onError: c.textInverse,
      errorContainer: c.statusProblemBg,
      onErrorContainer: c.statusProblemFg,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerLowest: c.surfaceSunken,
      surfaceContainerLow: c.canvas,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceRaised,
      onSurfaceVariant: c.textSecondary,
      outline: c.borderStrong,
      outlineVariant: c.border,
      scrim: c.scrim,
      shadow: c.textPrimary,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.surface,
      inversePrimary: c.accentSubtle,
      surfaceTint: Colors.transparent,
    );

    final TextTheme text = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.canvas,
      textTheme: text,
      fontFamily: TypeTokens.family,
      fontFamilyFallback: TypeTokens.fallback,
      // Standard, never compact: density is bought with spacing and rules, not
      // by shrinking targets below 48dp for a one-handed user holding a parcel.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[AppTokens(colors: c)],

      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),

      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        shape: Border(bottom: BorderSide(color: c.border)),
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: c.border,
            width: ElevationTokens.resting.borderWidth,
          ),
          borderRadius: BorderRadius.circular(RadiusTokens.medium),
        ),
      ),

      // The next action is the largest tappable thing on screen.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.surfaceSunken,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size.fromHeight(SpaceTokens.primaryActionHeight),
          padding: const EdgeInsets.symmetric(horizontal: SpaceTokens.space20),
          textStyle: TypeTokens.subtitle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.medium),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size.fromHeight(SpaceTokens.minTapTarget),
          side: BorderSide(color: c.borderStrong),
          textStyle: TypeTokens.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.medium),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          minimumSize: const Size(
            SpaceTokens.minTapTarget,
            SpaceTokens.minTapTarget,
          ),
          textStyle: TypeTokens.label,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TypeTokens.body.copyWith(color: c.textDisabled),
        labelStyle: TypeTokens.label.copyWith(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpaceTokens.space12,
          vertical: SpaceTokens.space12,
        ),
        border: _inputBorder(c.borderStrong),
        enabledBorder: _inputBorder(c.borderStrong),
        focusedBorder: _inputBorder(c.focus, width: 2),
        errorBorder: _inputBorder(c.statusProblemFg),
        focusedErrorBorder: _inputBorder(c.statusProblemFg, width: 2),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.statusNeutralBg,
        side: BorderSide.none,
        labelStyle: TypeTokens.label,
        padding: const EdgeInsets.symmetric(
          horizontal: SpaceTokens.space8,
          vertical: SpaceTokens.space4,
        ),
        shape: const StadiumBorder(),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: c.surface,
        iconColor: c.textSecondary,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        minVerticalPadding: SpaceTokens.space12,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpaceTokens.space16,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSubtle,
        elevation: 0,
        height: SpaceTokens.space64,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          TypeTokens.caption.copyWith(color: c.textSecondary),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.large),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(RadiusTokens.large),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: TypeTokens.body.copyWith(color: c.surface),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceSunken,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
        borderRadius: BorderRadius.circular(RadiusTokens.medium),
      );

  static TextTheme _textTheme(ColorTokens c) {
    TextStyle on(TextStyle style, Color color) => style.copyWith(color: color);

    return TextTheme(
      displayLarge: on(TypeTokens.display, c.textPrimary),
      displayMedium: on(TypeTokens.headline, c.textPrimary),
      displaySmall: on(TypeTokens.title, c.textPrimary),
      headlineLarge: on(TypeTokens.headline, c.textPrimary),
      headlineMedium: on(TypeTokens.title, c.textPrimary),
      headlineSmall: on(TypeTokens.subtitle, c.textPrimary),
      titleLarge: on(TypeTokens.title, c.textPrimary),
      titleMedium: on(TypeTokens.subtitle, c.textPrimary),
      titleSmall: on(TypeTokens.label, c.textPrimary),
      bodyLarge: on(TypeTokens.body, c.textPrimary),
      bodyMedium: on(TypeTokens.bodySmall, c.textPrimary),
      bodySmall: on(TypeTokens.caption, c.textSecondary),
      labelLarge: on(TypeTokens.label, c.textPrimary),
      labelMedium: on(TypeTokens.label, c.textSecondary),
      labelSmall: on(TypeTokens.caption, c.textSecondary),
    );
  }
}

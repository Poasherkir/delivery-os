import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/core/theme/app_tokens.dart';
import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, (ThemeData, ColorTokens)> themes =
      <String, (ThemeData, ColorTokens)>{
        'light': (AppTheme.light(), ColorTokens.light),
        'dark': (AppTheme.dark(), ColorTokens.dark),
      };

  themes.forEach((String name, (ThemeData, ColorTokens) pair) {
    final (ThemeData theme, ColorTokens tokens) = pair;

    group(name, () {
      test('carries its tokens as a theme extension', () {
        expect(theme.extension<AppTokens>()?.colors, same(tokens));
      });

      test('surfaces come from tokens', () {
        expect(theme.scaffoldBackgroundColor, tokens.canvas);
        expect(theme.colorScheme.surface, tokens.surface);
        expect(theme.colorScheme.primary, tokens.accent);
        expect(theme.colorScheme.onPrimary, tokens.onAccent);
        expect(theme.colorScheme.error, tokens.statusProblemFg);
        expect(theme.colorScheme.outline, tokens.borderStrong);
        expect(theme.colorScheme.outlineVariant, tokens.border);
      });

      test('every ColorScheme role is a token, not a literal', () {
        // Mechanical check that the theme adds no colour of its own.
        // Colors.transparent is the sanctioned exception: it switches off
        // Material 3's elevation tint, which would fight the borders.
        final ColorScheme s = theme.colorScheme;
        final Set<Color> allowed = <Color>{
          ...tokens.all.values,
          Colors.transparent,
        };

        final Map<String, Color> roles = <String, Color>{
          'primary': s.primary,
          'onPrimary': s.onPrimary,
          'primaryContainer': s.primaryContainer,
          'onPrimaryContainer': s.onPrimaryContainer,
          'secondary': s.secondary,
          'onSecondary': s.onSecondary,
          'secondaryContainer': s.secondaryContainer,
          'onSecondaryContainer': s.onSecondaryContainer,
          'tertiary': s.tertiary,
          'onTertiary': s.onTertiary,
          'tertiaryContainer': s.tertiaryContainer,
          'onTertiaryContainer': s.onTertiaryContainer,
          'error': s.error,
          'onError': s.onError,
          'errorContainer': s.errorContainer,
          'onErrorContainer': s.onErrorContainer,
          'surface': s.surface,
          'onSurface': s.onSurface,
          'onSurfaceVariant': s.onSurfaceVariant,
          'surfaceContainerLowest': s.surfaceContainerLowest,
          'surfaceContainerLow': s.surfaceContainerLow,
          'surfaceContainer': s.surfaceContainer,
          'surfaceContainerHigh': s.surfaceContainerHigh,
          'surfaceContainerHighest': s.surfaceContainerHighest,
          'outline': s.outline,
          'outlineVariant': s.outlineVariant,
          'scrim': s.scrim,
          'shadow': s.shadow,
          'inverseSurface': s.inverseSurface,
          'onInverseSurface': s.onInverseSurface,
          'inversePrimary': s.inversePrimary,
          'surfaceTint': s.surfaceTint,
        };

        roles.forEach((String role, Color color) {
          expect(
            allowed,
            contains(color),
            reason: 'ColorScheme.$role in $name is not a token',
          );
        });
      });

      test('the accent never leaks into a secondary role', () {
        // One accent. If secondary or tertiary ever equals it, a component
        // reaching for them starts competing with the primary action.
        expect(theme.colorScheme.secondary, isNot(tokens.accent));
        expect(theme.colorScheme.tertiary, isNot(tokens.accent));
      });

      test('depth is borders, not shadows', () {
        expect(theme.cardTheme.elevation, 0);
        expect(theme.appBarTheme.elevation, 0);
        expect(theme.appBarTheme.scrolledUnderElevation, 0);
        expect(theme.dialogTheme.elevation, 0);
        expect(theme.bottomSheetTheme.elevation, 0);
        expect(theme.navigationBarTheme.elevation, 0);
        // Material 3 tints elevated surfaces by default; that is a shadow by
        // another name and it fights the border language.
        expect(theme.colorScheme.surfaceTint, Colors.transparent);
        expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
      });

      test('tap targets are never shrunk below 48dp', () {
        expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
        expect(theme.visualDensity, VisualDensity.standard);
      });

      test('the primary action is the largest thing offered', () {
        final Size? filled = theme.filledButtonTheme.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final Size? outlined = theme.outlinedButtonTheme.style?.minimumSize
            ?.resolve(<WidgetState>{});

        expect(filled?.height, SpaceTokens.primaryActionHeight);
        expect(outlined?.height, SpaceTokens.minTapTarget);
        expect(filled!.height, greaterThan(outlined!.height));
      });

      test('every text theme style keeps an explicit height', () {
        // Inherited from the tokens; a copyWith that dropped it would
        // reintroduce the AR/FR line box divergence.
        final List<TextStyle?> styles = <TextStyle?>[
          theme.textTheme.displayLarge,
          theme.textTheme.headlineLarge,
          theme.textTheme.titleLarge,
          theme.textTheme.bodyLarge,
          theme.textTheme.bodyMedium,
          theme.textTheme.bodySmall,
          theme.textTheme.labelLarge,
          theme.textTheme.labelSmall,
        ];
        for (final TextStyle? style in styles) {
          expect(style?.height, isNotNull);
          expect(style?.fontSize, isNotNull);
        }
      });

      test('the Arabic fallback is configured app-wide', () {
        expect(theme.textTheme.bodyLarge?.fontFamily, TypeTokens.family);
        expect(
          theme.textTheme.bodyLarge?.fontFamilyFallback,
          contains('IBMPlexSansArabic'),
        );
      });
    });
  });

  testWidgets('context.colors resolves the active theme', (
    WidgetTester tester,
  ) async {
    late ColorTokens seen;

    // pumpAndSettle, not pump: MaterialApp animates theme changes, and the
    // AppTokens lerp deliberately snaps at t=0.5, so reading mid-transition
    // still returns the outgoing theme.
    Future<void> pump(ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (BuildContext context) {
              seen = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump(AppTheme.light());
    expect(seen, same(ColorTokens.light));

    await pump(AppTheme.dark());
    expect(seen, same(ColorTokens.dark));
  });

  testWidgets('context.colors falls back without the extension', (
    WidgetTester tester,
  ) async {
    // A bare MaterialApp in a widget test must still render, not throw.
    late ColorTokens seen;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(
          builder: (BuildContext context) {
            seen = context.colors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seen, same(ColorTokens.dark));
  });
}

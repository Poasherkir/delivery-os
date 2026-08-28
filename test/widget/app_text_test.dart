import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:delivery_os/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fonts.dart';

Future<Text> _pumpText(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: Scaffold(body: child),
    ),
  );
  // MaterialApp animates theme changes between successive pumps in one test.
  await tester.pumpAndSettle();
  return tester.widget<Text>(find.byType(Text));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('always applies the forced strut', (WidgetTester tester) async {
    // The whole reason this widget exists. Without the strut, AR and FR line
    // boxes differ and the layout shifts on locale switch.
    for (final AppTextStyle style in AppTextStyle.values) {
      final Text rendered = await _pumpText(
        tester,
        AppText('Bab Ezzouar', style),
      );

      expect(rendered.strutStyle?.forceStrutHeight, isTrue, reason: style.name);
      expect(rendered.strutStyle?.fontSize, style.style.fontSize);
      expect(rendered.strutStyle?.height, style.style.height);
    }
  });

  testWidgets('renders at the token size and weight', (
    WidgetTester tester,
  ) async {
    for (final AppTextStyle style in AppTextStyle.values) {
      final Text rendered = await _pumpText(tester, AppText('3 400,00', style));

      expect(
        rendered.style?.fontSize,
        style.style.fontSize,
        reason: style.name,
      );
      expect(
        rendered.style?.fontWeight,
        style.style.fontWeight,
        reason: style.name,
      );
    }
  });

  testWidgets('defaults to the theme primary text colour', (
    WidgetTester tester,
  ) async {
    final Text light = await _pumpText(
      tester,
      const AppText('x', AppTextStyle.body),
    );
    expect(light.style?.color, ColorTokens.light.textPrimary);

    final Text dark = await _pumpText(
      tester,
      const AppText('x', AppTextStyle.body),
      theme: AppTheme.dark(),
    );
    expect(dark.style?.color, ColorTokens.dark.textPrimary);
  });

  testWidgets('an explicit colour wins', (WidgetTester tester) async {
    final Text rendered = await _pumpText(
      tester,
      AppText(
        '1 250,00 DA',
        AppTextStyle.moneyBody,
        color: ColorTokens.light.moneyEarningFg,
      ),
    );
    expect(rendered.style?.color, ColorTokens.light.moneyEarningFg);
  });

  testWidgets('AR and FR line boxes stay in the ratio the multiplier sets', (
    WidgetTester tester,
  ) async {
    // With the Arabic multiplier at 1.0 this asserts they are identical.
    // Written as a ratio rather than as equality so that raising the
    // multiplier after a device check is a deliberate change, not a red test.
    for (final AppTextStyle style in AppTextStyle.values) {
      final double fr = await _heightIn(
        tester,
        AppLocales.french,
        'Livraison a Bab Ezzouar',
        style,
      );
      final double ar = await _heightIn(
        tester,
        AppLocales.arabic,
        'توصيل إلى باب الزوار',
        style,
      );

      expect(
        ar,
        closeTo(fr * TypeTokens.arabicSizeMultiplier, 1.0),
        reason: '${style.name} is out of ratio between AR and FR',
      );
    }
  });

  testWidgets('the Arabic script multiplier reaches size and strut alike', (
    WidgetTester tester,
  ) async {
    for (final AppTextStyle style in AppTextStyle.values) {
      await _pumpLocalized(
        tester,
        AppLocales.arabic,
        AppText('باب الزوار', style),
      );
      final Text rendered = tester.widget<Text>(find.byType(Text));

      final double expected =
          style.style.fontSize! * TypeTokens.arabicSizeMultiplier;

      expect(rendered.style?.fontSize, closeTo(expected, 0.001));
      // The strut must scale with it, or taller glyphs clip against a line box
      // sized for the unscaled text.
      expect(rendered.strutStyle?.fontSize, closeTo(expected, 0.001));
      expect(rendered.strutStyle?.forceStrutHeight, isTrue);
    }
  });

  testWidgets('French is never rescaled', (WidgetTester tester) async {
    await _pumpLocalized(
      tester,
      AppLocales.french,
      const AppText('Bab Ezzouar', AppTextStyle.body),
    );

    expect(
      tester.widget<Text>(find.byType(Text)).style?.fontSize,
      TypeTokens.body.fontSize,
    );
  });
}

Future<void> _pumpLocalized(
  WidgetTester tester,
  Locale locale,
  Widget child,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: AppL10n.localizationsDelegates,
      theme: AppTheme.light(),
      home: Scaffold(
        body: Align(alignment: AlignmentDirectional.topStart, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<double> _heightIn(
  WidgetTester tester,
  Locale locale,
  String text,
  AppTextStyle style,
) async {
  await _pumpLocalized(tester, locale, AppText(text, style));
  return tester.getSize(find.byType(Text)).height;
}

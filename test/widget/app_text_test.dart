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

  testWidgets('AR and FR occupy the same height at every style', (
    WidgetTester tester,
  ) async {
    for (final AppTextStyle style in AppTextStyle.values) {
      final List<double> heights = <double>[];

      for (final (TextDirection direction, String text)
          in <(TextDirection, String)>[
            (TextDirection.ltr, 'Livraison a Bab Ezzouar'),
            (TextDirection.rtl, 'توصيل إلى باب الزوار'),
          ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: AppText(text, style),
                ),
              ),
            ),
          ),
        );
        heights.add(tester.getSize(find.byType(Text)).height);
      }

      expect(
        heights[1],
        closeTo(heights[0], 0.01),
        reason: '${style.name} renders taller in AR than in FR',
      );
    }
  });
}

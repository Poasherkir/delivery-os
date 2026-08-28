import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:delivery_os/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fonts.dart';

const Key _markerKey = Key('directional-marker');

/// A deliberately asymmetric layout: directional padding on the start edge and
/// start-aligned content. Under RTL both must move to the right-hand side.
Widget _asymmetric() => const Padding(
  padding: EdgeInsetsDirectional.only(start: SpaceTokens.space48),
  child: Align(
    alignment: AlignmentDirectional.centerStart,
    child: SizedBox(
      key: _markerKey,
      width: SpaceTokens.space48,
      height: SpaceTokens.space48,
    ),
  ),
);

Future<void> _pump(WidgetTester tester, Locale locale, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: AppL10n.localizationsDelegates,
        localeListResolutionCallback:
            (List<Locale>? device, Iterable<Locale> supported) =>
                AppLocales.resolve(device, override: locale),
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Arabic resolves to RTL and French to LTR', (
    WidgetTester tester,
  ) async {
    for (final (Locale locale, TextDirection expected)
        in <(Locale, TextDirection)>[
          (AppLocales.arabic, TextDirection.rtl),
          (AppLocales.french, TextDirection.ltr),
        ]) {
      late TextDirection actual;
      late Locale resolved;

      await _pump(
        tester,
        locale,
        Builder(
          builder: (BuildContext context) {
            actual = Directionality.of(context);
            resolved = Localizations.localeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(actual, expected, reason: locale.languageCode);
      expect(resolved, locale);
    }
  });

  testWidgets('a directional layout mirrors between AR and FR', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AppLocales.french, _asymmetric());
    final Rect ltr = tester.getRect(find.byKey(_markerKey));

    await _pump(tester, AppLocales.arabic, _asymmetric());
    final Rect rtl = tester.getRect(find.byKey(_markerKey));

    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    // Left-hand side under FR, right-hand side under AR.
    expect(ltr.left, lessThan(screenWidth / 2));
    expect(rtl.left, greaterThan(screenWidth / 2));

    // And an exact mirror: the gap from the start edge is identical, measured
    // from opposite sides. A layout built with EdgeInsets instead of
    // EdgeInsetsDirectional would fail this.
    expect(
      screenWidth - rtl.right,
      closeTo(ltr.left, 0.01),
      reason: 'the start-edge inset did not mirror',
    );
    expect(rtl.width, ltr.width);
  });

  testWidgets('text aligns to the start edge in both directions', (
    WidgetTester tester,
  ) async {
    const String key = 'aligned-text';

    Future<Rect> rectFor(Locale locale, String sample) async {
      await _pump(
        tester,
        locale,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppText(sample, AppTextStyle.body, key: const Key(key)),
        ),
      );
      return tester.getRect(find.byKey(const Key(key)));
    }

    final Rect fr = await rectFor(AppLocales.french, 'Bab Ezzouar');
    final Rect ar = await rectFor(AppLocales.arabic, 'باب الزوار');

    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(fr.left, closeTo(0, 0.01));
    expect(ar.right, closeTo(screenWidth, 0.01));
  });

  testWidgets('the app title comes from the ARB bundle in both locales', (
    WidgetTester tester,
  ) async {
    for (final Locale locale in AppLocales.supported) {
      late String title;

      await _pump(
        tester,
        locale,
        Builder(
          builder: (BuildContext context) {
            title = AppL10n.of(context).appTitle;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(title, isNotEmpty, reason: locale.languageCode);
    }
  });
}

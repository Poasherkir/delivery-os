import 'package:delivery_os/app/app.dart';
import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/app/routes.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/features/companies/presentation/companies_screen.dart';
import 'package:delivery_os/features/customers/presentation/customers_screen.dart';
import 'package:delivery_os/features/history/presentation/history_screen.dart';
import 'package:delivery_os/features/home/presentation/home_screen.dart';
import 'package:delivery_os/features/money/presentation/money_screen.dart';
import 'package:delivery_os/features/more/presentation/more_screen.dart';
import 'package:delivery_os/features/orders/presentation/orders_screen.dart';
import 'package:delivery_os/features/route/presentation/route_screen.dart';
import 'package:delivery_os/features/settings/presentation/settings_screen.dart';
import 'package:delivery_os/shared/widgets/app_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_fonts.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Locale? locale,
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    if (locale != null) LocaleController.storageKey: locale.languageCode,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const DeliveryOsApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Re-pumping [DeliveryOsApp] does **not** reset go_router's navigation stack,
/// even under a fresh [ProviderScope] with a fresh router. Every test that
/// needs a known starting route therefore pumps exactly once; anything looping
/// over locales or entries is split into separate tests rather than re-pumped.
Future<void> _openMore(WidgetTester tester) async {
  await tester.tap(find.byIcon(AppDestination.more.icon));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('the five destinations', () {
    test('there are exactly five, and no more', () {
      // CLAUDE.md: "Five bottom-nav destinations. Not six." Past five the
      // targets drop below 40dp and this user is tapping one-handed while
      // holding a parcel. Adding a sixth should require arguing for it, not
      // just a diff that slips through review.
      expect(AppDestination.values, hasLength(5));
    });

    test('paths are unique and rooted', () {
      final Set<String> paths = <String>{
        for (final AppDestination d in AppDestination.values) d.path,
        for (final MoreEntry e in MoreEntry.values) e.path,
      };

      expect(paths, hasLength(9));
      for (final String path in paths) {
        expect(path, startsWith('/'));
      }
    });

    test('the selected glyph differs from the unselected one', () {
      // Colour is never the only signal for the selected tab.
      for (final AppDestination d in AppDestination.values) {
        if (d != AppDestination.more) {
          expect(d.active, isNot(d.icon), reason: d.name);
        }
      }
    });
  });

  testWidgets('opens on Home', (WidgetTester tester) async {
    await _pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('each destination reaches its screen', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    for (final (AppDestination destination, Type screen)
        in <(AppDestination, Type)>[
          (AppDestination.orders, OrdersScreen),
          (AppDestination.route, RouteScreen),
          (AppDestination.money, MoneyScreen),
          (AppDestination.more, MoreScreen),
          (AppDestination.home, HomeScreen),
        ]) {
      await tester.tap(find.byIcon(destination.icon));
      await tester.pumpAndSettle();

      expect(find.byType(screen), findsOneWidget, reason: destination.name);
    }
  });

  for (final Locale locale in AppLocales.supported) {
    testWidgets('the app bar title is localized in ${locale.languageCode}', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, locale: locale);

      final AppL10n l10n = AppL10n.of(tester.element(find.byType(HomeScreen)));

      // Opens on Home, titled in the active language.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.navHome),
        ),
        findsOneWidget,
      );

      await _openMore(tester);

      // And follows the destination.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.navMore),
        ),
        findsOneWidget,
      );
    });
  }

  group('More', () {
    testWidgets('lists its four entries, plus the debug gallery', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _openMore(tester);

      // The token gallery is appended in debug builds only, and tests run in
      // debug. Stated as a sum rather than a magic 5, so the release-build
      // shape stays visible in the assertion.
      expect(
        find.byType(ListTile),
        findsNWidgets(MoreEntry.values.length + (kDebugMode ? 1 : 0)),
      );
      expect(find.byKey(const Key('more.devGallery')), findsOneWidget);
    });

    // One test per entry rather than a loop: re-pumping DeliveryOsApp inside a
    // single test does not reset the router's navigation stack, so the second
    // iteration would start from wherever the first one ended.
    for (final (MoreEntry entry, Type screen) in <(MoreEntry, Type)>[
      (MoreEntry.customers, CustomersScreen),
      (MoreEntry.companies, CompaniesScreen),
      (MoreEntry.history, HistoryScreen),
      (MoreEntry.settings, SettingsScreen),
    ]) {
      testWidgets('${entry.name} pushes above the shell, hiding the bar', (
        WidgetTester tester,
      ) async {
        await _pumpApp(tester);
        await _openMore(tester);

        await tester.tap(find.byKey(ValueKey<MoreEntry>(entry)));
        await tester.pumpAndSettle();

        expect(find.byType(screen), findsOneWidget);
        // The point of pushing on the root navigator: More is a plain list,
        // not a sixth tab with its own stack.
        expect(
          find.byType(NavigationBar),
          findsNothing,
          reason: '${entry.name} kept the bottom bar',
        );
      });
    }

    testWidgets('back returns to the shell', (WidgetTester tester) async {
      await _pumpApp(tester);
      await _openMore(tester);
      await tester.tap(
        find.byKey(const ValueKey<MoreEntry>(MoreEntry.history)),
      );
      await tester.pumpAndSettle();

      // The Material back button the AppBar implies, not pageBack(), which
      // hunts for a Cupertino one.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(MoreScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('layout holds up', () {
    testWidgets('nav targets stay at or above 48dp on a narrow screen', (
      WidgetTester tester,
    ) async {
      // A 2GB budget Android phone is 320dp wide in the worst case.
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pumpApp(tester);

      final Size bar = tester.getSize(find.byType(NavigationBar));
      expect(
        bar.width / AppDestination.values.length,
        greaterThanOrEqualTo(48),
      );
      expect(bar.height, greaterThanOrEqualTo(48));
    });

    for (final double scale in <double>[1.0, 1.3]) {
      for (final Locale locale in AppLocales.supported) {
        testWidgets(
          'renders without overflow at ${scale}x in ${locale.languageCode}',
          (WidgetTester tester) async {
            // "Text scale to 1.3x must not break any layout." Drivers run
            // large system fonts more often than you would expect.
            await _pumpApp(tester, locale: locale, textScale: scale);

            expect(tester.takeException(), isNull);

            await tester.tap(find.byIcon(AppDestination.more.icon));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  testWidgets('every navigation label goes through AppText or the theme', (
    WidgetTester tester,
  ) async {
    // The shell title is an AppText; NavigationDestination takes a raw String
    // and builds its own Text, which is why the guard test allows lib/app but
    // this checks the title specifically.
    await _pumpApp(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.byType(AppText)),
      findsOneWidget,
    );
  });
}

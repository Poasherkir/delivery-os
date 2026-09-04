import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_fonts.dart';

/// The language picker: the only place in a shipped build where a driver can
/// choose. Until this screen existed the sole switch was the token gallery,
/// which is behind `kDebugMode`.
void main() {
  setUpAll(loadAppFonts);

  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
  });

  Future<void> pump(WidgetTester tester, {required Locale locale}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          // No database in this test. `userSettingsProvider` is null until one
          // opens, which is a state the app genuinely runs in, and the
          // controller is required to keep working — a driver who cannot open
          // their data still has to be able to read the screen telling them so.
          userSettingsProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the three languages and the automatic option', () {
    testWidgets('are all offered, each named in its own language', (
      WidgetTester tester,
    ) async {
      // Endonyms, not translations. This is the one screen a driver reaches
      // when the app is in a language they cannot read.
      await pump(tester, locale: AppLocales.french);

      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Automatique'), findsOneWidget);
    });

    testWidgets('and the endonyms do not change with the locale', (
      WidgetTester tester,
    ) async {
      // The whole point: in Arabic, "English" still reads English. Only the
      // automatic option translates, because it names a behaviour rather than
      // a language.
      await pump(tester, locale: AppLocales.arabic);

      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('تلقائي'), findsOneWidget);
      expect(find.text('Automatique'), findsNothing);
    });

    testWidgets('and every shipped locale has a row', (
      WidgetTester tester,
    ) async {
      // Derived from the shipped set rather than counted by hand, so a fourth
      // locale added without a row here fails.
      await pump(tester, locale: AppLocales.french);

      for (final Locale option in AppLocales.supported) {
        expect(
          find.byKey(Key('settings.language.${option.languageCode}')),
          findsOneWidget,
          reason: '${option.languageCode} is shipped but not offered',
        );
      }
    });
  });

  group('choosing', () {
    testWidgets('starts on automatic, which is a choice not an absence', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(_isSelected(tester, 'settings.language.system'), isTrue);
      expect(_isSelected(tester, 'settings.language.ar'), isFalse);
    });

    testWidgets('a language applies in one tap, with no save button', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('settings.language.en')));
      await tester.pumpAndSettle();

      expect(_isSelected(tester, 'settings.language.en'), isTrue);
      expect(_isSelected(tester, 'settings.language.system'), isFalse);
    });

    testWidgets('and it persists, so the next launch honours it', (
      WidgetTester tester,
    ) async {
      // The controller writes through to preferences; the database mirror is
      // the other half and has its own tests.
      await pump(tester, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('settings.language.ar')));
      await tester.pumpAndSettle();

      expect(preferences.getString(LocaleController.storageKey), 'ar');
    });

    testWidgets('and going back to automatic clears the stored choice', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);
      await tester.tap(find.byKey(const Key('settings.language.ar')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings.language.system')));
      await tester.pumpAndSettle();

      expect(
        preferences.getString(LocaleController.storageKey),
        isNull,
        reason:
            'following the device is stored as the absence of a preference, '
            'not as a resolved language — the distinction the nullable column '
            'exists for',
      );
    });
  });

  testWidgets('every row clears the minimum tap target', (
    WidgetTester tester,
  ) async {
    // The driver is one-handed, and this list is read in whatever language
    // they cannot currently read.
    await pump(tester, locale: AppLocales.french);

    final Iterable<Element> rows = tester.elementList(find.byType(ListTile));
    expect(rows, isNotEmpty, reason: 'nothing was measured');
    for (final Element row in rows) {
      expect(row.size!.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('and Arabic renders right to left', (WidgetTester tester) async {
    await pump(tester, locale: AppLocales.arabic);

    expect(
      Directionality.of(
        tester.element(find.byKey(const Key('settings.language.ar'))),
      ),
      TextDirection.rtl,
    );
  });
}

bool _isSelected(WidgetTester tester, String key) => tester
    .widget<ListTile>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(ListTile),
      ),
    )
    .selected;

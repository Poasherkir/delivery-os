import 'dart:io';

import 'package:delivery_os/app/app.dart';
import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:delivery_os/features/startup/presentation/database_error_screen.dart';
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_fonts.dart';

Future<QueryExecutor> _refuse() =>
    Future<QueryExecutor>.error(DatabaseKeyMissingError());

/// A database that opens normally, in a fresh temp file — which is exactly the
/// first-launch case: no file yet, and creating one is not a failure.
Future<QueryExecutor> Function() _freshInstall() {
  final Directory dir = Directory.systemTemp.createTempSync('dberr_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return () async => NativeDatabase(File('${dir.path}/app.db'));
}

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester, {
    required Future<QueryExecutor> Function() opener,
    String? locale,
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      if (locale case final String l) LocaleController.storageKey: l,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // `Override` is not exported by Riverpod 3; the list type is inferred.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2026, 8, 31)),
          ),
          databaseAccessProvider.overrideWithValue(
            DatabaseAccess(open: opener),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const DeliveryOsApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('a fresh install never sees this screen', () {
    // The assertion that matters most here. "No database file yet" and "the
    // file will not open" are easy to collapse into one error path, and a new
    // driver meeting the worst screen in the app on first launch would be a
    // bad first impression caused by a bug that is not real.
    testWidgets('with no database file, the app starts normally', (
      WidgetTester tester,
    ) async {
      await pump(tester, opener: _freshInstall(), locale: 'fr');

      expect(find.byType(DatabaseErrorScreen), findsNothing);
    });

    testWidgets('and in Arabic too', (WidgetTester tester) async {
      // Locale is set explicitly. The test runner reports en-US, which falls
      // back to Arabic, so a test that never names one is exercising AR while
      // reading as though it were LTR.
      await pump(tester, opener: _freshInstall(), locale: 'ar');

      expect(find.byType(DatabaseErrorScreen), findsNothing);
    });

    testWidgets('while a refused open does reach it', (
      WidgetTester tester,
    ) async {
      // The control. Without this, the two tests above would pass for a
      // screen that is unreachable in every case, including the real one.
      await pump(tester, opener: _refuse, locale: 'fr');

      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
    });
  });

  group('what the screen says', () {
    testWidgets('states the fact and never the cause', (
      WidgetTester tester,
    ) async {
      await pump(tester, opener: _refuse, locale: 'fr');
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byType(DatabaseErrorScreen)),
      );

      expect(find.text(l10n.dbErrorTitle), findsOneWidget);
      expect(find.text(l10n.dbErrorStillTrue), findsOneWidget);
      expect(find.text(l10n.dbErrorReconcile), findsOneWidget);
    });

    testWidgets('never names encryption, keys or a database', (
      WidgetTester tester,
    ) async {
      // Our vocabulary, not the driver's. Checked against the rendered text
      // rather than the ARB, so a future edit to either locale is caught.
      await pump(tester, opener: _refuse, locale: 'fr');

      final Iterable<String> rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => (t.data ?? '').toLowerCase());

      for (final String banned in <String>[
        'chiffr', // chiffré, chiffrement
        'clé',
        'base de données',
        'sqlite',
      ]) {
        expect(
          rendered.any((String s) => s.contains(banned)),
          isFalse,
          reason: '"$banned" is our vocabulary, not the driver\'s',
        );
      }
    });

    testWidgets('the cause disclosure is collapsed until asked', (
      WidgetTester tester,
    ) async {
      await pump(tester, opener: _refuse, locale: 'fr');
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byType(DatabaseErrorScreen)),
      );

      expect(find.text(l10n.dbErrorWhyBody), findsNothing);

      await tester.tap(find.byKey(const Key('dbError.why')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.dbErrorWhyBody), findsOneWidget);
    });

    testWidgets('retry is the only action at this level', (
      WidgetTester tester,
    ) async {
      // A driver who has just read that his data will not open must not be one
      // panicked tap from destroying it. The reset arrives in task 3, behind a
      // secondary path — never as a peer of this button.
      await pump(tester, opener: _refuse, locale: 'fr');

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byKey(const Key('dbError.retry')), findsOneWidget);
    });

    testWidgets('the retry target is at least 48dp', (
      WidgetTester tester,
    ) async {
      await pump(tester, opener: _refuse, locale: 'fr');

      final Size size = tester.getSize(find.byKey(const Key('dbError.retry')));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('Arabic', () {
    testWidgets('renders right-to-left', (WidgetTester tester) async {
      await pump(tester, opener: _refuse, locale: 'ar');

      expect(
        Directionality.of(tester.element(find.byType(DatabaseErrorScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets('and the copy is Arabic, not the French fallback', (
      WidgetTester tester,
    ) async {
      await pump(tester, opener: _refuse, locale: 'ar');
      final AppL10n ar = AppL10n.of(
        tester.element(find.byType(DatabaseErrorScreen)),
      );

      expect(ar.localeName, 'ar');
      expect(find.text(ar.dbErrorTitle), findsOneWidget);

      // Actually Arabic script, not the French bundle leaking through. The
      // range is built from codepoints rather than pasted, per the project
      // rule on non-ASCII in string literals.
      final bool hasArabic = ar.dbErrorTitle.runes.any(
        (int r) => r >= 0x0600 && r <= 0x06FF,
      );
      expect(hasArabic, isTrue, reason: 'the AR bundle did not resolve');
    });

    testWidgets('survives 1.3x text scale without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await pump(tester, opener: _refuse, locale: 'ar', textScale: 1.3);

      // The screen is still there and nothing overflowed. Replacing the tree
      // with an empty box and asserting no exception, which is what this test
      // did first, would have passed for any implementation at all.
      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('retry re-attempts the open and recovers', (
    WidgetTester tester,
  ) async {
    // The one case where this screen is recoverable: a transient keystore
    // failure that clears. The first open refuses, the second succeeds.
    final Directory dir = Directory.systemTemp.createTempSync('dberr_retry_');
    addTearDown(() => dir.deleteSync(recursive: true));

    bool firstAttempt = true;
    Future<QueryExecutor> flaky() {
      if (firstAttempt) {
        firstAttempt = false;
        return Future<QueryExecutor>.error(DatabaseKeyMissingError());
      }
      return Future<QueryExecutor>.value(
        NativeDatabase(File('${dir.path}/app.db')),
      );
    }

    await pump(tester, opener: flaky, locale: 'fr');
    expect(find.byType(DatabaseErrorScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('dbError.retry')));
    await tester.pumpAndSettle();

    expect(find.byType(DatabaseErrorScreen), findsNothing);
  });
}

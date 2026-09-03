import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/features/ingestion/presentation/scanner_screen.dart';
import 'package:delivery_os/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../support/app_fonts.dart';

/// The scanner, with no camera.
///
/// A widget test has no camera and cannot get one. `MobileScanner` responds to
/// that by rendering its *placeholder*, not by calling `errorBuilder` — the
/// platform channel never answers, so nothing ever errors.
///
/// That matters, because the first version of this file pumped the whole screen
/// and asserted the unavailable-camera copy contained no blame. It passed
/// against copy that was never on screen: a check against an empty subject set.
/// [CameraUnavailable] is therefore pumped directly, which is also the only way
/// to reach the permission-denied branch at all.
///
/// What no widget test can reach: an actual decode, the torch doing anything,
/// and whether the preview is the right way up. Those need the device run.
void main() {
  setUpAll(loadAppFonts);

  /// Every test names its locale. The runner reports `en-US`, which correctly
  /// falls back to Arabic — so a silent test exercises RTL while reading as if
  /// it were LTR.
  Future<void> pump(WidgetTester tester, {required Locale locale}) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        supportedLocales: AppLocales.supported,
        localizationsDelegates: AppL10n.localizationsDelegates,
        home: const ScannerScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('manual entry', () {
    testWidgets('is offered even when the camera never starts', (
      WidgetTester tester,
    ) async {
      // The property the whole screen is arranged around. A damaged or missing
      // label is ordinary rather than exceptional, and a scanner the driver
      // cannot escape is worse than no scanner.
      await pump(tester, locale: AppLocales.french);

      expect(find.byKey(const Key('scanner.manualEntry')), findsOneWidget);
      expect(find.text('Saisir à la main'), findsOneWidget);
    });

    testWidgets('meets the tap target minimum', (WidgetTester tester) async {
      await pump(tester, locale: AppLocales.french);

      final Size size = tester.getSize(
        find.byKey(const Key('scanner.manualEntry')),
      );
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('pops with null rather than a value', (
      WidgetTester tester,
    ) async {
      // The caller distinguishes "scanned this" from "chose to type it", and
      // popping an empty string would collapse the two.
      Object? result = 'not popped';

      await tester.pumpWidget(
        MaterialApp(
          locale: AppLocales.french,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<String>(
                  MaterialPageRoute<String>(
                    builder: (BuildContext c) => const ScannerScreen(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scanner.manualEntry')));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('the camera-unavailable state', () {
    Future<void> pumpUnavailable(
      WidgetTester tester, {
      required MobileScannerErrorCode code,
      Locale locale = AppLocales.french,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: Scaffold(
            body: CameraUnavailable(
              error: MobileScannerException(errorCode: code),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a refused permission offers manual entry first', (
      WidgetTester tester,
    ) async {
      // Manual entry before settings, deliberately. A driver who declined at
      // 07:00 in an agency needs to enter the order now, not navigate Android
      // settings — and the entry form works without a scan.
      await pumpUnavailable(
        tester,
        code: MobileScannerErrorCode.permissionDenied,
      );

      expect(find.text('Appareil photo non autorisé'), findsOneWidget);

      final String body = tester
          .widgetList<AppText>(find.byType(AppText))
          .map((AppText t) => t.data)
          .firstWhere((String d) => d.contains('saisir'));
      expect(
        body.indexOf('la main'),
        lessThan(body.indexOf('réglages')),
        reason: 'settings is offered before manual entry',
      );
    });

    testWidgets('any other failure does not guess the cause', (
      WidgetTester tester,
    ) async {
      // Hardware in use, a device fault, something unnamed. The driver's next
      // step is the same whatever it was, and a wrong explanation sends them
      // off to fix something that is not broken.
      await pumpUnavailable(tester, code: MobileScannerErrorCode.genericError);

      expect(find.text('Appareil photo indisponible'), findsOneWidget);
      expect(find.textContaining('réglages'), findsNothing);
    });

    testWidgets('neither state blames the driver', (WidgetTester tester) async {
      // A refused permission is a reasonable thing to have done, and a broken
      // camera is nobody's fault.
      for (final MobileScannerErrorCode code in <MobileScannerErrorCode>[
        MobileScannerErrorCode.permissionDenied,
        MobileScannerErrorCode.genericError,
      ]) {
        await pumpUnavailable(tester, code: code);

        // The subject set is non-empty by construction: the copy is on screen,
        // which is what the earlier version of this test failed to ensure.
        expect(find.byType(AppText), findsWidgets);

        for (final String forbidden in <String>[
          'erreur',
          'Erreur',
          'échec',
          'invalide',
        ]) {
          expect(
            find.textContaining(forbidden),
            findsNothing,
            reason: '"$forbidden" reads as blame where nobody erred',
          );
        }
      }
    });

    testWidgets('renders in Arabic too', (WidgetTester tester) async {
      await pumpUnavailable(
        tester,
        code: MobileScannerErrorCode.permissionDenied,
        locale: AppLocales.arabic,
      );

      expect(find.text('الكاميرا غير مسموح بها'), findsOneWidget);
    });
  });

  group('chrome', () {
    testWidgets('has a torch control', (WidgetTester tester) async {
      // A stairwell at 07:00 is dark, and the label is on the parcel in the
      // driver's other hand.
      await pump(tester, locale: AppLocales.french);

      expect(find.byKey(const Key('scanner.torch')), findsOneWidget);
    });

    testWidgets('renders right-to-left in Arabic', (WidgetTester tester) async {
      await pump(tester, locale: AppLocales.arabic);

      expect(find.text('مسح الطرد'), findsOneWidget);
      expect(find.text('إدخال يدوي'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('إدخال يدوي'))),
        TextDirection.rtl,
      );
    });
  });
}

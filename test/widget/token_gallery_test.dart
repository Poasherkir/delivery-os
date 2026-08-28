import 'package:delivery_os/app/app.dart';
import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/app/routes.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:delivery_os/features/_dev/presentation/token_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_fonts.dart';

/// Opens the app on the gallery, through the real router and the real More
/// list, so the debug entry point is exercised rather than the screen being
/// pumped in isolation.
Future<ProviderContainer> _openGallery(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final ProviderContainer container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const DeliveryOsApp(),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(AppDestination.more.icon));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('more.devGallery')));
  await tester.pumpAndSettle();

  return container;
}

/// Taps the segment labelled [label].
///
/// Not `widgetWithText`: that returns the whole SegmentedButton, and tapping it
/// hits the control's centre — the middle segment — rather than the one named.
Future<void> _tapSegment(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Scrolls the gallery until [finder] is on screen, failing if it never is.
/// Only searches forwards, so callers must assert in gallery order.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  // The scrollable must be named: the control rows scroll horizontally, so
  // scrollUntilVisible would otherwise find several and refuse to choose.
  await tester.scrollUntilVisible(
    finder,
    300,
    maxScrolls: 200,
    // `.first` is the ListView's own Scrollable; the control rows scroll
    // horizontally and are descendants of it, so the finder matches several.
    scrollable: find
        .descendant(
          of: find.byKey(const Key('dev.gallery.list')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  expect(finder, findsOneWidget);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('is reachable from More in a debug build', (
    WidgetTester tester,
  ) async {
    await _openGallery(tester);
    expect(find.byType(TokenGalleryScreen), findsOneWidget);
  });

  testWidgets('renders every token', (WidgetTester tester) async {
    // A gallery that silently stops listing a token is worse than no gallery:
    // it looks like coverage. Section headings carry the counts, so they fail
    // when a token is added without the gallery noticing.
    //
    // Asserted in gallery order, because a ListView does not build what is off
    // screen and scrollUntilVisible only searches forwards.
    await _openGallery(tester);

    await _scrollTo(
      tester,
      find.textContaining('${ColorTokens.light.all.length} tokens'),
    );
    await _scrollTo(
      tester,
      find.textContaining('${AppTextStyle.values.length} steps'),
    );

    for (final ElevationToken token in ElevationTokens.scale) {
      await _scrollTo(tester, find.textContaining('${token.name} · border'));
    }

    // Confidence tiers are the ones with no colour of their own, so they are
    // the easiest to forget.
    for (final ConfidenceTreatment tier in ConfidenceTokens.byTier) {
      await _scrollTo(tester, find.textContaining('tier ${tier.tier}'));
    }
  });

  testWidgets('the locale toggle drives the real controller', (
    WidgetTester tester,
  ) async {
    // The M0 gate item. Not a local preview toggle — tapping AR here is what a
    // driver switching language would do.
    final ProviderContainer container = await _openGallery(tester);

    expect(container.read(localeControllerProvider), isNull);

    await _tapSegment(tester, 'AR');
    await tester.pumpAndSettle();

    expect(container.read(localeControllerProvider), AppLocales.arabic);
    expect(
      Directionality.of(tester.element(find.byType(TokenGalleryScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('switching between FR and AR mirrors the proof block', (
    WidgetTester tester,
  ) async {
    await _openGallery(tester);

    Rect proofRect() =>
        tester.getRect(find.byKey(const Key('dev.rtlProof.bar')));

    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    // French explicitly: the test device reports en-US, which correctly falls
    // back to Arabic, so the app is already RTL on open. Taking LTR for
    // granted here would have compared RTL against RTL.
    await _tapSegment(tester, 'FR');
    await tester.pumpAndSettle();
    final Rect ltr = proofRect();

    await _tapSegment(tester, 'AR');
    await tester.pumpAndSettle();

    final Rect rtl = proofRect();

    // Same width, opposite side: the 48dp start inset moved from the left edge
    // to the right one, so the bar's gap from each edge swaps.
    expect(rtl.width, closeTo(ltr.width, 0.01));
    expect(
      screenWidth - rtl.right,
      closeTo(ltr.left, 0.01),
      reason: 'the start inset did not mirror',
    );
  });

  testWidgets('the theme toggle is local and does not leak', (
    WidgetTester tester,
  ) async {
    await _openGallery(tester);

    await _tapSegment(tester, 'Dark');
    await tester.pumpAndSettle();

    // Read from the Scaffold, which sits *below* the Theme the gallery
    // installs. Reading at TokenGalleryScreen would see the app theme above it.
    expect(
      Theme.of(
        tester.element(
          find.descendant(
            of: find.byType(TokenGalleryScreen),
            matching: find.byType(Scaffold),
          ),
        ),
      ).brightness,
      Brightness.dark,
    );
    // Nothing was persisted: a global theme control belongs to Settings in M5.
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
  });

  testWidgets('survives 1.3x text scale without overflow', (
    WidgetTester tester,
  ) async {
    await _openGallery(tester);

    await _tapSegment(tester, '1.3x');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Scroll the whole gallery, since an overflow only throws when the
    // offending row is actually laid out.
    await tester.drag(
      find.byKey(const Key('dev.gallery.list')),
      const Offset(0, -4000),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

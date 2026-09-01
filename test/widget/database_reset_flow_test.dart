import 'dart:io';

import 'package:delivery_os/app/app.dart';
import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:delivery_os/features/startup/controllers/reset_controller.dart';
import 'package:delivery_os/features/startup/presentation/database_error_screen.dart';
import 'package:delivery_os/features/startup/presentation/database_reset_screen.dart';
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_fonts.dart';

Future<QueryExecutor> _refuse() =>
    Future<QueryExecutor>.error(DatabaseKeyMissingError());

void main() {
  setUpAll(loadAppFonts);

  late int resetCalls;

  /// Pumps the app in its failed-startup state, which is the only way into the
  /// reset flow.
  ///
  /// [resetFails] makes the reset itself throw — the second-worst moment in the
  /// app, and the one with no path through it before this task.
  /// [resetRecovers] makes startup succeed *after* a reset, so the done screen
  /// can hand back to a working app.
  Future<void> pump(
    WidgetTester tester, {
    bool resetFails = false,
    bool resetRecovers = false,
    String locale = 'fr',
  }) async {
    resetCalls = 0;
    SharedPreferences.setMockInitialValues(<String, Object>{
      LocaleController.storageKey: locale,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Directory dir = Directory.systemTemp.createTempSync('resetflow_');
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Disposable.
      }
    });

    bool didReset = false;

    // `Override` is not exported by Riverpod 3; the list type is inferred.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(FixedClock(DateTime.utc(2026, 9))),
          databaseAccessProvider.overrideWithValue(
            DatabaseAccess(
              open: () => didReset && resetRecovers
                  ? Future<QueryExecutor>.value(
                      NativeDatabase(File('${dir.path}/app.db')),
                    )
                  : _refuse(),
              reset: () async {
                resetCalls++;
                if (resetFails) {
                  throw const FileSystemException('locked');
                }
                didReset = true;
              },
            ),
          ),
        ],
        child: const DeliveryOsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Walks from the failure screen to the hold screen.
  Future<void> openHoldScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('dbError.otherOptions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset.continue')));
    await tester.pumpAndSettle();
  }

  group('reaching the reset', () {
    testWidgets('is two screens and a hold away from the failure screen', (
      WidgetTester tester,
    ) async {
      await pump(tester);

      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
      expect(find.byType(DatabaseResetScreen), findsNothing);

      await tester.tap(find.byKey(const Key('dbError.otherOptions')));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseResetScreen), findsOneWidget);

      // Step one offers no way to destroy anything.
      expect(find.byKey(const Key('reset.hold')), findsNothing);
    });

    testWidgets('cancelling lands on the failure screen, not a blank route', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('dbError.otherOptions')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset.cancel')));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
    });

    testWidgets('and cancelling from the hold screen does too', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await openHoldScreen(tester);

      await tester.tap(find.byKey(const Key('reset.holdCancel')));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseResetScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('reset.cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
    });
  });

  group('the hold', () {
    testWidgets('does nothing until the full duration elapses', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(milliseconds: 2900));

      expect(resetCalls, 0, reason: 'the reset fired before the hold finished');

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('lifting early cancels with no partial effect', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(resetCalls, 0);
      // Still on the hold screen, nothing destroyed, no error shown.
      expect(find.byType(DatabaseResetHoldScreen), findsOneWidget);
    });

    testWidgets('a pointer already down when the screen appears is ignored', (
      WidgetTester tester,
    ) async {
      // Step one ends with a tap on "Continuer" and this screen appears under
      // that same finger. A driver who taps without lifting cleanly must not
      // start the countdown without ever choosing to.
      await pump(tester);
      await tester.tap(find.byKey(const Key('dbError.otherOptions')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset.continue')));
      await tester.pumpAndSettle();

      // Checked before anything else, so a timer that armed itself reports as
      // that rather than as "the hold screen vanished". Verified by planting
      // `_progress.forward()` in initState, which is the actual bug this
      // guards: the hold must be armed by a PointerDownEvent this screen saw
      // arrive, never by the screen appearing.
      expect(resetCalls, 0, reason: 'the hold armed itself without a press');
      expect(find.byType(DatabaseResetHoldScreen), findsOneWidget);

      // And it stays unarmed with no fresh press, past the hold duration.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(
        resetCalls,
        0,
        reason: 'a press the hold control never saw begin started the timer',
      );
    });

    testWidgets('a completed hold runs the reset exactly once', (
      WidgetTester tester,
    ) async {
      await pump(tester, resetRecovers: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(resetCalls, 1);
    });
  });

  group('after a successful reset', () {
    testWidgets('the confirmation screen is not back-navigable', (
      WidgetTester tester,
    ) async {
      // Those screens describe a decision already made. Returning to them would
      // offer to destroy data that no longer exists, on a database that is now
      // fine.
      await pump(tester, resetRecovers: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseResetDoneScreen), findsOneWidget);

      // The system back gesture has nothing to pop to.
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator).last,
      );
      expect(
        navigator.canPop(),
        isFalse,
        reason: 'the reset flow is still on the stack behind the confirmation',
      );
    });

    testWidgets('and the driver can start a working app', (
      WidgetTester tester,
    ) async {
      await pump(tester, resetRecovers: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset.done')));
      await tester.pumpAndSettle();

      // Out of the failure branch entirely.
      expect(find.byType(DatabaseResetDoneScreen), findsNothing);
      expect(find.byType(DatabaseErrorScreen), findsNothing);
      expect(
        find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
            find.byType(NavigationBar).evaluate().isNotEmpty,
        isTrue,
        reason: 'the normal app shell should be showing',
      );
    });
  });

  group('when the reset itself fails', () {
    testWidgets('the driver returns to the failure screen', (
      WidgetTester tester,
    ) async {
      await pump(tester, resetFails: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseErrorScreen), findsOneWidget);
      expect(find.byType(DatabaseResetScreen), findsNothing);
      expect(find.byType(DatabaseResetHoldScreen), findsNothing);
    });

    testWidgets('with one added line, not a new error screen', (
      WidgetTester tester,
    ) async {
      await pump(tester, resetFails: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      final AppL10n l10n = AppL10n.of(
        tester.element(find.byType(DatabaseErrorScreen)),
      );
      expect(find.text(l10n.dbErrorResetFailed), findsOneWidget);
      // The original screen is intact underneath it.
      expect(find.text(l10n.dbErrorTitle), findsOneWidget);
      expect(find.text(l10n.dbErrorStillTrue), findsOneWidget);
    });

    testWidgets('and it does not retry by itself', (WidgetTester tester) async {
      // Two failures in a row is a situation for the driver to decide about,
      // not for the app to keep hammering at.
      await pump(tester, resetFails: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(resetCalls, 1, reason: 'the app retried on its own');
    });

    testWidgets('the stale line clears when he tries again', (
      WidgetTester tester,
    ) async {
      await pump(tester, resetFails: true);
      await openHoldScreen(tester);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('reset.hold'))),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      final AppL10n l10n = AppL10n.of(
        tester.element(find.byType(DatabaseErrorScreen)),
      );
      expect(find.text(l10n.dbErrorResetFailed), findsOneWidget);

      await tester.tap(find.byKey(const Key('dbError.otherOptions')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset.cancel')));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.dbErrorResetFailed),
        findsNothing,
        reason: 'the line outlived the attempt it described',
      );
    });
  });

  testWidgets('a second trigger while the reset runs does nothing', (
    WidgetTester tester,
  ) async {
    // Between the hold completing and the new database being ready there is
    // real work. A double tap, a stray gesture or a rebuild in that window must
    // not start a second delete against a database the first is still using.
    await pump(tester, resetRecovers: true);
    await openHoldScreen(tester);

    final Element element = tester.element(
      find.byType(DatabaseResetHoldScreen),
    );
    final ResetController controller = ProviderScope.containerOf(
      element,
    ).read(resetControllerProvider.notifier);

    // Two overlapping calls, as a double-fire would produce.
    final Future<bool> first = controller.run();
    final Future<bool> second = controller.run();

    expect(await second, isFalse, reason: 're-entry was not blocked');
    expect(await first, isTrue);
    expect(resetCalls, 1);

    await tester.pumpAndSettle();
  });

  testWidgets('the flow renders right-to-left in Arabic', (
    WidgetTester tester,
  ) async {
    await pump(tester, locale: 'ar');
    await tester.tap(find.byKey(const Key('dbError.otherOptions')));
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(DatabaseResetScreen))),
      TextDirection.rtl,
    );

    final AppL10n ar = AppL10n.of(
      tester.element(find.byType(DatabaseResetScreen)),
    );
    expect(find.text(ar.resetTitle), findsOneWidget);
    expect(find.text(ar.resetLosesMoney), findsOneWidget);
  });
}

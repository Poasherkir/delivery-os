import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';

/// Where a reset attempt has got to.
enum ResetPhase {
  /// Nothing running. Includes "never started" and "finished successfully" —
  /// the success case navigates away rather than being represented here.
  idle,

  /// Between the hold completing and the new database being ready. There is
  /// real work in this window and a second trigger in it must do nothing.
  running,

  /// The attempt did not complete. The driver is returned to the failure
  /// screen, which shows one extra line. Deliberately not a distinct error
  /// *screen*: he has now had two things fail, and stacking a second error
  /// state on the first makes the app read as confused about which.
  failed,
}

/// Runs the destructive reset, once at a time.
///
/// The reset itself is [DatabaseReset]; this owns the *state machine* around
/// it — the part with the windows in it.
class ResetController extends Notifier<ResetPhase> {
  @override
  ResetPhase build() => ResetPhase.idle;

  /// Attempts the reset. Returns true when the database was destroyed and a
  /// fresh key minted.
  ///
  /// **Re-entrant calls do nothing and say so by returning false.** A double
  /// tap, a stray gesture, or a rebuild that re-fires the completion callback
  /// would otherwise run a second delete against a database the first call is
  /// still working on. Guarding here rather than in the widget means the
  /// guarantee does not depend on which widget calls it.
  ///
  /// **Never retries by itself.** Two failures in a row is a situation for the
  /// driver to decide about, not for the app to keep hammering at.
  Future<bool> run() async {
    if (state == ResetPhase.running) {
      return false;
    }
    state = ResetPhase.running;

    try {
      final Future<void> Function()? reset = ref
          .read(databaseAccessProvider)
          .reset;
      if (reset == null) {
        throw StateError('DatabaseAccess.reset is not wired');
      }

      // Close first if anything is open. Deleting a file SQLite still holds
      // succeeds on POSIX and fails on Windows, and neither is an outcome to
      // meet on a driver's phone. Usually there is nothing to close, since
      // reaching this screen means the open failed.
      await ref.read(startupProvider).value?.database.close();

      await reset();

      state = ResetPhase.idle;
      return true;
    } catch (error, stack) {
      // Swallowed on purpose: the driver gets one plain line, and the detail
      // goes where a bug report can reach it. Rethrowing would surface a
      // stack trace on the worst screen in the app.
      if (kDebugMode) {
        debugPrint('reset failed: $error\n$stack');
      }
      state = ResetPhase.failed;
      return false;
    }
  }

  /// Clears the failure notice. Called when the driver acts again, so the line
  /// does not outlive the attempt it describes.
  void acknowledgeFailure() {
    if (state == ResetPhase.failed) {
      state = ResetPhase.idle;
    }
  }
}

final NotifierProvider<ResetController, ResetPhase> resetControllerProvider =
    NotifierProvider<ResetController, ResetPhase>(ResetController.new);

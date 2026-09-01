import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';
import '../controllers/reset_controller.dart';

/// Step one: what is about to be lost.
///
/// Categories rather than counts, because the database is unreadable and we
/// cannot count what is in it. Naming them is the only honest way to convey
/// scale — "your data" is abstract, "les encaissements et les règlements" is
/// not.
///
/// Cancelling from here lands back on the failure screen, never a blank route.
class DatabaseResetScreen extends StatelessWidget {
  const DatabaseResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpaceTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppText(l10n.resetTitle, AppTextStyle.headline),
              const SizedBox(height: SpaceTokens.space16),

              AppText(l10n.resetLosesIntro, AppTextStyle.body),
              const SizedBox(height: SpaceTokens.space12),

              for (final String item in <String>[
                l10n.resetLosesDeliveries,
                l10n.resetLosesCustomers,
                l10n.resetLosesMoney,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: SpaceTokens.space8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: SpaceTokens.space8,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: colors.statusProblemFg,
                        ),
                      ),
                      Expanded(child: AppText(item, AppTextStyle.body)),
                    ],
                  ),
                ),

              const SizedBox(height: SpaceTokens.space12),
              AppText(
                l10n.resetIrreversible,
                AppTextStyle.body,
                color: colors.statusProblemFg,
              ),

              const SizedBox(height: SpaceTokens.space24),
              AppText(l10n.resetReconcileFirst, AppTextStyle.bodySmall),

              const SizedBox(height: SpaceTokens.space32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  key: const Key('reset.cancel'),
                  // Cancel is the prominent action here. The destructive path
                  // is deliberately the quieter one at every step.
                  onPressed: () => Navigator.of(context).pop(),
                  child: AppText(l10n.resetCancel, AppTextStyle.label),
                ),
              ),
              const SizedBox(height: SpaceTokens.space12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  key: const Key('reset.continue'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DatabaseResetHoldScreen(),
                    ),
                  ),
                  child: AppText(
                    l10n.resetContinue,
                    AppTextStyle.label,
                    color: colors.statusProblemFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step two: hold to destroy.
///
/// A press-and-hold rather than a typed confirmation word. Typing a word on a
/// phone keyboard, in a second script, one-handed, while holding a parcel is
/// the wrong interaction for this context. A hold is language-neutral,
/// impossible to trigger by muscle memory, and works with one thumb.
class DatabaseResetHoldScreen extends ConsumerStatefulWidget {
  const DatabaseResetHoldScreen({super.key});

  static const Duration holdDuration = Duration(seconds: 3);

  @override
  ConsumerState<DatabaseResetHoldScreen> createState() =>
      _DatabaseResetHoldScreenState();
}

class _DatabaseResetHoldScreenState
    extends ConsumerState<DatabaseResetHoldScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: DatabaseResetHoldScreen.holdDuration,
  )..addStatusListener(_onProgress);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onProgress(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _commit();
    }
  }

  void _startHold(PointerDownEvent _) {
    // Only a press that *began* on this screen counts. Step one ends with a tap
    // on "Continuer" and this screen appears under that same finger; if the
    // timer accepted a pointer it never saw arrive, a driver who taps without
    // lifting cleanly would start the countdown without ever choosing to.
    // Listener's onPointerDown fires only for presses that begin here, so this
    // is structural rather than a timing guess.
    _progress.forward();
  }

  void _cancelHold() {
    // Lifting early cancels with no partial effect. The work happens only when
    // the full duration elapses; there is nothing to unwind.
    if (!_progress.isCompleted) {
      _progress.reset();
    }
  }

  Future<void> _commit() async {
    final NavigatorState navigator = Navigator.of(context);
    final bool ok = await ref.read(resetControllerProvider.notifier).run();
    if (!mounted) {
      return;
    }

    if (ok) {
      // Clear the whole flow. These screens describe a decision that has been
      // made; returning to them would offer to destroy data that no longer
      // exists, on a database that is now fine.
      unawaited(
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const DatabaseResetDoneScreen(),
          ),
          (Route<void> route) => false,
        ),
      );
    } else {
      // Back to the failure screen, which shows one extra line. Not a new
      // error screen stacked on the old one.
      navigator.popUntil((Route<void> route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final bool running =
        ref.watch(resetControllerProvider) == ResetPhase.running;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpaceTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppText(l10n.resetHoldTitle, AppTextStyle.headline),
              const SizedBox(height: SpaceTokens.space16),
              AppText(l10n.resetHoldInstruction, AppTextStyle.body),

              const Spacer(),

              Listener(
                key: const Key('reset.hold'),
                onPointerDown: running ? null : _startHold,
                onPointerUp: (_) => _cancelHold(),
                onPointerCancel: (_) => _cancelHold(),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (BuildContext context, Widget? child) {
                    return Stack(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 72,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.statusProblemBg,
                              border: Border.all(color: colors.statusProblemFg),
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.medium,
                              ),
                            ),
                          ),
                        ),
                        // Visible progress, so the hold is legible rather than
                        // a guess about how long to keep pressing.
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: _progress.value,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.statusProblemFg.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.medium,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpaceTokens.space16,
                              ),
                              child: AppText(
                                l10n.resetHoldAction,
                                AppTextStyle.label,
                                color: colors.statusProblemFg,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: SpaceTokens.space12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  key: const Key('reset.holdCancel'),
                  onPressed: running ? null : () => Navigator.of(context).pop(),
                  child: AppText(l10n.resetCancel, AppTextStyle.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step three: it is done, and the app is usable again.
///
/// Dropping silently into an empty app would read as another failure. The only
/// way off this screen is forward — the flow behind it was cleared when it was
/// pushed.
class DatabaseResetDoneScreen extends ConsumerWidget {
  const DatabaseResetDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpaceTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: SpaceTokens.space32),
              AppText(l10n.resetDoneTitle, AppTextStyle.headline),
              const SizedBox(height: SpaceTokens.space16),
              AppText(l10n.resetDoneBody, AppTextStyle.body),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  key: const Key('reset.done'),
                  // Retrying startup is what takes the app out of the failure
                  // branch entirely: once it succeeds, DeliveryOsApp renders
                  // the router and this whole tree is gone.
                  onPressed: () => ref.invalidate(startupProvider),
                  child: AppText(l10n.resetDoneAction, AppTextStyle.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

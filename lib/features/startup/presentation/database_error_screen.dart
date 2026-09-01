import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';
import '../controllers/reset_controller.dart';
import 'database_reset_screen.dart';

/// Shown when the encrypted database will not open.
///
/// The worst screen in the app, and the one most likely to be read in bad light
/// by someone holding a parcel. Four things, in this order:
///
/// 1. **What happened, in consequence terms.** The title carries it alone. It
///    never names encryption, keys or a database — that is our vocabulary, and
///    the driver's question is whether his day is over.
/// 2. **What is still true.** The parcels are real, the company still holds its
///    own record of the batch, and what was lost is the app's copy of the
///    history rather than his work or his money. This is the line that decides
///    whether he continues his day, so it gets the space it needs.
/// 3. **Reconcile with the company, first and emphasised.** Deliberately not a
///    numbered troubleshooting step: it fixes nothing, so listing it after
///    "retry" would read as what you do once the other steps fail. It is what
///    he does first, and it stays true even if retry works — if the money
///    records are gone, the bordereau is the surviving source.
/// 4. **Retry, and nothing else at this level.** The destructive reset lives
///    behind a secondary path. A driver who has just read that his data will
///    not open must not be one panicked tap from destroying it.
///
/// **No cause is stated.** A keystore wipe, a device restore, a corrupted file
/// and an OEM security reset all arrive as the same exception, so any cause
/// would be a guess — and a wrong explanation on the worst day costs more trust
/// than no explanation. The one hint worth giving sits behind a disclosure and
/// is phrased as *this can happen after*, never *this happened because*.
class DatabaseErrorScreen extends ConsumerWidget {
  const DatabaseErrorScreen({super.key});

  /// Debug-only route, so this copy can be read on a real screen in real light
  /// without deliberately corrupting a database to get here.
  static const String path = '/dev/db-error';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(SpaceTokens.space24),
              child: ConstrainedBox(
                // Fills the viewport when the copy is short, so the retry
                // button sits at the bottom rather than floating mid-screen;
                // scrolls when the text grows at a large font scale.
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (SpaceTokens.space24 * 2),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppText(l10n.dbErrorTitle, AppTextStyle.headline),
                      const SizedBox(height: SpaceTokens.space16),

                      AppText(l10n.dbErrorStillTrue, AppTextStyle.body),
                      const SizedBox(height: SpaceTokens.space20),

                      _Reconcile(text: l10n.dbErrorReconcile),
                      const SizedBox(height: SpaceTokens.space24),

                      _Step(index: 1, text: l10n.dbErrorStep1),
                      const SizedBox(height: SpaceTokens.space8),
                      _Step(index: 2, text: l10n.dbErrorStep2),

                      const SizedBox(height: SpaceTokens.space20),
                      _Why(
                        label: l10n.dbErrorWhyLabel,
                        body: l10n.dbErrorWhyBody,
                      ),

                      const Spacer(),
                      const SizedBox(height: SpaceTokens.space24),

                      // One line, on the existing screen, when a reset attempt
                      // did not complete. Deliberately not a second error
                      // state: the driver has now had two things fail, and
                      // stacking one on the other makes the screen read as
                      // though the app is confused about which.
                      if (ref.watch(resetControllerProvider) ==
                          ResetPhase.failed)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpaceTokens.space12,
                          ),
                          child: AppText(
                            l10n.dbErrorResetFailed,
                            AppTextStyle.bodySmall,
                            color: colors.statusProblemFg,
                          ),
                        ),

                      _RetryButton(label: l10n.dbErrorRetry),
                      const SizedBox(height: SpaceTokens.space8),
                      _OtherOptions(label: l10n.dbErrorOtherOptions),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The reconcile instruction, set apart from the numbered steps.
///
/// A leading rule rather than a filled card: elevation in this app is borders,
/// not shadows, and a coloured panel here would read as an alert when the point
/// is calm instruction.
class _Reconcile extends StatelessWidget {
  const _Reconcile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final BorderSide rule = BorderSide(color: colors.accent, width: 3);

    return Container(
      padding: EdgeInsetsDirectional.only(start: SpaceTokens.space12),
      decoration: BoxDecoration(
        // Directional so the rule sits on the reading edge in both scripts.
        border: rtl ? Border(right: rule) : Border(left: rule),
      ),
      child: AppText(text, AppTextStyle.body),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: SpaceTokens.space24,
          child: AppText(
            // Localized digits: Arabic renders ١ ٢ rather than 1 2, which is
            // what the rest of the app's numerals do.
            MaterialLocalizations.of(context).formatDecimal(index),
            AppTextStyle.bodySmall,
            color: colors.textSecondary,
          ),
        ),
        Expanded(
          child: AppText(
            text,
            AppTextStyle.bodySmall,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// The cause disclosure, collapsed by default.
class _Why extends StatefulWidget {
  const _Why({required this.label, required this.body});

  final String label;
  final String body;

  @override
  State<_Why> createState() => _WhyState();
}

class _WhyState extends State<_Why> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          key: const Key('dbError.why'),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            // 48dp minimum target, met by padding rather than by a bare label.
            padding: const EdgeInsets.symmetric(vertical: SpaceTokens.space12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppText(widget.label, AppTextStyle.label, color: colors.accent),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: colors.accent,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space8),
            child: AppText(
              widget.body,
              AppTextStyle.bodySmall,
              color: colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// The secondary path to the destructive reset.
///
/// A quiet text button below retry, never a peer of it. A driver who has just
/// read that his data will not open must not be one panicked tap from
/// destroying it, so the reset is two screens and a three-second hold away.
class _OtherOptions extends ConsumerWidget {
  const _OtherOptions({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        key: const Key('dbError.otherOptions'),
        onPressed: () {
          // Clear a stale failure line: it described the previous attempt, not
          // this one.
          ref.read(resetControllerProvider.notifier).acknowledgeFailure();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DatabaseResetScreen(),
            ),
          );
        },
        child: AppText(label, AppTextStyle.label),
      ),
    );
  }
}

/// Retry re-attempts the open by invalidating startup.
///
/// Worth having because a transient keystore failure can clear on relaunch,
/// which is the one case where this screen is recoverable.
class _RetryButton extends ConsumerWidget {
  const _RetryButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      // The next action is the largest tappable thing on screen.
      height: 56,
      child: FilledButton(
        key: const Key('dbError.retry'),
        onPressed: () => ref.invalidate(startupProvider),
        child: AppText(label, AppTextStyle.label),
      ),
    );
  }
}

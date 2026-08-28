import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_locales.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';

/// Live gallery of every design token.
///
/// Permanent, not throwaway, but gated behind [kDebugMode]: it pays for itself
/// every time the theme changes, and it is the fastest RTL smoke test in the
/// project. Its route and its entry in More both disappear from release builds.
///
/// Labels here are English literals on purpose. Invariant 10 governs
/// *user-facing* strings, and no driver ever reaches this screen; putting
/// "Elevation" and "Spacing" into the ARB bundles would dilute them with
/// vocabulary no translator should have to touch.
///
/// The locale toggle drives the real [localeControllerProvider], because
/// switching AR/FR is an M0 gate item and must be exercised for real. The theme
/// and text-scale toggles are local to this subtree — a global theme control
/// belongs to Settings in M5, and inventing one here would be building ahead.
class TokenGalleryScreen extends ConsumerStatefulWidget {
  const TokenGalleryScreen({super.key});

  static const String path = '/dev/tokens';

  @override
  ConsumerState<TokenGalleryScreen> createState() => _TokenGalleryScreenState();
}

class _TokenGalleryScreenState extends ConsumerState<TokenGalleryScreen> {
  Brightness? _brightnessOverride;
  double _textScale = 1.0;

  static const List<double> _scales = <double>[1.0, 1.15, 1.3];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness =
        _brightnessOverride ?? Theme.of(context).brightness;
    final ThemeData theme = brightness == Brightness.dark
        ? AppTheme.dark()
        : AppTheme.light();
    final ColorTokens colors = brightness == Brightness.dark
        ? ColorTokens.dark
        : ColorTokens.light;

    return Theme(
      data: theme,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(_textScale)),
        child: Scaffold(
          appBar: AppBar(
            title: const AppText('Design tokens', AppTextStyle.title),
          ),
          body: ListView(
            key: const Key('dev.gallery.list'),
            padding: const EdgeInsets.all(SpaceTokens.space16),
            children: <Widget>[
              _controls(colors),
              _RtlProof(colors: colors),
              _ColorSection(colors: colors),
              _StatusSection(colors: colors),
              _MoneySection(colors: colors),
              _TypeSection(colors: colors),
              _SpacingSection(colors: colors),
              _RadiusSection(colors: colors),
              _ElevationSection(colors: colors),
              _ConfidenceSection(colors: colors),
              _MotionSection(colors: colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controls(ColorTokens colors) {
    final Locale? locale = ref.watch(localeControllerProvider);

    return _Section(
      title: 'Controls',
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ControlRow(
            label: 'Locale',
            colors: colors,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: <ButtonSegment<String>>[
                const ButtonSegment<String>(value: '', label: Text('System')),
                for (final Locale option in AppLocales.supported)
                  ButtonSegment<String>(
                    value: option.languageCode,
                    label: Text(option.languageCode.toUpperCase()),
                  ),
              ],
              selected: <String>{locale?.languageCode ?? ''},
              onSelectionChanged: (Set<String> selection) {
                final String code = selection.single;
                // Drives the real controller: this is the M0 gate item.
                ref
                    .read(localeControllerProvider.notifier)
                    .select(code.isEmpty ? null : Locale(code));
              },
            ),
          ),
          _ControlRow(
            label: 'Theme',
            colors: colors,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: '', label: Text('System')),
                ButtonSegment<String>(value: 'light', label: Text('Light')),
                ButtonSegment<String>(value: 'dark', label: Text('Dark')),
              ],
              selected: <String>{
                switch (_brightnessOverride) {
                  null => '',
                  Brightness.light => 'light',
                  Brightness.dark => 'dark',
                },
              },
              onSelectionChanged: (Set<String> selection) => setState(() {
                _brightnessOverride = switch (selection.single) {
                  'light' => Brightness.light,
                  'dark' => Brightness.dark,
                  _ => null,
                };
              }),
            ),
          ),
          _ControlRow(
            label: 'Text scale',
            colors: colors,
            child: SegmentedButton<double>(
              showSelectedIcon: false,
              segments: <ButtonSegment<double>>[
                for (final double scale in _scales)
                  ButtonSegment<double>(value: scale, label: Text('${scale}x')),
              ],
              selected: <double>{_textScale},
              onSelectionChanged: (Set<double> selection) =>
                  setState(() => _textScale = selection.single),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.colors,
    required this.child,
  });

  final String title;
  final ColorTokens colors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpaceTokens.space24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(title, AppTextStyle.subtitle, color: colors.textSecondary),
        const SizedBox(height: SpaceTokens.space8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SpaceTokens.space12),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(
              color: colors.border,
              width: ElevationTokens.resting.borderWidth,
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.medium),
          ),
          child: child,
        ),
      ],
    ),
  );
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.label,
    required this.colors,
    required this.child,
  });

  final String label;
  final ColorTokens colors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpaceTokens.space12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(label, AppTextStyle.caption, color: colors.textSecondary),
        const SizedBox(height: SpaceTokens.space4),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      ],
    ),
  );
}

/// The fastest RTL check in the project.
///
/// Everything here is directional. Under `ar` the whole block must flip: the
/// start inset moves to the right edge, the icon leads from the right, and the
/// chevron points left. A block built with [EdgeInsets] and [Alignment] instead
/// of their directional counterparts stays put, which is exactly the bug this
/// makes obvious in one glance.
class _RtlProof extends StatelessWidget {
  const _RtlProof({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);

    return _Section(
      title: 'RTL mirroring — currently ${direction.name.toUpperCase()}',
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: colors.accentSubtle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: SpaceTokens.space48,
              ),
              child: Container(
                key: const Key('dev.rtlProof.bar'),
                height: SpaceTokens.space32,
                color: colors.accent,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.only(
                  start: SpaceTokens.space8,
                ),
                child: AppText(
                  'start inset 48',
                  AppTextStyle.caption,
                  color: colors.onAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: SpaceTokens.space8),
          Row(
            children: <Widget>[
              Icon(Icons.local_shipping_outlined, color: colors.textSecondary),
              const SizedBox(width: SpaceTokens.space8),
              Expanded(
                child: AppText(
                  'Bab Ezzouar — باب الزوار — 3 400,00',
                  AppTextStyle.body,
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textDisabled),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Colour — ${colors.all.length} tokens',
    colors: colors,
    child: Wrap(
      spacing: SpaceTokens.space8,
      runSpacing: SpaceTokens.space8,
      children: <Widget>[
        for (final MapEntry<String, Color> entry in colors.all.entries)
          Container(
            width: 148,
            padding: const EdgeInsets.all(SpaceTokens.space8),
            decoration: BoxDecoration(
              color: entry.value,
              border: Border.all(color: colors.borderStrong),
              borderRadius: BorderRadius.circular(RadiusTokens.small),
            ),
            child: AppText(
              entry.key,
              AppTextStyle.caption,
              color: entry.value.computeLuminance() > 0.4
                  ? ColorTokens.light.textPrimary
                  : ColorTokens.dark.textPrimary,
            ),
          ),
      ],
    ),
  );
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Status — four buckets, never colour alone',
    colors: colors,
    child: Wrap(
      spacing: SpaceTokens.space8,
      runSpacing: SpaceTokens.space8,
      children: <Widget>[
        _chip(
          'pending',
          colors.statusNeutralFg,
          colors.statusNeutralBg,
          Icons.circle_outlined,
        ),
        _chip(
          'on_route / arrived',
          colors.statusProgressFg,
          colors.statusProgressBg,
          Icons.local_shipping_outlined,
        ),
        _chip(
          'delivered',
          colors.statusSuccessFg,
          colors.statusSuccessBg,
          Icons.check_circle_outline,
        ),
        _chip(
          'failed / returned',
          colors.statusProblemFg,
          colors.statusProblemBg,
          Icons.error_outline,
        ),
      ],
    ),
  );

  Widget _chip(String label, Color fg, Color bg, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: SpaceTokens.space12,
      vertical: SpaceTokens.space4,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(RadiusTokens.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: SpaceTokens.space4),
        AppText(label, AppTextStyle.label, color: fg),
      ],
    ),
  );
}

class _MoneySection extends StatelessWidget {
  const _MoneySection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Money — hue encodes ownership',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _row('Earnings (yours)', '1 250,00', colors.moneyEarningFg),
        _row('Collected (not yours)', '412 300,00', colors.moneyOwedFg),
        _row('Owed to company', '398 050,00', colors.moneyOwedFg),
        _row('Expenses (spent)', '2 400,00', colors.statusProblemFg),
        const SizedBox(height: SpaceTokens.space8),
        AppText(
          'Cash on hand is large and neutral, not small and coloured.',
          AppTextStyle.caption,
          color: colors.textSecondary,
        ),
        const SizedBox(height: SpaceTokens.space4),
        AppText(
          '412 300,00 DA',
          AppTextStyle.moneyLarge,
          color: colors.moneyOwedFg,
        ),
      ],
    ),
  );

  Widget _row(String label, String amount, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: SpaceTokens.space4),
    child: Row(
      children: <Widget>[
        Expanded(
          child: AppText(
            label,
            AppTextStyle.bodySmall,
            color: colors.textSecondary,
          ),
        ),
        // Tabular figures come from the face itself, so these align.
        AppText(amount, AppTextStyle.moneyBody, color: color),
      ],
    ),
  );
}

class _TypeSection extends StatelessWidget {
  const _TypeSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Type — ${AppTextStyle.values.length} steps, FR and AR',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final AppTextStyle style in AppTextStyle.values)
          Padding(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText(
                  '${style.name}  ${style.style.fontSize!.toInt()}sp  '
                  'w${style.style.fontWeight!.value}',
                  AppTextStyle.caption,
                  color: colors.textSecondary,
                ),
                AppText('Livraison à Bab Ezzouar', style),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AppText('توصيل إلى باب الزوار', style),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Spacing — 2pt grid',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final double step in SpaceTokens.scale)
          Padding(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space4),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  child: AppText(
                    '${step.toInt()}',
                    AppTextStyle.caption,
                    color: colors.textSecondary,
                  ),
                ),
                Container(
                  width: step == 0 ? 1 : step,
                  height: SpaceTokens.space16,
                  color: step == 0 ? colors.border : colors.accent,
                ),
              ],
            ),
          ),
        const SizedBox(height: SpaceTokens.space8),
        AppText(
          'Minimum tap target ${SpaceTokens.minTapTarget.toInt()} · '
          'primary action ${SpaceTokens.primaryActionHeight.toInt()}',
          AppTextStyle.caption,
          color: colors.textSecondary,
        ),
      ],
    ),
  );
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Radius',
    colors: colors,
    child: Wrap(
      spacing: SpaceTokens.space8,
      runSpacing: SpaceTokens.space8,
      children: <Widget>[
        for (final double radius in RadiusTokens.scale)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: SpaceTokens.space48,
                height: SpaceTokens.space48,
                decoration: BoxDecoration(
                  color: colors.accentSubtle,
                  border: Border.all(color: colors.accent),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              AppText(
                radius >= RadiusTokens.pill ? 'pill' : '${radius.toInt()}',
                AppTextStyle.caption,
                color: colors.textSecondary,
              ),
            ],
          ),
      ],
    ),
  );
}

class _ElevationSection extends StatelessWidget {
  const _ElevationSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Elevation — borders, not shadows',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final ElevationToken token in ElevationTokens.scale)
          Padding(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpaceTokens.space12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: token.borderWidth == 0
                    ? null
                    : Border.all(
                        color: colors.border,
                        width: token.borderWidth,
                      ),
                borderRadius: BorderRadius.circular(RadiusTokens.medium),
                boxShadow: token.shadows(colors.scrim),
              ),
              child: AppText(
                '${token.name} · border ${token.borderWidth} · '
                'shadow ${token.opacity}',
                AppTextStyle.caption,
                color: colors.textSecondary,
              ),
            ),
          ),
      ],
    ),
  );
}

class _ConfidenceSection extends StatelessWidget {
  const _ConfidenceSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Coordinate confidence — no colour of its own',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final ConfidenceTreatment tier in ConfidenceTokens.byTier)
          Padding(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space8),
            child: Row(
              children: <Widget>[
                _marker(tier),
                const SizedBox(width: SpaceTokens.space12),
                Expanded(
                  child: AppText(
                    'tier ${tier.tier} · '
                    '${tier.dashPattern == null ? "solid" : "dashed"} · '
                    '${tier.filled ? "filled" : "outline"} · '
                    'badge ${tier.badge.name}',
                    AppTextStyle.caption,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  /// Approximates the dashed treatments with opacity, since painting a real
  /// dash pattern belongs to the map layer in M4. The point here is that the
  /// five tiers are distinguishable without a fifth colour ramp.
  Widget _marker(ConfidenceTreatment tier) => Container(
    width: SpaceTokens.space32,
    height: SpaceTokens.space32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: tier.filled ? colors.textSecondary : Colors.transparent,
      border: Border.all(
        color: tier.dashPattern == null
            ? colors.textPrimary
            : colors.textDisabled,
        width: tier.borderWidth,
      ),
    ),
    child: switch (tier.badge) {
      ConfidenceBadge.none => null,
      ConfidenceBadge.unknown => Icon(
        Icons.question_mark,
        size: 14,
        color: colors.textSecondary,
      ),
      ConfidenceBadge.confirmed => Icon(
        Icons.check,
        size: 14,
        color: colors.surface,
      ),
    },
  );
}

class _MotionSection extends StatelessWidget {
  const _MotionSection({required this.colors});

  final ColorTokens colors;

  @override
  Widget build(BuildContext context) => _Section(
    title: 'Motion — functional, never decorative',
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final Duration duration in MotionTokens.scale)
          AppText(
            '${duration.inMilliseconds}ms',
            AppTextStyle.caption,
            color: colors.textSecondary,
          ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/l10n/app_locales.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';

/// Settings, reached from More.
///
/// One thing on it so far: the language. The controller, the nullable
/// `users.locale` column and the copy all existed since M0 — what was missing
/// was a place a driver could actually reach any of it. Until now the only
/// language switch in the app was the token gallery, which is behind
/// `kDebugMode` and never ships.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    // Null means "follow the device", which is a real choice and not the
    // absence of one — see the column doc on `users.locale`.
    final Locale? chosen = ref.watch(localeControllerProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(MoreEntry.settings.label(l10n), AppTextStyle.title),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpaceTokens.space16,
              SpaceTokens.space16,
              SpaceTokens.space16,
              SpaceTokens.space8,
            ),
            child: AppText(l10n.settingsLanguage, AppTextStyle.label),
          ),

          _LanguageRow(
            key: const Key('settings.language.system'),
            label: l10n.languageSystem,
            selected: chosen == null,
            onTap: () =>
                ref.read(localeControllerProvider.notifier).select(null),
          ),
          for (final Locale option in AppLocales.supported)
            _LanguageRow(
              key: Key('settings.language.${option.languageCode}'),
              label: _endonym(l10n, option),
              selected: chosen?.languageCode == option.languageCode,
              onTap: () =>
                  ref.read(localeControllerProvider.notifier).select(option),
            ),
        ],
      ),
    );
  }

  /// Each language named in itself.
  ///
  /// Deliberately not translated — this is the one screen a driver reaches
  /// when the app is in a language they cannot read, and they find their own
  /// by recognising it. The switch is exhaustive over the shipped set, so a
  /// fourth locale added without a name for it does not compile.
  String _endonym(AppL10n l10n, Locale locale) => switch (locale.languageCode) {
    'ar' => l10n.languageArabic,
    'fr' => l10n.languageFrench,
    'en' => l10n.languageEnglish,
    _ => locale.languageCode.toUpperCase(),
  };
}

/// One language, selectable in a single tap.
///
/// No save button: a language change applies immediately and persists itself.
/// Making the driver confirm a choice they can see the result of would be a
/// tap that answers a question they already answered.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return ListTile(
      // Comfortably past the 48dp minimum: the driver is one-handed, and this
      // list is read in whatever language they cannot currently read.
      minTileHeight: 56,
      title: AppText(label, AppTextStyle.body),
      // Colour is never the only signal — the check is the signal, the tint
      // follows it.
      trailing: selected
          ? Icon(Icons.check, color: colors.accent)
          : const SizedBox.shrink(),
      selected: selected,
      onTap: onTap,
    );
  }
}

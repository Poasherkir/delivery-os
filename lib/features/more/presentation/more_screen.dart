import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';

/// The More destination: a plain list, deliberately.
///
/// Not a shell branch with its own stack. Each entry pushes onto the root
/// navigator, so tapping Customers leaves the five-tab world rather than
/// burrowing into a sixth tab that the bottom bar cannot show.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: SpaceTokens.space8),
      itemCount: MoreEntry.values.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(height: 1, color: colors.border),
      itemBuilder: (BuildContext context, int index) {
        final MoreEntry entry = MoreEntry.values[index];

        return ListTile(
          key: ValueKey<MoreEntry>(entry),
          leading: Icon(entry.icon, color: colors.textSecondary),
          title: AppText(entry.label(l10n), AppTextStyle.body),
          // chevron_right carries matchTextDirection: true, so it flips to
          // point left under RTL. Verified against the Material icon table,
          // not assumed — most Material icons do not.
          trailing: Icon(Icons.chevron_right, color: colors.textDisabled),
          onTap: () => context.push(entry.path),
        );
      },
    );
  }
}

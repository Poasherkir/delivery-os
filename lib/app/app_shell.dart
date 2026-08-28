import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/generated/app_l10n.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/tokens/tokens.dart';
import '../shared/widgets/app_text.dart';
import 'routes.dart';

/// Chrome around the five bottom-nav destinations.
///
/// Owns the only [Scaffold] in the shell, so branch screens are plain bodies
/// rather than nested scaffolds. Screens reached from More live outside this
/// shell entirely and bring their own.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final AppDestination current =
        AppDestination.values[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(title: AppText(current.label(l10n), AppTextStyle.title)),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: <Widget>[
          for (final AppDestination destination in AppDestination.values)
            NavigationDestination(
              // The glyph changes on selection, not just the tint: colour is
              // never the only signal.
              icon: Icon(destination.icon, color: colors.textSecondary),
              selectedIcon: Icon(destination.active, color: colors.accent),
              label: destination.label(l10n),
              tooltip: destination.label(l10n),
            ),
        ],
      ),
    );
  }

  void _select(int index) {
    // Tapping the destination you are already on pops that branch back to its
    // root, which is the behaviour every Android user expects.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

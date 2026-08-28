import 'package:flutter/material.dart';

import '../core/l10n/generated/app_l10n.dart';

/// The five bottom-nav destinations.
///
/// **Five, not six.** Past five the targets drop below 40dp, and this user is
/// tapping one-handed while holding a parcel. A test enforces the count, so
/// adding a sixth is a decision someone has to argue for rather than a diff
/// that slips through.
///
/// The twelve `features/` folders are a code layout, not a navigation design.
/// Delivery is a modal flow launched from Route or Orders; ingestion is a FAB.
/// Neither is a destination.
enum AppDestination {
  home(path: '/home', icon: Icons.dashboard_outlined, active: Icons.dashboard),
  orders(
    path: '/orders',
    icon: Icons.inventory_2_outlined,
    active: Icons.inventory_2,
  ),
  route(path: '/route', icon: Icons.route_outlined, active: Icons.route),
  money(
    path: '/money',
    icon: Icons.account_balance_wallet_outlined,
    active: Icons.account_balance_wallet,
  ),
  more(path: '/more', icon: Icons.menu, active: Icons.menu);

  const AppDestination({
    required this.path,
    required this.icon,
    required this.active,
  });

  final String path;
  final IconData icon;

  /// Shown when the destination is selected. Colour is never the only signal,
  /// so the selected state changes the glyph as well as the tint.
  final IconData active;

  String label(AppL10n l10n) => switch (this) {
    AppDestination.home => l10n.navHome,
    AppDestination.orders => l10n.navOrders,
    AppDestination.route => l10n.navRoute,
    AppDestination.money => l10n.navMoney,
    AppDestination.more => l10n.navMore,
  };
}

/// Screens reached from the More list.
///
/// These are pushed onto the **root** navigator, above the shell, so the bottom
/// bar is not present while you are in them. More is a plain list, not a branch
/// with its own stack: a driver who taps Customers is leaving the five-tab
/// world, not burrowing into a sixth tab.
enum MoreEntry {
  customers(path: '/customers', icon: Icons.people_outline),
  companies(path: '/companies', icon: Icons.business_outlined),
  history(path: '/history', icon: Icons.history),
  settings(path: '/settings', icon: Icons.settings_outlined);

  const MoreEntry({required this.path, required this.icon});

  final String path;
  final IconData icon;

  String label(AppL10n l10n) => switch (this) {
    MoreEntry.customers => l10n.navCustomers,
    MoreEntry.companies => l10n.navCompanies,
    MoreEntry.history => l10n.navHistory,
    MoreEntry.settings => l10n.navSettings,
  };
}

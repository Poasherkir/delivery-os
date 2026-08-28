import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/companies/presentation/companies_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/money/presentation/money_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/route/presentation/route_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

/// Created once per app, not per rebuild — a fresh [GoRouter] would reset the
/// navigation stack every time the locale or theme changed.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppDestination.home.path,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppShell(navigationShell: navigationShell),
        // One branch per destination, in enum order, so `currentIndex` and
        // `AppDestination.values` cannot drift apart.
        branches: <StatefulShellBranch>[
          for (final AppDestination destination in AppDestination.values)
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: destination.path,
                  builder: (BuildContext context, GoRouterState state) =>
                      _destinationScreen(destination),
                ),
              ],
            ),
        ],
      ),

      // Declared outside the shell, so go_router puts them on the root
      // navigator: they cover the bottom bar instead of nesting in a tab.
      for (final MoreEntry entry in MoreEntry.values)
        GoRoute(
          path: entry.path,
          builder: (BuildContext context, GoRouterState state) =>
              _moreScreen(entry),
        ),
    ],
  );
});

Widget _destinationScreen(AppDestination destination) => switch (destination) {
  AppDestination.home => const HomeScreen(),
  AppDestination.orders => const OrdersScreen(),
  AppDestination.route => const RouteScreen(),
  AppDestination.money => const MoneyScreen(),
  AppDestination.more => const MoreScreen(),
};

Widget _moreScreen(MoreEntry entry) => switch (entry) {
  MoreEntry.customers => const CustomersScreen(),
  MoreEntry.companies => const CompaniesScreen(),
  MoreEntry.history => const HistoryScreen(),
  MoreEntry.settings => const SettingsScreen(),
};

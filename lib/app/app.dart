import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_locales.dart';
import '../core/l10n/generated/app_l10n.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/startup/presentation/database_error_screen.dart';
import 'di.dart';
import 'router.dart';
import 'startup.dart';

/// Root widget: router, theme and locale, and nothing else.
class DeliveryOsApp extends ConsumerWidget {
  const DeliveryOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? override = ref.watch(localeControllerProvider);
    final AsyncValue<StartupResult> startup = ref.watch(startupProvider);

    // Watched, not read: this is what triggers reconciliation once the
    // database is up. Its own failure is already represented by `startup`.
    ref.watch(localeReconciliationProvider);

    // When the database will not open there is no navigation to do — no shell,
    // no destinations, one screen. Rendering it as `home` rather than as a
    // router destination is deliberate: a driver on this screen must not be
    // able to reach the rest of the app through a back gesture or a deep link
    // into a database that is not there.
    //
    // The database opens *after* the first frame, so this branch is reachable
    // only once startup has actually failed. Loading and success both render
    // the router, which is why a fresh install — where there is no database
    // file yet and creating one is normal — never sees this screen.
    if (startup.hasError) {
      return MaterialApp(
        onGenerateTitle: (BuildContext context) => AppL10n.of(context).appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        locale: override,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: AppL10n.localizationsDelegates,
        localeListResolutionCallback:
            (List<Locale>? device, Iterable<Locale> supported) =>
                AppLocales.resolve(device, override: override),
        home: const DatabaseErrorScreen(),
      );
    }

    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => AppL10n.of(context).appTitle,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,

      // When the driver has chosen a language, `locale` is non-null and
      // WidgetsApp resolves against just that. When it is null, the callback
      // receives the real device list. Both paths land in AppLocales.resolve,
      // so there is one rule rather than two.
      locale: override,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: AppL10n.localizationsDelegates,
      localeListResolutionCallback:
          (List<Locale>? device, Iterable<Locale> supported) =>
              AppLocales.resolve(device, override: override),
    );
  }
}

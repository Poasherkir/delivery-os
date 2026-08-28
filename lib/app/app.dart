import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_locales.dart';
import '../core/l10n/generated/app_l10n.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root widget: router, theme and locale, and nothing else.
class DeliveryOsApp extends ConsumerWidget {
  const DeliveryOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? override = ref.watch(localeControllerProvider);
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

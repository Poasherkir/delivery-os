import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/app_locales.dart';
import 'core/l10n/generated/app_l10n.dart';
import 'core/l10n/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/font_license.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  // Loaded before the first frame so the app never renders once in the wrong
  // language and then swaps.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // `Override` is not exported by Riverpod 3, so the list type is
      // inferred rather than annotated.
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DeliveryOsApp(),
    ),
  );
}

/// Root widget of Delivery OS.
///
/// Routing arrives in M0-06; until then this renders an empty scaffold, so the
/// only user-facing string is the app title, which comes from the ARB files.
class DeliveryOsApp extends ConsumerWidget {
  const DeliveryOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? override = ref.watch(localeControllerProvider);

    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppL10n.of(context).appTitle,
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

      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/font_license.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  runApp(const DeliveryOsApp());
}

/// Root widget of Delivery OS.
///
/// Localization arrives in M0-05 and routing in M0-06; until then this renders
/// nothing user-facing, so there are no hardcoded strings to localize
/// (invariant 10).
class DeliveryOsApp extends StatelessWidget {
  const DeliveryOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}

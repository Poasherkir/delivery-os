import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/di.dart';
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

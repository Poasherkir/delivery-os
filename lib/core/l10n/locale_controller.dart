import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locales.dart';

/// Overridden in `main()` with an instance loaded before the first frame, so
/// the app never renders one frame in the wrong language and then swaps.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw StateError(
        'sharedPreferencesProvider must be overridden in ProviderScope',
      ),
    );

/// The driver's explicit language choice, or `null` for "follow the device".
///
/// Stored in shared preferences rather than the database: this is read before
/// the first frame, and the encrypted database needs an async keystore round
/// trip to open. `users.locale` in the schema is the value that will *sync*
/// when V2 arrives; when the DB lands in M0-21 the two need reconciling, and
/// this store stays the one the first frame reads.
class LocaleController extends Notifier<Locale?> {
  static const String storageKey = 'locale.override';

  @override
  Locale? build() {
    final String? code = ref
        .watch(sharedPreferencesProvider)
        .getString(storageKey);
    // A stored code that is no longer supported degrades to "follow the
    // device" rather than throwing. Dropping a locale must not brick the app
    // for whoever had it selected.
    if (code == null || !AppLocales.isSupported(code)) {
      return null;
    }
    return Locale(code);
  }

  /// Sets an explicit language, or clears the override when [locale] is null.
  ///
  /// Throws on an unsupported locale: that is a programming error, not
  /// something to swallow, and the selector only offers what is supported.
  Future<void> select(Locale? locale) async {
    if (locale != null && !AppLocales.isSupported(locale.languageCode)) {
      throw ArgumentError.value(locale, 'locale', 'not a supported locale');
    }

    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);

    if (locale == null) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, locale.languageCode);
    }

    state = locale;
  }
}

final NotifierProvider<LocaleController, Locale?> localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

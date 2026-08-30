import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di.dart';
import '../../domain/repositories/user_settings.dart';
import 'app_locales.dart';

/// The driver's explicit language choice, or `null` for "follow the device".
///
/// ## Two stores, and why neither is redundant
///
/// `users.locale` is the source of truth. Shared preferences is a cache of it.
///
/// **The cache exists for the failure path.** The encrypted database needs an
/// async keystore round trip to open, and that open can fail — a wiped keystore
/// entry, a corrupted file. When it does, the driver still has to be told so,
/// in a language they read. A message about unreadable data is worthless in the
/// wrong script, so the language the first frame renders in cannot depend on
/// the thing that just failed. That is the whole reason for the duplication;
/// without it this cache looks redundant and someone deletes it.
///
/// **Ordering is what keeps them consistent, not a merge rule.** Every change
/// writes the database first and mirrors to preferences second, so preferences
/// can only ever be stale, never ahead. "Which one is more recent" is therefore
/// never a question anyone has to answer, and there is no timestamp comparison
/// anywhere in this file. When the two disagree, the database is right by
/// construction.
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

    // The database first. If it throws, preferences is left alone and nothing
    // is written anywhere — which is the outcome the ordering exists to
    // guarantee. Writing the cache first and then failing would leave a stored
    // choice the source of truth has never heard of.
    if (locale != null) {
      final UserSettings? settings = ref.read(userSettingsProvider);
      // Null before the database opens, and null for good if it never does.
      // A driver switching language on the "cannot be decrypted" screen is the
      // case this tolerates: that write reaches preferences only, which is
      // exactly as much as a broken database can honour.
      if (settings != null) {
        await settings.setLocale(locale.languageCode);
      }
    }

    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);

    if (locale == null) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, locale.languageCode);
    }

    state = locale;
  }

  /// Brings the cache and the UI in line with the database, once it is open.
  ///
  /// Call after bootstrap. Does nothing when there is no database, no user row
  /// yet, or nothing to correct — so it is safe on every launch, which is when
  /// it runs.
  Future<void> reconcile() async {
    final UserSettings? settings = ref.read(userSettingsProvider);
    if (settings == null) {
      return;
    }

    final String? stored = await settings.locale();
    if (stored == null || stored == state?.languageCode) {
      return;
    }

    // "Follow the device" is an instruction, not a value, and the database has
    // no way to express it: `users.locale` is a non-null tag. So a concrete
    // value there must not be allowed to manufacture an override the driver
    // never chose — that would silently convert System into an explicit pick,
    // and the driver would never get their device language back.
    if (state == null) {
      return;
    }

    // A language the database names but this build no longer ships. Leave the
    // current choice alone rather than clearing it: same reasoning as `build`,
    // where dropping a locale must not disrupt whoever had it selected.
    if (!AppLocales.isSupported(stored)) {
      return;
    }

    // The database wins. Correct the cache, then the UI.
    await ref.read(sharedPreferencesProvider).setString(storageKey, stored);
    state = Locale(stored);
  }
}

final NotifierProvider<LocaleController, Locale?> localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

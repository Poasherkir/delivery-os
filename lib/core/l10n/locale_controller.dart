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
    //
    // Clearing the override is a write like any other: null goes to the
    // database as null, because "follow the device" is a preference to record
    // rather than the absence of one.
    final UserSettings? settings = ref.read(userSettingsProvider);
    // Null before the database opens, and null for good if it never does.
    // A driver switching language on the "cannot be decrypted" screen is the
    // case this tolerates: that write reaches preferences only, which is
    // exactly as much as a broken database can honour.
    if (settings != null) {
      await settings.setLocale(locale?.languageCode);
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

    final LocalePreference? stored = await settings.localePreference();
    if (stored == null) {
      // No user row yet — the window between the database opening and
      // bootstrap seeding. Nothing to reconcile against.
      return;
    }

    // A language the database names but this build no longer ships. Leave
    // everything alone rather than clearing: same reasoning as `build`, where
    // dropping a locale must not disrupt whoever had it selected.
    if (stored.isExplicit && !AppLocales.isSupported(stored.tag!)) {
      return;
    }

    // Both stores now hold the same datum — a preference, where null means
    // "follow the device" — so the database wins in *both* directions and
    // there is no special case for System. An explicit choice here overwrites
    // a stale one in the cache, and a null here clears one.
    final Locale? target = stored.isExplicit ? Locale(stored.tag!) : null;
    if (target?.languageCode == state?.languageCode) {
      return;
    }

    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (target == null) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, target.languageCode);
    }
    state = target;
  }
}

final NotifierProvider<LocaleController, Locale?> localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// Reconciles the cached locale against the database once startup succeeds.
///
/// Lives here rather than in `di.dart` to keep the dependency edges one-way:
/// `userSettingsProvider` is derived from `startupProvider`, so anything that
/// reconciles has to sit *downstream* of both. Reconciling from inside startup
/// would be a cycle.
///
/// Never resolves if startup fails, which is correct — there is no source of
/// truth to reconcile against, and the cached locale is the only thing keeping
/// the failure screen readable.
final FutureProvider<void> localeReconciliationProvider = FutureProvider<void>((
  Ref ref,
) async {
  await ref.watch(startupProvider.future);
  await ref.read(localeControllerProvider.notifier).reconcile();
});

import 'dart:ui' show Locale;

import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/domain/repositories/user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A settings store that records what it was asked, and when.
final class _FakeSettings implements UserSettings {
  _FakeSettings(this._prefs, {this.stored, this.failWrite = false});

  final SharedPreferences _prefs;
  String? stored;
  final bool failWrite;

  final List<String> writes = <String>[];

  /// What preferences held at the instant the database write ran.
  ///
  /// How the ordering rule gets tested rather than merely asserted: if the
  /// database really is written first, preferences must still hold the *old*
  /// value at this point.
  String? prefsDuringWrite;
  bool wroteAtLeastOnce = false;

  @override
  Future<String?> locale() async => stored;

  @override
  Future<void> setLocale(String locale) async {
    if (failWrite) {
      throw StateError('the database write failed');
    }
    prefsDuringWrite = _prefs.getString(LocaleController.storageKey);
    wroteAtLeastOnce = true;
    writes.add(locale);
    stored = locale;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late _FakeSettings fake;

  /// Builds a container. [dbLocale] is what `users.locale` holds; [stored] is
  /// what preferences holds; [withDatabase] false stands in for a database
  /// that never opened.
  Future<ProviderContainer> container({
    Map<String, Object> stored = const <String, Object>{},
    String? dbLocale,
    bool withDatabase = true,
    bool failWrite = false,
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    prefs = await SharedPreferences.getInstance();
    fake = _FakeSettings(prefs, stored: dbLocale, failWrite: failWrite);

    // `Override` is not exported by Riverpod 3; the list type is inferred.
    final ProviderContainer c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (withDatabase) userSettingsProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('the database is written first', () {
    test('preferences still holds the old value during the write', () async {
      // The ordering rule, caught at the only moment it is observable.
      // Writing the cache first and the truth second is what would make
      // "which is more recent" a question someone has to answer; this is what
      // stops that question from ever arising.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        dbLocale: 'ar',
      );

      await c.read(localeControllerProvider.notifier).select(AppLocales.french);

      expect(fake.wroteAtLeastOnce, isTrue);
      expect(
        fake.prefsDuringWrite,
        'ar',
        reason: 'preferences was updated before the database',
      );
    });

    test('and preferences catches up afterwards', () async {
      final ProviderContainer c = await container(dbLocale: 'ar');

      await c.read(localeControllerProvider.notifier).select(AppLocales.french);

      expect(fake.writes, <String>['fr']);
      expect(prefs.getString(LocaleController.storageKey), 'fr');
      expect(c.read(localeControllerProvider), AppLocales.french);
    });

    test('a failed database write leaves preferences untouched', () async {
      // The outcome the ordering exists to guarantee: nothing written
      // anywhere, rather than a stored choice the source of truth never heard
      // of.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        failWrite: true,
      );

      await expectLater(
        c.read(localeControllerProvider.notifier).select(AppLocales.french),
        throwsA(isA<StateError>()),
      );

      expect(prefs.getString(LocaleController.storageKey), 'ar');
      expect(c.read(localeControllerProvider), AppLocales.arabic);
    });
  });

  group('with no database', () {
    test('a language change still reaches preferences', () async {
      // The "your data cannot be decrypted" path. A driver switching language
      // to read that message is exactly the case this tolerates, and
      // preferences is as much as a broken database can honour.
      final ProviderContainer c = await container(withDatabase: false);

      await c.read(localeControllerProvider.notifier).select(AppLocales.french);

      expect(prefs.getString(LocaleController.storageKey), 'fr');
      expect(c.read(localeControllerProvider), AppLocales.french);
    });

    test('reconcile does nothing at all', () async {
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'fr'},
        withDatabase: false,
      );

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
      expect(prefs.getString(LocaleController.storageKey), 'fr');
    });
  });

  group('reconcile', () {
    test('the database wins over a stale cache', () async {
      // The case the whole design is for. Preferences can only ever be stale,
      // so when the two disagree the database is right by construction.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        dbLocale: 'fr',
      );
      expect(c.read(localeControllerProvider), AppLocales.arabic);

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
    });

    test('and the cache is corrected too, not just the UI', () async {
      // Otherwise the next launch reads the stale value again and the
      // correction has to be repeated forever.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        dbLocale: 'fr',
      );

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(prefs.getString(LocaleController.storageKey), 'fr');
    });

    test('"follow the device" is never converted into a choice', () async {
      // `users.locale` is a non-null tag with no way to say "follow the
      // device". A concrete value there must not manufacture an override the
      // driver never made, or they never get their device language back.
      final ProviderContainer c = await container(dbLocale: 'fr');
      expect(c.read(localeControllerProvider), isNull);

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), isNull);
      expect(prefs.getString(LocaleController.storageKey), isNull);
    });

    test('agreement is a no-op', () async {
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'fr'},
        dbLocale: 'fr',
      );

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
      expect(prefs.getString(LocaleController.storageKey), 'fr');
    });

    test('no user row yet is a no-op, not a crash', () async {
      // The window between the database opening and bootstrap seeding it.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'fr'},
      );

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
    });

    test('a language this build dropped leaves the choice alone', () async {
      // Same reasoning as `build`: dropping a locale must not disrupt whoever
      // had it selected, and least of all by clearing it silently.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'fr'},
        dbLocale: 'de',
      );

      await c.read(localeControllerProvider.notifier).reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
      expect(prefs.getString(LocaleController.storageKey), 'fr');
    });

    test('is safe to run on every launch', () async {
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        dbLocale: 'fr',
      );

      final LocaleController controller = c.read(
        localeControllerProvider.notifier,
      );
      await controller.reconcile();
      await controller.reconcile();
      await controller.reconcile();

      expect(c.read(localeControllerProvider), AppLocales.french);
      expect(fake.writes, isEmpty, reason: 'reconcile must not write back');
    });
  });

  test('selecting an unsupported locale still throws', () async {
    // Unchanged from M0-04. The database path must not have loosened it.
    final ProviderContainer c = await container();

    expect(
      () =>
          c.read(localeControllerProvider.notifier).select(const Locale('de')),
      throwsA(isA<ArgumentError>()),
    );
  });
}

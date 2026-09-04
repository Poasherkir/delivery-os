import 'dart:ui' show Locale;

import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // `Override` is not exported by Riverpod 3; the list type is inferred.
  final ProviderContainer container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts with no override when nothing is stored', () {
    // Null means "follow the device", which is the state a fresh install is in.
    return _container(<String, Object>{}).then((ProviderContainer container) {
      expect(container.read(localeControllerProvider), isNull);
    });
  });

  test('restores a stored choice', () async {
    final ProviderContainer container = await _container(<String, Object>{
      LocaleController.storageKey: 'fr',
    });

    expect(container.read(localeControllerProvider), AppLocales.french);
  });

  test(
    'a stored code that is no longer shipped degrades to follow-device',
    () async {
      // Dropping a locale in a future release must not brick the app for
      // whoever had it selected. Turkish, not English: English ships now, so
      // storing it would exercise the supported path rather than this one.
      final ProviderContainer container = await _container(<String, Object>{
        LocaleController.storageKey: 'tr',
      });

      expect(container.read(localeControllerProvider), isNull);
    },
  );

  test('selecting persists and updates the state', () async {
    final ProviderContainer container = await _container(<String, Object>{});

    await container
        .read(localeControllerProvider.notifier)
        .select(AppLocales.arabic);

    expect(container.read(localeControllerProvider), AppLocales.arabic);
    expect(
      container
          .read(sharedPreferencesProvider)
          .getString(LocaleController.storageKey),
      'ar',
    );
  });

  test('the choice survives a restart', () async {
    final ProviderContainer first = await _container(<String, Object>{});
    await first
        .read(localeControllerProvider.notifier)
        .select(AppLocales.french);

    // A second container over the same store stands in for a cold start.
    final SharedPreferences prefs = first.read(sharedPreferencesProvider);
    final ProviderContainer second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);

    expect(second.read(localeControllerProvider), AppLocales.french);
  });

  test('clearing removes the stored value', () async {
    final ProviderContainer container = await _container(<String, Object>{
      LocaleController.storageKey: 'fr',
    });

    await container.read(localeControllerProvider.notifier).select(null);

    expect(container.read(localeControllerProvider), isNull);
    expect(
      container
          .read(sharedPreferencesProvider)
          .containsKey(LocaleController.storageKey),
      isFalse,
    );
  });

  test('selecting an unshipped locale throws', () async {
    final ProviderContainer container = await _container(<String, Object>{});

    expect(
      () => container
          .read(localeControllerProvider.notifier)
          .select(const Locale('tr')),
      throwsArgumentError,
    );
  });
}

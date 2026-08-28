import 'dart:ui' show Locale;

import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolve', () {
    test('honours a supported device language', () {
      expect(
        AppLocales.resolve(const <Locale>[Locale('fr')]),
        AppLocales.french,
      );
      expect(
        AppLocales.resolve(const <Locale>[Locale('ar')]),
        AppLocales.arabic,
      );
    });

    test('ignores the region subtag', () {
      // An Algerian device is ar-DZ or fr-DZ, never bare ar or fr.
      for (final Locale device in const <Locale>[
        Locale('ar', 'DZ'),
        Locale('ar', 'MA'),
        Locale('ar', 'EG'),
      ]) {
        expect(AppLocales.resolve(<Locale>[device]), AppLocales.arabic);
      }
      expect(
        AppLocales.resolve(const <Locale>[Locale('fr', 'DZ')]),
        AppLocales.french,
      );
      expect(
        AppLocales.resolve(const <Locale>[Locale('fr', 'CA')]),
        AppLocales.french,
      );
    });

    test('falls back to Arabic for an unsupported language', () {
      expect(
        AppLocales.resolve(const <Locale>[Locale('en', 'US')]),
        AppLocales.arabic,
      );
      expect(
        AppLocales.resolve(const <Locale>[Locale('es')]),
        AppLocales.arabic,
      );
    });

    test('falls back to Arabic when the device list is empty or absent', () {
      expect(AppLocales.resolve(const <Locale>[]), AppLocales.arabic);
      expect(AppLocales.resolve(null), AppLocales.arabic);
    });

    test('takes the first supported entry, not the first entry', () {
      // Android reports an ordered preference list. A driver whose phone is
      // English-first but French-second should get French, not the fallback.
      expect(
        AppLocales.resolve(const <Locale>[
          Locale('en'),
          Locale('de'),
          Locale('fr'),
          Locale('ar'),
        ]),
        AppLocales.french,
      );
    });

    test('an explicit choice beats the device', () {
      expect(
        AppLocales.resolve(const <Locale>[
          Locale('fr', 'DZ'),
        ], override: AppLocales.arabic),
        AppLocales.arabic,
      );
      expect(
        AppLocales.resolve(const <Locale>[
          Locale('ar', 'DZ'),
        ], override: AppLocales.french),
        AppLocales.french,
      );
    });

    test('an unsupported override defers to the device', () {
      // Not an error at this layer: a stale stored value must degrade, not
      // strand the driver in a language the app does not ship.
      expect(
        AppLocales.resolve(const <Locale>[
          Locale('fr'),
        ], override: const Locale('en')),
        AppLocales.french,
      );
    });

    test('always returns a supported locale', () {
      for (final List<Locale>? device in <List<Locale>?>[
        null,
        const <Locale>[],
        const <Locale>[Locale('zh')],
        const <Locale>[Locale('ar', 'DZ')],
      ]) {
        expect(AppLocales.supported, contains(AppLocales.resolve(device)));
      }
    });
  });

  group('direction', () {
    test('Arabic is RTL and French is not', () {
      expect(AppLocales.isRtl(AppLocales.arabic), isTrue);
      expect(AppLocales.isRtl(AppLocales.french), isFalse);
      expect(AppLocales.isRtl(const Locale('ar', 'DZ')), isTrue);
    });
  });

  group('supported set', () {
    test('Arabic comes first, and is the fallback', () {
      // Order is also the order the language selector offers.
      expect(AppLocales.supported.first, AppLocales.arabic);
      expect(AppLocales.fallback, AppLocales.arabic);
      expect(AppLocales.supported, contains(AppLocales.fallback));
    });

    test('isSupported matches the shipped set', () {
      expect(AppLocales.isSupported('ar'), isTrue);
      expect(AppLocales.isSupported('fr'), isTrue);
      expect(AppLocales.isSupported('en'), isFalse);
      expect(AppLocales.isSupported(''), isFalse);
    });
  });
}

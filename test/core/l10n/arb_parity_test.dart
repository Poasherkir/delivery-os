import 'dart:convert';
import 'dart:io';

import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String languageCode) =>
    jsonDecode(File('lib/core/l10n/app_$languageCode.arb').readAsStringSync())
        as Map<String, dynamic>;

/// Translatable keys: everything that is not `@@locale` metadata or an
/// `@key` description block.
Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((String k) => !k.startsWith('@')).toSet();

void main() {
  final Map<String, Map<String, dynamic>> bundles =
      <String, Map<String, dynamic>>{
        for (final locale in AppLocales.supported)
          locale.languageCode: _arb(locale.languageCode),
      };

  test('every shipped locale has an ARB file', () {
    // If a locale is added to AppLocales.supported without a bundle, the app
    // would fall back silently at runtime. Fail at build time instead.
    expect(bundles.keys, AppLocales.supported.map((l) => l.languageCode));
  });

  test('each ARB declares the locale its filename claims', () {
    bundles.forEach((String code, Map<String, dynamic> arb) {
      expect(arb['@@locale'], code);
    });
  });

  test('no locale is missing a key another locale has', () {
    // The failure this prevents is silent: a missing key falls back to the
    // template language, so an Arabic screen quietly renders one French word.
    final Set<String> union = <String>{
      for (final Map<String, dynamic> arb in bundles.values)
        ..._messageKeys(arb),
    };

    bundles.forEach((String code, Map<String, dynamic> arb) {
      expect(
        union.difference(_messageKeys(arb)),
        isEmpty,
        reason: 'app_$code.arb is missing keys',
      );
    });
  });

  test('no value is blank', () {
    bundles.forEach((String code, Map<String, dynamic> arb) {
      for (final String key in _messageKeys(arb)) {
        expect(
          (arb[key] as String).trim(),
          isNotEmpty,
          reason: '$key is empty in app_$code.arb',
        );
      }
    });
  });

  test('the template documents every key', () {
    // Descriptions are developer-facing and only required in the template, but
    // they are required: an undocumented key gets mistranslated.
    final Map<String, dynamic> template = bundles['fr']!;
    for (final String key in _messageKeys(template)) {
      expect(
        template.containsKey('@$key'),
        isTrue,
        reason: '$key has no @$key description in the template ARB',
      );
    }
  });
}

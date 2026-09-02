import 'dart:io';

import 'package:test/test.dart';

/// Nothing this app needs at runtime may arrive over the network.
///
/// The network ban in `CLAUDE.md` forbids an HTTP client in our own code, and
/// `no_network_test` covers that. This covers the other door: a dependency that
/// fetches something on first use. A driver scans their first parcel standing
/// in an agency with no signal, and a scanner that answers by downloading a
/// model is a scanner that does not work.
void main() {
  group('the barcode model ships inside the APK', () {
    // mobile_scanner offers a bundled model and an unbundled one that Play
    // Services downloads on demand. Bundled is already its default, which is
    // exactly why this is asserted: getting it right because a package default
    // happens to agree with us is not a decision, and a default can change in a
    // minor version without anything failing.
    late String properties;

    setUpAll(() {
      final File file = File('android/gradle.properties');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'android/gradle.properties is missing; this guard cannot run',
      );
      properties = file.readAsStringSync();
    });

    test('useUnbundled is pinned false, not merely left unset', () {
      expect(
        properties,
        contains('dev.steenbakker.mobile_scanner.useUnbundled=false'),
        reason:
            'the bundled MLKit model must be pinned explicitly. Unset means '
            'inheriting a default, and the unbundled variant downloads the '
            'model on first use — which is the one moment a driver has no '
            'signal.',
      );
    });

    test('and is never set true', () {
      // Belt and braces: a second line later in the file would win, and the
      // `contains` above would still pass.
      expect(
        properties,
        isNot(contains('useUnbundled=true')),
        reason: 'the unbundled model requires a network fetch on first scan',
      );
    });
  });

  group('no HTTP client is declared', () {
    // The M4 carve-out is the Mapbox Matrix API and nothing else. Until then a
    // client in pubspec is a client somebody will eventually call.
    late String pubspec;

    setUpAll(() => pubspec = File('pubspec.yaml').readAsStringSync());

    test('not http, dio, chopper or anything like them', () {
      final List<String> found = <String>[
        for (final String package in <String>[
          'http:',
          'dio:',
          'chopper:',
          'retrofit:',
          'web_socket_channel:',
          'grpc:',
        ])
          if (RegExp('^\\s+$package', multiLine: true).hasMatch(pubspec))
            package,
      ];

      expect(
        found,
        isEmpty,
        reason:
            'no HTTP client of any kind before M4, when exactly one arrives '
            'for the Mapbox Matrix API: ${found.join(', ')}',
      );
    });
  });
}

import 'dart:io';

import 'package:test/test.dart';

/// The permissions this app is allowed to declare, and nothing else.
///
/// Each entry is a deliberate, reviewable line in a diff — which is the whole
/// point, because invariant 11 is not "no permissions forever". It is
/// "background location and geofencing never arrive quietly".
///
/// Still expected, so nobody treats a future failure as the guard being wrong:
///
/// * `android.permission.ACCESS_FINE_LOCATION` and
///   `android.permission.FOREGROUND_SERVICE_LOCATION` at M4, foreground only
///   and only while a route is active.
///
/// What must never appear, in any milestone:
/// `ACCESS_BACKGROUND_LOCATION`. That is invariant 11, and it is listed
/// separately below so its absence is asserted rather than merely implied by
/// the allowlist.
const Set<String> allowedPermissions = <String>{
  // M1-07, the barcode scanner. Frames are read for a barcode and discarded;
  // nothing is written to storage.
  'android.permission.CAMERA',
};

/// Permissions that are a design violation regardless of what the allowlist
/// says. Adding one of these to [allowedPermissions] would not be enough — this
/// list has to be edited too, which makes it a two-place decision.
const Set<String> forbiddenPermissions = <String>{
  'android.permission.ACCESS_BACKGROUND_LOCATION',
  'android.permission.ACCESS_MEDIA_LOCATION',
  'android.permission.READ_SMS',
  'android.permission.READ_CONTACTS',
  'android.permission.READ_PHONE_STATE',
};

const String _manifest = 'android/app/src/main/AndroidManifest.xml';

void main() {
  late Set<String> declared;

  setUpAll(() {
    final File file = File(_manifest);
    expect(
      file.existsSync(),
      isTrue,
      reason: '$_manifest is missing; this guard cannot run',
    );

    // A deliberately blunt parse. An XML reader would be more correct and would
    // also make this test depend on a package, and the shape being matched is
    // fixed by the Android tooling.
    declared = RegExp(r'<uses-permission[^>]*android:name="([^"]+)"')
        .allMatches(file.readAsStringSync())
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();
  });

  test('every declared permission is on the allowlist', () {
    final Set<String> unexpected = declared.difference(allowedPermissions);

    expect(
      unexpected,
      isEmpty,
      reason:
          'these permissions are declared but not allowed: '
          '${unexpected.join(', ')}. If one is genuinely needed, add it to '
          'allowedPermissions in this file — that line is the review.',
    );
  });

  test('the allowlist has not drifted ahead of the manifest', () {
    // An allowlist entry with no matching declaration is a permission somebody
    // planned for and never used, or removed and forgot to un-allow. Either way
    // the list stops describing reality, which is how an allowlist rots into a
    // formality.
    final Set<String> stale = allowedPermissions.difference(declared);

    expect(
      stale,
      isEmpty,
      reason:
          'allowed but not declared: ${stale.join(', ')}. Remove it, or the '
          'allowlist stops meaning what it says.',
    );
  });

  test('no forbidden permission appears anywhere in the manifest', () {
    // Checked against the raw text, not the parsed set, so a commented-out or
    // oddly-formatted declaration still trips it.
    final String raw = File(_manifest).readAsStringSync();
    final List<String> found = <String>[
      for (final String p in forbiddenPermissions)
        if (raw.contains(p)) p,
    ];

    expect(
      found,
      isEmpty,
      reason:
          'invariant 11 and §13: ${found.join(', ')} must never be declared. '
          'Background location is a deliberate exclusion, not an oversight.',
    );
  });

  test('no service or receiver that could run location in the background', () {
    // The other half of invariant 11. A foreground service with a location type
    // is how background tracking arrives without the permission name appearing.
    final String raw = File(_manifest).readAsStringSync();

    expect(
      raw.contains('foregroundServiceType'),
      isFalse,
      reason: 'a foreground service type is declared; invariant 11 forbids it',
    );
    expect(
      raw.contains('<receiver'),
      isFalse,
      reason:
          'a broadcast receiver is declared, which is how background work '
          'usually arrives. If one is genuinely needed, this guard needs a '
          'deliberate exemption.',
    );
  });
}

import 'dart:io';

import 'package:test/test.dart';

// **Every screen has something that measures its tap targets.**
//
// Converting the second rule `CLAUDE.md` marked convertible. The minimum is
// 48dp because the driver is tapping one-handed while holding a parcel, and
// it was enforced per screen by whoever remembered — which held for eight
// screens and would not have held for the ninth.
//
// **What this checks and what it does not.** It does not measure anything: a
// static scan cannot render a widget. It guarantees that every screen *has* a
// test that measures, which is the half that was missing. The measuring lives
// in the per-screen tests, where it can be specific about which control
// matters — the next action being the largest thing on screen is a claim only
// that screen's test can make.
//
// Two halves, and neither works alone, the same shape as `outbox_guard_test`:
//
// 1. **A scan** finds every screen and sheet under `features/`. The subject
//    set is discovered rather than listed, so a new screen cannot escape by
//    not being added anywhere.
// 2. **A registry** below says, for each, which test measures it — or states
//    why it has nothing to measure. A scanned screen missing from the
//    registry fails by name.
//
// The scan alone could be satisfied by a file that mentions 48 in a comment.
// The registry alone is a list a new screen never joins. Together they fail
// closed.

/// Where the measuring happens, per screen.
///
/// A path under `test/` means that file measures this screen's tap targets.
/// Several screens share one file, which is fine — what matters is that
/// something covers each.
const Map<String, String> measuredBy = <String, String>{
  'companies_screen.dart': 'test/widget/company_form_screen_test.dart',
  'company_form_screen.dart': 'test/widget/company_form_screen_test.dart',
  'customer_form_screen.dart': 'test/widget/customers_screen_test.dart',
  'customer_profile_screen.dart':
      'test/widget/customer_profile_screen_test.dart',
  'customers_screen.dart': 'test/widget/customers_screen_test.dart',
  'database_error_screen.dart': 'test/widget/database_error_screen_test.dart',
  'order_entry_screen.dart': 'test/widget/order_entry_screen_test.dart',
  'orders_screen.dart': 'test/widget/orders_screen_test.dart',
  'scanner_screen.dart': 'test/widget/scanner_screen_test.dart',
  'settings_screen.dart': 'test/widget/settings_screen_test.dart',
};

/// Screens with nothing to measure, each with the reason.
///
/// Adding a name here is a deliberate, reviewable line — the same shape as the
/// Android permission allowlist. A placeholder that grows a button has to be
/// moved out of this map, and the diff is the review.
const Map<String, String> nothingToMeasure = <String, String>{
  'home_screen.dart': 'placeholder: renders SizedBox.expand, no controls',
  'history_screen.dart': 'placeholder: renders SizedBox.expand, no controls',
  'money_screen.dart': 'placeholder: renders SizedBox.expand, no controls',
  'route_screen.dart': 'placeholder: renders SizedBox.expand, no controls',
  'token_gallery_screen.dart':
      'debug only, behind kDebugMode and tree-shaken out of a release build. '
      'It is a specimen sheet for reading tokens, not a screen a driver taps',

  // The two below are covered by the flows that own them rather than by a
  // test of their own, and neither currently measures. Named here rather
  // than left out, so the gap is visible instead of implied by absence.
  'database_reset_screen.dart':
      'TODO(M2): reachable only from the unreadable-database screen and '
      'covered functionally by database_reset_flow_test, which does not '
      'measure. Its hold-to-delete control is deliberately large',
  'more_screen.dart':
      'TODO(M2): a plain ListTile list at Material defaults. router_test '
      'measures the bottom bar it sits behind but not these rows',
  'commune_picker_sheet.dart':
      'TODO(M2): its rows set minTileHeight 56 explicitly; the sheet has no '
      'test of its own yet and is exercised through the entry form',
};

void main() {
  late List<File> screens;

  setUpAll(() {
    final Directory features = Directory('lib/features');
    expect(
      features.existsSync(),
      isTrue,
      reason: 'lib/features is missing; this guard cannot run',
    );

    screens = features
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (File f) =>
              f.path.endsWith('_screen.dart') || f.path.endsWith('_sheet.dart'),
        )
        .toList();

    expect(
      screens,
      isNotEmpty,
      reason: 'the scan found no screens at all, so it proved nothing',
    );
  });

  test('every screen is either measured or explicitly exempt', () {
    final List<String> unaccounted = <String>[
      for (final File screen in screens)
        if (!measuredBy.containsKey(_name(screen)) &&
            !nothingToMeasure.containsKey(_name(screen)))
          _name(screen),
    ];

    expect(
      unaccounted,
      isEmpty,
      reason:
          'these screens have nothing asserting their tap targets: '
          '${unaccounted.join(', ')}. Add a test that measures them and list '
          'it in measuredBy, or add them to nothingToMeasure with the reason '
          '— that line is the review. The minimum is 48dp because the driver '
          'is tapping one-handed while holding a parcel.',
    );
  });

  test('and the registry has not drifted ahead of the screens', () {
    // A registry entry naming a screen that no longer exists is a claim about
    // nothing. Same failure as an allowlist that stops describing reality.
    final Set<String> present = screens.map(_name).toSet();
    final Set<String> stale = <String>{
      ...measuredBy.keys,
      ...nothingToMeasure.keys,
    }..removeAll(present);

    expect(
      stale,
      isEmpty,
      reason:
          'registered but no longer present: ${stale.join(', ')}. Remove the '
          'entry, or the registry stops meaning what it says.',
    );
  });

  test('and no screen is in both maps', () {
    // "Measured" and "nothing to measure" cannot both be true, and a screen in
    // both would satisfy the coverage test while its exemption quietly excused
    // whatever the measurement failed to check.
    final Set<String> both = measuredBy.keys.toSet()
      ..retainAll(nothingToMeasure.keys);

    expect(
      both,
      isEmpty,
      reason: 'both measured and exempt: ${both.join(', ')}',
    );
  });

  test('every named test file exists and actually measures', () {
    // The half that stops this from being a list of good intentions. A named
    // file that does not assert a size is a registry entry that proves
    // nothing — which is what "partial" meant before this guard existed.
    final List<String> notMeasuring = <String>[];

    for (final MapEntry<String, String> entry in measuredBy.entries) {
      final File file = File(entry.value);
      if (!file.existsSync()) {
        notMeasuring.add('${entry.value} (missing)');
        continue;
      }
      if (!file.readAsStringSync().contains('greaterThanOrEqualTo(48)')) {
        notMeasuring.add('${entry.value} (no 48dp assertion)');
      }
    }

    expect(
      notMeasuring,
      isEmpty,
      reason:
          'these files are named as measuring a screen but do not: '
          '${notMeasuring.join(', ')}',
    );
  });
}

String _name(File file) => file.uri.pathSegments.last;

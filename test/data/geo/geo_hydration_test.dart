import 'dart:io';

import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/geo/bundled_geo_assets.dart';
import 'package:delivery_os/data/geo/geo_hydration.dart';
import 'package:delivery_os/data/geo/geo_loader.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves whatever it is given, and counts how often the expensive half is
/// read. The commune file is the one that costs real time on a cold start.
final class _FakeAssets implements GeoAssetSource {
  _FakeAssets({required this.wilayas, required this.communes});

  String wilayas;
  String communes;
  int communeReads = 0;

  @override
  Future<String> wilayasJson() async => wilayas;

  @override
  Future<String> communesJson() async {
    communeReads++;
    return communes;
  }
}

String _read(String name) => File('assets/geo/$name').readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SharedPreferences prefs;
  late _FakeAssets assets;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    assets = _FakeAssets(
      wilayas: _read('wilayas.json'),
      communes: _read('communes.json'),
    );
  });

  tearDown(() => db.close());

  GeoHydration hydration() => GeoHydration(assets: assets, preferences: prefs);

  Future<int> countWilayas() async =>
      (await db.customSelect('SELECT count(*) c FROM wilayas').getSingle())
          .read<int>('c');

  group('the bundled asset', () {
    // Version-agnostic on purpose: this must keep passing when the fixture is
    // replaced by the real dataset. The check that the fixture does not ship
    // in a release is a CI step, not a test — a test asserting the version is
    // not `fixture-` would fail today, which is when the fixture is what is
    // bundled.
    test('parses and loads', () async {
      final GeoLoadReport? report = await hydration().ensureLoaded(db);

      expect(report, isNotNull);
      expect(report!.wilayasWritten, greaterThan(0));
      expect(report.communesWritten, greaterThan(0));
      expect(await countWilayas(), report.wilayasWritten);
    });

    test('is declared in pubspec, both files', () {
      // A file present on disk but undeclared loads in a test and throws on a
      // device, which is the worst place to find out.
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains(BundledGeoAssets.wilayasPath));
      expect(pubspec, contains(BundledGeoAssets.communesPath));
    });

    test('records the version it loaded', () async {
      await hydration().ensureLoaded(db);

      expect(prefs.getString(GeoHydration.storageKey), isNotEmpty);
    });
  });

  group('a second launch does nothing', () {
    test('and does not even read the commune file', () async {
      // The reason peekVersion exists. Re-parsing ~1,541 communes and their
      // polygons on every cold start would be the most expensive thing startup
      // does, for no result.
      await hydration().ensureLoaded(db);
      final int readsAfterFirst = assets.communeReads;

      final GeoLoadReport? second = await hydration().ensureLoaded(db);

      expect(second, isNull, reason: 'it loaded again with nothing to do');
      expect(
        assets.communeReads,
        readsAfterFirst,
        reason: 'the expensive file was read on a launch with no work',
      );
    });

    test('and the table is untouched', () async {
      await hydration().ensureLoaded(db);
      final int before = await countWilayas();

      await hydration().ensureLoaded(db);

      expect(await countWilayas(), before);
    });
  });

  group('a new dataset version loads', () {
    test('when the version changes', () async {
      await hydration().ensureLoaded(db);

      assets
        ..wilayas = assets.wilayas.replaceAll('fixture-1', 'fixture-2')
        ..communes = assets.communes.replaceAll('fixture-1', 'fixture-2');

      final GeoLoadReport? report = await hydration().ensureLoaded(db);

      expect(report, isNotNull);
      expect(prefs.getString(GeoHydration.storageKey), 'fixture-2');
    });
  });

  group('preferences and the database can disagree', () {
    test('an empty table reloads even when the version matches', () async {
      // The condition that is easy to miss. A reset destroys the database and
      // leaves preferences untouched, so trusting the stored version alone
      // would leave a driver with a silently empty commune picker and no error
      // anywhere — the app certain it had already loaded a dataset that no
      // longer exists.
      await hydration().ensureLoaded(db);
      final String version = prefs.getString(GeoHydration.storageKey)!;

      // Exactly what a reset leaves behind: fresh tables, stale marker.
      await db.customStatement('DELETE FROM communes');
      await db.customStatement('DELETE FROM wilayas');
      expect(await countWilayas(), 0);
      expect(prefs.getString(GeoHydration.storageKey), version);

      final GeoLoadReport? report = await hydration().ensureLoaded(db);

      expect(report, isNotNull, reason: 'it trusted the marker over the table');
      expect(await countWilayas(), greaterThan(0));
    });
  });

  group('a failed load leaves no marker', () {
    test('so the next launch tries again', () async {
      // The version is written after the load succeeds. Recording work that did
      // not finish would make the failure permanent and silent.
      assets.communes = '{ not json';

      await expectLater(hydration().ensureLoaded(db), throwsA(anything));

      expect(prefs.getString(GeoHydration.storageKey), isNull);
      expect(await countWilayas(), 0);
    });

    test('and a broken commune file does not half-load the wilayas', () async {
      // GeoLoader runs in one transaction, so this is really a check that the
      // parse happens before any write — a half-loaded geography table is a
      // picker that silently omits provinces.
      assets.communes = assets.communes.replaceAll(
        '"wilaya": 16',
        '"wilaya": 99',
      );

      await expectLater(hydration().ensureLoaded(db), throwsA(anything));

      expect(await countWilayas(), 0);
    });
  });
}

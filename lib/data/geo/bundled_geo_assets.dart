import 'package:flutter/services.dart' show rootBundle;

import 'geo_hydration.dart';

/// The geography files shipped inside the APK.
///
/// Kept in its own file because `rootBundle` is Flutter and does not run on the
/// test host — the same split as `database_location.dart`. Everything that
/// decides *whether* to load lives in `GeoHydration` and is testable; this only
/// answers what the files say.
///
/// **These currently hold the three-wilaya fixture.** It is real data for three
/// wilayas rather than invented rows, and it is bundled so the startup path can
/// be exercised end to end on a device before the real dataset exists. Which
/// wilaya structure the real file should use — 58 or 69 — is a carrier
/// question, settled from a real bordereau rather than from the Journal
/// Officiel (§1.5). A CI step blocks any release build whose bundled version
/// still starts with `fixture-`.
final class BundledGeoAssets implements GeoAssetSource {
  const BundledGeoAssets();

  static const String wilayasPath = 'assets/geo/wilayas.json';
  static const String communesPath = 'assets/geo/communes.json';

  @override
  Future<String> wilayasJson() => rootBundle.loadString(wilayasPath);

  @override
  Future<String> communesJson() => rootBundle.loadString(communesPath);
}

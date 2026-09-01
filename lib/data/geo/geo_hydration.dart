import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import 'geo_dataset.dart';
import 'geo_loader.dart';

/// Where the bundled geography files come from.
///
/// An interface because reading them uses `rootBundle`, which is Flutter and
/// does not run on the test host. Everything that *decides* whether to load
/// lives below and is testable; this only answers "what do the files say".
abstract interface class GeoAssetSource {
  Future<String> wilayasJson();

  Future<String> communesJson();
}

/// Loads the bundled geography into the database, at most once per dataset.
///
/// Runs on every launch and usually does nothing. `GeoLoader.load` is
/// idempotent, so re-running it would be *correct* — it would also re-parse
/// ~1,541 communes and their polygons on every cold start, which is the single
/// most expensive thing startup could do, for no result.
final class GeoHydration {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named. Same shape as the other
  /// collaborators in this layer.
  factory GeoHydration({
    required GeoAssetSource assets,
    required SharedPreferences preferences,
  }) => GeoHydration._(assets, preferences);

  const GeoHydration._(this._assets, this._prefs);

  final GeoAssetSource _assets;
  final SharedPreferences _prefs;

  /// The dataset version last loaded successfully.
  static const String storageKey = 'geo.dataset.version';

  /// Loads if there is anything to load. Returns null when there is not.
  ///
  /// **Two conditions, and the second is the one that is easy to miss.** The
  /// version having changed is the obvious trigger. The other is the table
  /// being empty: preferences and the database can disagree, because a reset
  /// destroys the database and leaves preferences untouched. Trusting the
  /// stored version alone would leave a driver with a commune picker that is
  /// silently empty and no error anywhere — the app would be certain it had
  /// already loaded a dataset that no longer exists.
  ///
  /// The version is written *after* the load succeeds. A crash mid-load leaves
  /// the marker unset, so the next launch tries again rather than recording
  /// work that did not finish.
  Future<GeoLoadReport?> ensureLoaded(AppDatabase database) async {
    final String wilayasJson = await _assets.wilayasJson();
    final String version = GeoDataset.peekVersion(wilayasJson);

    if (_prefs.getString(storageKey) == version &&
        await _hasAnyWilaya(database)) {
      return null;
    }

    final GeoDataset dataset = GeoDataset.parse(
      wilayasJson: wilayasJson,
      communesJson: await _assets.communesJson(),
    );

    final GeoLoadReport report = await GeoLoader(database).load(dataset);
    await _prefs.setString(storageKey, dataset.version);
    return report;
  }

  /// Counts nothing, only asks whether anything is there. `SELECT count(*)`
  /// over 1,541 rows on every cold start is work with one bit of result.
  Future<bool> _hasAnyWilaya(AppDatabase database) async {
    final QueryRow? row = await database
        .customSelect('SELECT 1 AS present FROM wilayas LIMIT 1')
        .getSingleOrNull();
    return row != null;
  }
}

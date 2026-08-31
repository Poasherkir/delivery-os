import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'geo_dataset.dart';

/// What a load changed. Returned so a caller can log it and a test can assert
/// it without re-querying.
final class GeoLoadReport {
  const GeoLoadReport({
    required this.wilayasWritten,
    required this.communesWritten,
    required this.wilayasRetired,
    required this.communesRetired,
  });

  final int wilayasWritten;
  final int communesWritten;

  /// Rows already in the table that the incoming dataset no longer lists.
  final int wilayasRetired;
  final int communesRetired;

  bool get retiredAnything => wilayasRetired > 0 || communesRetired > 0;

  @override
  String toString() =>
      'GeoLoadReport(wilayas: $wilayasWritten written, $wilayasRetired '
      'retired; communes: $communesWritten written, $communesRetired retired)';
}

/// Hydrates the bundled geography into the database.
///
/// **Never deletes.** Administrative reform merges and renames both tables, and
/// `customer_addresses` holds foreign keys into them, so deleting a row that a
/// real address points at would orphan it. A loader that decided which rows are
/// safe to delete would carry a partial-delete policy nobody can hold in their
/// head — so it does not have one. Everything incoming is upserted; everything
/// absent is retired.
///
/// **Writes no outbox row, and that is not an oversight.** Invariant 5 covers
/// *mutations* — things the driver did, which a server will one day need to be
/// told about. This is neither. `wilayas` and `communes` are bundled reference
/// data (invariant 3, category 3): they ship inside the APK, they are not the
/// driver's data, and they never sync. A queued `wilaya.update` would be a
/// command asking a server to accept a copy of a file it shipped itself.
///
/// The same reasoning as `AppBootstrap.ensureUser`, written out here rather
/// than cross-referenced because the M0 gate's invariant-5 audit found this
/// exact gap: the documented case had an answer and the undocumented one had a
/// question. A test named `loading is not a mutation` pins it.
final class GeoLoader {
  const GeoLoader(this._db);

  final AppDatabase _db;

  /// Applies [dataset], in one transaction.
  ///
  /// Idempotent: loading the same dataset twice leaves the same table. A row
  /// that was retired and reappears in a later dataset comes back un-retired,
  /// which falls out of the upsert rather than needing its own pass.
  ///
  /// **Retire everything, then un-retire what the dataset lists.** The obvious
  /// shape — "retire the rows whose key is not in this list" — needs the whole
  /// key set inside the statement, and there is no good way to put it there.
  /// Binding roughly 1541 commune ids runs into `SQLITE_MAX_VARIABLE_NUMBER`,
  /// which is 999 on some builds, so it would pass against a small fixture and
  /// fail on the real dataset. Interpolating them as literals avoids that and
  /// introduces a worse habit: string-built SQL that is safe here only because
  /// these particular values happen to be parsed integers.
  ///
  /// A blanket `UPDATE ... SET is_retired = 1` takes no parameters at all, and
  /// the upserts that follow restore every current row. The transaction is what
  /// makes the intermediate state safe — there is no moment any reader can
  /// observe in which everything is retired.
  Future<GeoLoadReport> load(GeoDataset dataset) {
    return _db.transaction(() async {
      // Captured before anything moves, so the report can say what this load
      // actually retired rather than what the table happens to hold. Counting
      // retired rows before and after would go wrong the moment a load
      // un-retires something.
      final Set<int> wilayasLiveBefore = await _liveKeys('wilayas', 'code');
      final Set<int> communesLiveBefore = await _liveKeys('communes', 'id');

      await _retireAll('wilayas');
      await _retireAll('communes');

      for (final WilayaRecord w in dataset.wilayas) {
        await _db
            .into(_db.wilayas)
            .insertOnConflictUpdate(
              WilayasCompanion.insert(
                code: Value<int>(w.code),
                nameFr: w.nameFr,
                nameAr: w.nameAr,
                latitude: Value<double?>(w.point?.latitude),
                longitude: Value<double?>(w.point?.longitude),
                geohash: Value<String?>(w.geohash),
                // Present in the dataset means current, always. This is what
                // un-retires a row that comes back.
                isRetired: const Value<bool>(false),
              ),
            );
      }

      for (final CommuneRecord c in dataset.communes) {
        await _db
            .into(_db.communes)
            .insertOnConflictUpdate(
              CommunesCompanion.insert(
                id: Value<int>(c.id),
                wilayaCode: c.wilayaCode,
                nameFr: c.nameFr,
                nameAr: c.nameAr,
                latitude: Value<double?>(c.point?.latitude),
                longitude: Value<double?>(c.point?.longitude),
                geohash: Value<String?>(c.geohash),
                boundary: Value<String?>(c.boundary),
                isRetired: const Value<bool>(false),
              ),
            );
      }

      // Whatever was live before and is not live now was retired by this load.
      final Set<int> wilayasLiveAfter = await _liveKeys('wilayas', 'code');
      final Set<int> communesLiveAfter = await _liveKeys('communes', 'id');

      return GeoLoadReport(
        wilayasWritten: dataset.wilayas.length,
        communesWritten: dataset.communes.length,
        wilayasRetired: wilayasLiveBefore.difference(wilayasLiveAfter).length,
        communesRetired: communesLiveBefore
            .difference(communesLiveAfter)
            .length,
      );
    });
  }

  /// Marks every row in [table] retired. No parameters, nothing interpolated.
  ///
  /// [table] is one of two literals chosen in this file, never anything that
  /// came from a dataset.
  Future<void> _retireAll(String table) => _db.customStatement(
    'UPDATE $table SET is_retired = 1 WHERE is_retired = 0',
  );

  /// The keys of every row not currently retired.
  Future<Set<int>> _liveKeys(String table, String keyColumn) async {
    final List<QueryRow> rows = await _db
        .customSelect('SELECT $keyColumn AS k FROM $table WHERE is_retired = 0')
        .get();
    return <int>{for (final QueryRow row in rows) row.read<int>('k')};
  }
}

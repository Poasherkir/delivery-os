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
final class GeoLoader {
  const GeoLoader(this._db);

  final AppDatabase _db;

  /// Applies [dataset], in one transaction.
  ///
  /// Idempotent: loading the same dataset twice leaves the same table. A row
  /// that was retired and reappears in a later dataset comes back un-retired,
  /// which falls out of the upsert rather than needing its own pass.
  Future<GeoLoadReport> load(GeoDataset dataset) {
    return _db.transaction(() async {
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

      final int wilayasRetired = await _retire(
        table: 'wilayas',
        keyColumn: 'code',
        keep: <int>[for (final WilayaRecord w in dataset.wilayas) w.code],
      );
      final int communesRetired = await _retire(
        table: 'communes',
        keyColumn: 'id',
        keep: <int>[for (final CommuneRecord c in dataset.communes) c.id],
      );

      return GeoLoadReport(
        wilayasWritten: dataset.wilayas.length,
        communesWritten: dataset.communes.length,
        wilayasRetired: wilayasRetired,
        communesRetired: communesRetired,
      );
    });
  }

  /// Marks every row outside [keep] retired, and returns how many changed.
  ///
  /// The key list is inlined as literals rather than bound as variables on
  /// purpose. `SQLITE_MAX_VARIABLE_NUMBER` is 999 on some builds and there are
  /// roughly 1541 communes, so binding them would work in tests against a small
  /// fixture and fail on the real dataset — the worst possible place to find
  /// out. These are integers parsed by `GeoDataset`, never raw file text, so
  /// there is nothing to inject.
  Future<int> _retire({
    required String table,
    required String keyColumn,
    required List<int> keep,
  }) async {
    if (keep.isEmpty) {
      // GeoDataset rejects an empty list at parse time, so this is
      // unreachable — and it stays here because the alternative is emitting
      // `NOT IN ()`, which is a syntax error in the best case and a table-wide
      // retirement in the worst.
      return 0;
    }

    final String keys = keep.join(',');
    return _db.customUpdate(
      'UPDATE $table SET is_retired = 1 '
      'WHERE is_retired = 0 AND $keyColumn NOT IN ($keys)',
      updates: <TableInfo<Table, Object?>>{
        if (table == 'wilayas') _db.wilayas else _db.communes,
      },
    );
  }
}

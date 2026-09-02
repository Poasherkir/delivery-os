import 'package:drift/drift.dart';

import '../../domain/entities/place.dart' as domain;
import '../../domain/repositories/geography_repository.dart';
import '../db/app_database.dart' as db;

/// [GeographyRepository] against the bundled dataset in the local database.
final class DriftGeographyRepository implements GeographyRepository {
  const DriftGeographyRepository(this._db);

  final db.AppDatabase _db;

  @override
  Future<List<domain.Wilaya>> selectableWilayas() async {
    final List<db.Wilaya> rows =
        await (_db.select(_db.wilayas)
              ..where((db.$WilayasTable w) => w.isRetired.equals(false))
              // Code order, not alphabetical: the wilaya number is what every
              // carrier and every bordereau uses, so a driver looking for 16
              // scans for 16.
              ..orderBy(<OrderClauseGenerator<db.$WilayasTable>>[
                (db.$WilayasTable w) => OrderingTerm(expression: w.code),
              ]))
            .get();
    return rows.map(_wilaya).toList();
  }

  @override
  Future<List<domain.Commune>> selectableCommunes(int wilayaCode) async {
    final List<db.Commune> rows =
        await (_db.select(_db.communes)
              ..where(
                (db.$CommunesTable c) =>
                    c.wilayaCode.equals(wilayaCode) & c.isRetired.equals(false),
              )
              ..orderBy(<OrderClauseGenerator<db.$CommunesTable>>[
                (db.$CommunesTable c) => OrderingTerm(expression: c.nameFr),
              ]))
            .get();
    return rows.map(_commune).toList();
  }

  @override
  Future<List<domain.Commune>> searchCommunes(
    String query, {
    int? wilayaCode,
  }) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return wilayaCode == null
          ? const <domain.Commune>[]
          : selectableCommunes(wilayaCode);
    }

    // Matches either name: a driver reading a French label off a parcel and a
    // driver typing Arabic have to find the same commune. `lower` is ASCII-only
    // in SQLite and therefore a no-op on Arabic, which is harmless — Arabic has
    // no case to fold.
    final String like = '%${trimmed.toLowerCase()}%';
    final List<db.Commune> rows =
        await (_db.select(_db.communes)
              ..where((db.$CommunesTable c) {
                final Expression<bool> matches =
                    c.nameFr.lower().like(like) | c.nameAr.like(like);
                final Expression<bool> live = c.isRetired.equals(false);
                return wilayaCode == null
                    ? matches & live
                    : matches & live & c.wilayaCode.equals(wilayaCode);
              })
              ..orderBy(<OrderClauseGenerator<db.$CommunesTable>>[
                (db.$CommunesTable c) => OrderingTerm(expression: c.nameFr),
              ])
              // A driver picks from a short list or refines the query. Returning
              // 1,541 rows to a phone that will render twelve of them is work
              // nobody sees.
              ..limit(50))
            .get();
    return rows.map(_commune).toList();
  }

  @override
  Future<domain.Wilaya?> wilayaByCode(int code) async {
    // No retirement filter, deliberately. This is the path that renders an
    // address recorded before an administrative reform.
    final db.Wilaya? row = await (_db.select(
      _db.wilayas,
    )..where((db.$WilayasTable w) => w.code.equals(code))).getSingleOrNull();
    return row == null ? null : _wilaya(row);
  }

  @override
  Future<domain.Commune?> communeById(int id) async {
    final db.Commune? row = await (_db.select(
      _db.communes,
    )..where((db.$CommunesTable c) => c.id.equals(id))).getSingleOrNull();
    return row == null ? null : _commune(row);
  }

  domain.Wilaya _wilaya(db.Wilaya row) => domain.Wilaya(
    code: row.code,
    nameFr: row.nameFr,
    nameAr: row.nameAr,
    isRetired: row.isRetired,
  );

  domain.Commune _commune(db.Commune row) => domain.Commune(
    id: row.id,
    wilayaCode: row.wilayaCode,
    nameFr: row.nameFr,
    nameAr: row.nameAr,
    isRetired: row.isRetired,
  );
}

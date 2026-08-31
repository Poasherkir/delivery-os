import 'package:drift/drift.dart';

/// Algeria's wilayas.
///
/// **Bundled reference data** — invariant 3, category 3. No audit columns at
/// all: this ships inside the APK, is not the driver's data, and never syncs.
/// It is replaced wholesale when the dataset is updated, not edited row by row.
///
/// No range constraint on [code], and no test asserting a row count. Algeria
/// went from 48 wilayas to 58 in 2019 and to 69 in 2025; a code is valid if and
/// only if it exists in this table (§1.5).
class Wilayas extends Table {
  IntColumn get code => integer()();

  TextColumn get nameFr => text().withLength(min: 1, max: 120)();

  TextColumn get nameAr => text().withLength(min: 1, max: 120)();

  /// Nullable: a dataset may ship names without coordinates, and a wilaya with
  /// no centroid is still a valid wilaya for the address picker. Better a
  /// usable list than no list.
  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  /// Precision-9 geohash of the centroid, for prefix proximity queries. SQLite
  /// has no PostGIS, so this is the index.
  TextColumn get geohash => text().nullable()();

  /// True when a dataset update no longer lists this row.
  ///
  /// **The loader never deletes.** Administrative reform merges and renames
  /// wilayas — 48 became 58 in 2019 and 69 in 2025 — and `customer_addresses`
  /// holds foreign keys into this table. Deleting a row that a real customer
  /// address points at would orphan it, and a loader that had to decide which
  /// rows are safe to delete would carry a partial-delete policy nobody can
  /// hold in their head.
  ///
  /// So retirement is a state rather than an absence, with defined behaviour on
  /// each side:
  ///
  /// * **Pickers and search filter on `is_retired = false`** — nobody gets
  ///   offered a wilaya that no longer exists.
  /// * **Lookups by id ignore it entirely** — an address pointing at a merged
  ///   wilaya still resolves and still renders its name, so old orders stay
  ///   readable forever.
  ///
  /// Functional state, not an audit column: the same category as
  /// `matrix_cache.fetched_at`, so it does not disturb invariant 3's
  /// bundled-reference-data rule that this table carries no audit columns.
  BoolColumn get isRetired => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{code};
}

/// Algeria's communes, roughly 1541 of them.
///
/// Bundled reference data, like [Wilayas]. Integer primary key rather than a
/// UUID: these ids come from the national nomenclature and are not ours to
/// mint, and invariant 2 is about rows this app creates offline.
class Communes extends Table {
  IntColumn get id => integer()();

  IntColumn get wilayaCode => integer().references(Wilayas, #code)();

  TextColumn get nameFr => text().withLength(min: 1, max: 120)();

  TextColumn get nameAr => text().withLength(min: 1, max: 120)();

  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  TextColumn get geohash => text().nullable()();

  /// GeoJSON polygon of the commune boundary. Nullable, and unused in M0.
  ///
  /// Point-in-polygon is the correct gate for promoting a captured pin to
  /// confidence 4 (§10.5, gate 2). A fixed radius from a centroid is not: an
  /// Algiers commune is a few square kilometres and a Saharan one is thousands,
  /// so no single radius serves both, and the centroid of a large desert
  /// commune can be tens of kilometres from every address in it.
  ///
  /// Present so the column exists if the bundled dataset carries boundaries. If
  /// it does not, nothing breaks and gate 2 degrades to a wilaya-scaled radius
  /// — weakest in the sparse south, where it matters least.
  TextColumn get boundary => text().nullable()();

  /// True when a dataset update no longer lists this commune. See
  /// [Wilayas.isRetired] for the full reasoning.
  ///
  /// Communes are where this earns its keep. The eleven wilayas created in
  /// November 2025 were carved out of existing ones, so commune *shapes* did
  /// not move but their *parent* did — a dataset predating the reform assigns
  /// them to a wilaya that no longer exists. Retiring rather than deleting is
  /// what lets the table absorb that without breaking a single stored address.
  BoolColumn get isRetired => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

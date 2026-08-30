import 'package:drift/drift.dart';

/// A recorded position, as SQLite can hold one.
///
/// The stand-in for `GEOGRAPHY(POINT,4326)`: SQLite has no PostGIS, so a point
/// is two reals plus a precision-9 geohash, prefix-queried for proximity. The
/// V2 Postgres equivalent is a `GEOGRAPHY` column with a GIST index.
///
/// All nullable. A customer address with no pin is the normal starting state —
/// that is confidence 0, and the whole point of the learned-pin geocoder is
/// that it fills in over time.
///
/// [accuracyM] is on the mixin rather than on each table for the same reason
/// the audit columns are: a table that records a GPS fix and forgets the radius
/// cannot recover it later, and promoting a 300-metre indoor fix to confidence
/// 4 poisons the one asset in this product that compounds (§10.5).
mixin GeoFixColumns on Table {
  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  /// Precision 9, roughly a 5-metre cell. Shorter prefixes are queried for
  /// coarser proximity.
  TextColumn get geohash => text().nullable()();

  /// The accuracy radius in metres that the platform reported with the fix.
  ///
  /// Captured at the moment of capture or not at all. Gate 3 of the pin
  /// promotion ladder: a fix taken indoors or in a stairwell can come back at
  /// 300 metres, and routing future deliveries from it degrades every route
  /// through that neighbourhood with nothing anywhere to notice. The threshold
  /// is an M2 decision made against real fixes in Algiers.
  IntColumn get accuracyM => integer().nullable()();
}

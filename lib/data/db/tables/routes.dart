import 'package:drift/drift.dart';

import '../../../domain/value_objects/route_status.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/owner_columns.dart';
import 'orders.dart';
import 'users.dart';

/// One day's driving.
///
/// **One route per driver per day, spanning every batch.** A driver working
/// three companies drives one route, not three (§2.1). Getting this wrong is
/// easy and expensive: it is the difference between an optimizer that sees the
/// whole day and one that solves three unrelated problems.
class Routes extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  /// `YYYY-MM-DD`. The business day, same convention as batches.
  TextColumn get serviceDate => text().withLength(min: 10, max: 10)();

  TextColumn get status => text()
      .map(
        const EnumTextConverter<RouteStatus>(RouteStatus.values, 'RouteStatus'),
      )
      .withDefault(const Constant('draft'))();

  /// Where the driver started. No accuracy radius: this is a chosen origin,
  /// not a measured fix, so [GeoFixColumns] would be the wrong shape.
  RealColumn get originLatitude => real().nullable()();

  RealColumn get originLongitude => real().nullable()();

  IntColumn get totalDistanceM => integer().nullable()();

  IntColumn get totalDurationS => integer().nullable()();

  IntColumn get optimizedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  IntColumn get startedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  IntColumn get completedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  /// Which solver produced the sequence: `dart-2opt-v1`, later `ortools-v1`.
  ///
  /// Recorded so a route that looks wrong months later can be attributed to
  /// the algorithm that built it rather than guessed at.
  TextColumn get algorithm => text().nullable()();
}

/// One stop on a route, pointing at the order to deliver there.
///
/// **A plan, not an outcome.** This table says which order is visited in what
/// position, when it is expected, and when the driver actually arrived and
/// left. What *happened* at the stop belongs to the order, which already holds
/// it — so there is deliberately no `status` column here. Two copies of one
/// fact drift apart, which is the same argument that keeps `settled` out of
/// `OrderStatus`.
///
/// Everything a route screen needs is derivable:
///
/// * **done** — the order has reached a batch-closing state
///   (`OrderStatus.closesTheBatch`)
/// * **current** — [arrivedAt] is set and [departedAt] is not
/// * **pending** — neither is set
///
/// "Skipped" looks route-only and is not persistent either: skipping a stop
/// triggers re-optimization, re-optimization replaces the stops wholesale, and
/// the old row is gone. Nothing needs to remember it.
///
/// If M4 turns up a genuine route-only state that timestamps cannot express,
/// adding a typed enum column then is cheap. Carrying an untyped one on the
/// chance that it might is not.
///
/// **Invariant 3's first exception**: `created_at` and `updated_at`, no
/// `version`, no soft delete, and no `owner_id`. Stops mutate — `arrived_at`,
/// `departed_at` — but they belong to their route rather than to the driver
/// directly, and re-optimization replaces a route's stops wholesale rather than
/// editing them one by one. A stop that is gone is gone with its route, so
/// there is nothing to tombstone and no version to reconcile.
class RouteStops extends Table with UuidPrimaryKey, RouteStopColumns {
  TextColumn get routeId => text()
      .withLength(min: 36, max: 36)
      .references(Routes, #id, onDelete: KeyAction.cascade)();

  TextColumn get orderId =>
      text().withLength(min: 36, max: 36).references(Orders, #id)();

  /// Position in the route, 1-based and unique within it.
  IntColumn get sequence => integer()();

  IntColumn get legDistanceM => integer().nullable()();

  IntColumn get legDurationS => integer().nullable()();

  /// Start time plus cumulative leg durations plus service time per stop
  /// (§10.1). Recomputed on every re-optimization.
  IntColumn get eta =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  IntColumn get arrivedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  IntColumn get departedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  /// A driver-locked stop keeps its index through re-optimization (§10.1).
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{routeId, sequence},
  ];
}

/// Cached travel-time and distance matrices, so re-optimization works offline.
///
/// **Invariant 3's fourth category, and the strictest one: no audit columns at
/// all, not even `owner_id`.** This is purgeable — droppable at any moment with
/// zero data loss, because everything in it can be refetched — and it must
/// never sync. It is not a record of anything.
///
/// The one column that looks like an audit column is [fetchedAt], and it is
/// not: it is functional state, the age the cache is expired against, not a
/// note about when a row was written.
class MatrixCache extends Table with UuidPrimaryKey {
  /// sha256 of the coordinate set, sorted and rounded to five decimals
  /// (§10.1). Rounding is what makes a re-optimization after one stop moves a
  /// few metres a cache hit rather than a paid request.
  TextColumn get pointHash => text().withLength(min: 64, max: 64)();

  /// Raw JSON. A cache of a provider response, stored as it arrived — parsing
  /// it into a typed model would tie the cache to today's shape, and the stakes
  /// of a mismatch here are only a cache miss.
  TextColumn get durations => text()();

  TextColumn get distances => text()();

  /// `mapbox`, `osrm`, `haversine`. Part of the key: the same coordinates
  /// answered by a different provider are a different result.
  TextColumn get provider => text().withLength(min: 1, max: 40)();

  IntColumn get fetchedAt => integer().map(const UtcMillisecondsConverter())();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{pointHash, provider},
  ];
}

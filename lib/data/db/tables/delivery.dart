import 'package:drift/drift.dart';

import '../../../domain/value_objects/delivery_attempt_outcome.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/geo_columns.dart';
import '../conventions/owner_columns.dart';
import 'orders.dart';
import 'users.dart';

/// What happened, each time the driver tried.
///
/// **Append-only** — invariant 3, category 2. An attempt is a fact about a
/// moment: never updated, never soft-deleted, because rewriting it would
/// rewrite what the driver actually did. These rows are the evidence behind
/// both the retour fee and the learned pin.
///
/// Returns are 15–25% of this business (§1.2). A parcel can be attempted across
/// several days, so the attempt history — not the order's current status — is
/// what explains why the money came out the way it did.
// No SQLite equivalent for §6.3's idx_attempts_geo (GiST). Prefix-query the
// geohash column instead.
class DeliveryAttempts extends Table
    with UuidPrimaryKey, AppendOnlyColumns, GeoFixColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get orderId => text()
      .withLength(min: 36, max: 36)
      .references(Orders, #id, onDelete: KeyAction.cascade)();

  /// 1-based, and unique per order.
  IntColumn get attemptNo => integer()();

  /// What happened at the door. A different axis from the order status: this
  /// records the moment, the status records where the parcel now stands.
  TextColumn get outcome => text().map(
    const EnumTextConverter<DeliveryAttemptOutcome>(
      DeliveryAttemptOutcome.values,
      'DeliveryAttemptOutcome',
    ),
  )();

  TextColumn get outcomeNote => text().nullable()();

  /// When the attempt happened, which is not when the row was written — a
  /// driver in a dead zone records it later. `created_at` is the write time;
  /// this is the truth, and it is what queries order by.
  IntColumn get occurredAt => integer().map(const UtcMillisecondsConverter())();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{orderId, attemptNo},
  ];
}

/// The photo and GPS fix taken at the moment of delivery.
///
/// Append-only, for the same reason as the attempts: this is evidence.
@DataClassName('DeliveryProof')
class ProofOfDelivery extends Table with UuidPrimaryKey, AppendOnlyColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get orderId => text()
      .withLength(min: 36, max: 36)
      .references(Orders, #id, onDelete: KeyAction.cascade)();

  /// App-private storage, never the gallery and never MediaStore (§13). A
  /// photo of a customer doorway is not something to hand to every app on the
  /// phone.
  TextColumn get photoPath => text().nullable()();

  /// V2. The column exists because adding it later means migrating live data;
  /// nothing in the MVP writes it.
  TextColumn get signaturePath => text().nullable()();

  /// No geohash here, unlike the attempts: nothing runs proximity queries on a
  /// proof photo. Latitude and longitude are the evidence that the driver was
  /// where they said they were.
  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  IntColumn get capturedAt => integer().map(const UtcMillisecondsConverter())();

  TextColumn get driverNote => text().nullable()();

  /// Dormant sync flag. POD photos upload lazily and on Wi-Fi (§11.4) — they
  /// are large, not needed for correctness, and uploading them over a metered
  /// Algerian connection mid-shift is hostile to the driver.
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
}

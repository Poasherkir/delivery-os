import 'package:drift/drift.dart';

import '../../../domain/value_objects/customer_risk_flag.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/geo_columns.dart';
import '../conventions/owner_columns.dart';
import 'geography.dart';
import 'users.dart';

/// A person who receives parcels.
///
/// **Permanent, and identified by phone.** Orders are transient; a customer
/// accumulates addresses, pins and history across every company the driver
/// works for. That accumulation is the product's compounding asset (§1.3): the
/// customer database *is* the geocoder, because Algerian addresses do not
/// geocode and learned pins keyed by phone number are the only accurate source.
// The identity path, and it must be instant: every order entry looks a
// customer up by normalized phone before anything else happens.
//
// A partial unique index rather than a table constraint, per §6.3. The
// difference is that a soft-deleted customer no longer blocks re-adding the
// same number — which a driver will do, and being refused by a row they
// cannot see would be inexplicable.
@TableIndex.sql(
  'CREATE UNIQUE INDEX idx_customers_owner_phone '
  'ON customers (owner_id, phone_e164) WHERE deleted_at IS NULL',
)
// No SQLite equivalent for §6.3's idx_customers_name_trgm (GIN + trigram).
// The answer here is an FTS5 virtual table, and it lands with customer name
// search in M1 rather than now: a virtual table and its sync triggers are
// real work and there is nothing to search yet.
class Customers extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  /// The identity key. Normalized to `+213XXXXXXXXX` on the way in, so every
  /// spelling of one number collapses to one row.
  TextColumn get phoneE164 => text().map(const PhoneE164Converter())();

  /// A second number for the same person. Normalized too, but not part of the
  /// identity: nothing joins or de-duplicates on it.
  TextColumn get phoneAlt =>
      text().map(const PhoneE164Converter()).nullable()();

  TextColumn get displayName => text().withLength(min: 1, max: 200)();

  TextColumn get notes => text().nullable()();

  /// Only ever set by a human. Nothing in the app infers this from delivery
  /// history — a customer who was out twice is not a problem customer, and a
  /// rule that decided otherwise would quietly build a blacklist nobody agreed
  /// to.
  TextColumn get riskFlag => text()
      .map(
        const EnumTextConverter<CustomerRiskFlag>(
          CustomerRiskFlag.values,
          'CustomerRiskFlag',
        ),
      )
      .withDefault(const Constant('none'))();

  IntColumn get totalOrders => integer().withDefault(const Constant(0))();

  IntColumn get totalDelivered => integer().withDefault(const Constant(0))();

  IntColumn get totalFailed => integer().withDefault(const Constant(0))();

  IntColumn get lastDeliveredAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();
}

/// Where a customer takes delivery, and how much the coordinate is trusted.
///
/// The learned-pin geocoder lives here. A pin starts at confidence 0 or 1 and
/// is raised by evidence — a driver placing it on the map, then a GPS fix taken
/// at the door on an actual delivery. It is only ever lowered deliberately, by
/// a correction that records why.
// Commune-scoped lookups, and the join the address picker leans on.
@TableIndex(name: 'idx_addr_commune', columns: {#communeId})
// No SQLite equivalent for §6.3's idx_addr_geo (GiST on the geography
// column). The geohash column is what replaces it: prefix queries at
// whatever precision the caller needs.
@DataClassName('CustomerAddress')
class CustomerAddresses extends Table
    with UuidPrimaryKey, OwnedMutableColumns, GeoFixColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get customerId => text()
      .withLength(min: 36, max: 36)
      .references(Customers, #id, onDelete: KeyAction.cascade)();

  IntColumn get wilayaCode => integer().references(Wilayas, #code)();

  IntColumn get communeId => integer().references(Communes, #id)();

  /// Free text: cité, bloc, étage. The part no geocoder will ever resolve.
  TextColumn get detail => text().nullable()();

  /// 0 none, 1 commune centroid, 2 geocoded, 3 driver-pinned, 4 GPS-confirmed.
  /// Invariant 9: a confidence-0 address is never routed.
  IntColumn get geoConfidence => integer()
      .map(const GeoConfidenceConverter())
      .withDefault(const Constant(0))();

  /// How the coordinate was obtained, for auditing the geocoder's quality.
  TextColumn get geoSource => text().nullable()();

  /// How many deliveries have confirmed this pin. The evidence behind the
  /// confidence tier.
  IntColumn get confirmedDeliveries =>
      integer().withDefault(const Constant(0))();

  /// "maison", "travail".
  TextColumn get label => text().nullable()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
}

import 'package:drift/drift.dart';

import '../conventions/audit_columns.dart';
import '../conventions/owner_columns.dart';
import 'users.dart';

/// A delivery company the driver works for.
///
/// An owned mutable entity: all five audit columns, soft delete, and a version
/// that `EntityStamper` bumps on every write.
///
/// A driver working two companies in one day has two batches and one route
/// (§2.1), so this is a first-class entity rather than a label on an order.
class Companies extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// App-private path, not a MediaStore URI (§13).
  TextColumn get logoPath => text().nullable()();

  /// Free text, and deliberately **not** a `PhoneE164`.
  ///
  /// This is dial-and-display data, never an identity key: nothing joins on it
  /// and nothing de-duplicates by it. Agencies hand out things like
  /// "0770 11 22 33 / 021 44 55 66", which is useful to a driver and not a
  /// phone number. Only `customers.phone_e164` — where duplicate detection
  /// actually depends on normalization — gets the converter.
  TextColumn get contactPhone => text().nullable()();

  TextColumn get notes => text().nullable()();

  /// Inactive companies stay in history but are hidden from pickers. Distinct
  /// from `deleted_at`, which means the row should not have existed.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

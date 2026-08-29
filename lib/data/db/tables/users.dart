import 'package:drift/drift.dart';

import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';

/// The driver.
///
/// Invariant 3's second exception: `created_at`, `updated_at`, `deleted_at`,
/// but no `owner_id` — this row *is* the owner — and no `version`, because an
/// account-less MVP has exactly one of them and nothing to reconcile.
///
/// Exactly one row exists, seeded at first launch (M0-21). Its id becomes the
/// `owner_id` on every other row, and at V2 sign-in the server adopts that same
/// UUID rather than issuing a new one, so every foreign key stays valid and the
/// migration is a no-op.
class Users extends Table with UuidPrimaryKey, UserColumns {
  /// Null until an account exists.
  ///
  /// The MVP has no signup, so requiring one would mean inventing a fake number
  /// and putting it in a unique identity column, where it would eventually be
  /// treated as real. SQLite permits many nulls in a unique index, so the
  /// constraint still holds once real numbers arrive at V2.
  TextColumn get phone =>
      text().map(const PhoneE164Converter()).nullable().unique()();

  TextColumn get displayName => text().withLength(min: 1, max: 120)();

  /// Language tag, `ar` or `fr`.
  ///
  /// Plain text rather than an enum converter, deliberately. A locale that this
  /// build no longer ships must degrade to "follow the device" rather than
  /// throw — dropping a language must not brick the app for whoever had it
  /// selected. `AppLocales.isSupported` decides; the column just stores.
  ///
  /// This is the value that *syncs* at V2. The value the first frame reads
  /// lives in shared preferences, because the encrypted database needs an async
  /// keystore round trip to open. Reconciling the two is M0-21's problem.
  TextColumn get locale =>
      text().withLength(min: 2, max: 8).withDefault(const Constant('ar'))();
}

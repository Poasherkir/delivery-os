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

  /// Null until the driver tells us their name.
  ///
  /// Same reasoning as [phone], and it matters for the same reason: there is no
  /// signup, so a non-null column would force `data/` to invent a placeholder,
  /// and a placeholder in a *display* field is one that eventually gets shown
  /// to someone. Null is the honest representation of "not asked yet", and the
  /// presentation layer is where a localized stand-in belongs.
  TextColumn get displayName =>
      text().withLength(min: 1, max: 120).nullable()();

  /// Language tag, `ar` or `fr` — or **null, meaning "follow the device"**.
  ///
  /// Nullable on purpose, and the null is the whole point. This column stores
  /// the driver's *preference*, not its effective value on one handset, because
  /// the preference is what syncs at V2. A driver set to "follow the device"
  /// who moves to a phone configured in French wants French; storing the
  /// resolved tag `ar` from the old phone would hand them Arabic on a French
  /// phone with no way to understand why.
  ///
  /// No default, for the same reason. A default of `ar` would record a
  /// preference the driver never expressed, and first launch would be
  /// indistinguishable from someone who deliberately chose Arabic.
  ///
  /// Plain text rather than an enum converter, deliberately. A locale that this
  /// build no longer ships must degrade to "follow the device" rather than
  /// throw — dropping a language must not brick the app for whoever had it
  /// selected. `AppLocales.isSupported` decides; the column just stores.
  ///
  /// The value the first frame reads lives in shared preferences, because the
  /// encrypted database needs an async keystore round trip to open. That store
  /// is a cache of this one: writes go here first and mirror there second, so
  /// it can only ever be stale, never ahead.
  TextColumn get locale => text().withLength(min: 2, max: 8).nullable()();
}

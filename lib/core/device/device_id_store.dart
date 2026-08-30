import 'package:shared_preferences/shared_preferences.dart';

import '../utils/uuid_v7.dart';

/// The identifier for this installation.
///
/// Stamped onto every outbox row (§11.5) so that at V2 two devices belonging to
/// the same driver can be told apart — which is exactly the case the outbox's
/// idempotency key has to survive.
///
/// **In shared preferences, not the secure store.** It is an identifier, not a
/// secret: nothing is protected by keeping it confidential, so the keystore
/// buys nothing and costs the keystore's failure modes — including, as M0-19
/// found, a package default that erases on error. It also has to be readable
/// when the keystore is not.
///
/// **And not in the database.** A V1.5 backup restored onto a second phone
/// would carry the device id across with it, and two devices sharing one
/// identity is precisely the confusion this field exists to prevent.
final class DeviceIdStore {
  const DeviceIdStore(this._prefs, this._uuid);

  final SharedPreferences _prefs;
  final UuidV7Generator _uuid;

  static const String storageKey = 'device.id';

  /// The device id, generating and persisting one if there is none.
  ///
  /// **A missing id is regenerated, never an error — and that is deliberately
  /// the opposite of the rule governing the database key.** The two look alike
  /// (both are "a value in platform storage that should already be there") and
  /// the consequences are not remotely alike:
  ///
  /// * Minting a fresh database key when one is missing makes an existing
  ///   database permanently unreadable. `DatabaseKeyProvider.obtain` therefore
  ///   throws rather than generate, and the whole of M0-19 is arranged around
  ///   that.
  /// * Minting a fresh device id costs sync attribution granularity at V2 and
  ///   nothing else. No data becomes unreachable, no money is lost, and the
  ///   driver never sees it.
  ///
  /// So do not carry the never-regenerate rule over here by analogy. Doing so
  /// would turn a harmless reset into a hard startup failure, which is strictly
  /// worse for the driver and protects nothing.
  Future<String> obtain() async {
    final String? existing = _prefs.getString(storageKey);
    // Empty counts as missing: a partially written preferences store is a real
    // state, and an empty device id would violate the outbox column's
    // `min: 1` at the point of insert rather than here, where it is fixable.
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final String fresh = _uuid.next();
    await _prefs.setString(storageKey, fresh);
    return fresh;
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'database_key.dart';

/// Keeps the database key in the platform keystore.
///
/// On Android that is a hardware-backed key held by the Android Keystore, used
/// to encrypt a small preferences file. The key material itself is
/// **non-exportable**, which is the property the whole design rests on: an
/// attacker holding the database file and the preferences file still has
/// nothing without the device.
///
/// It is also why both files are excluded from Android auto-backup. A restored
/// preferences file on a new device contains material that cannot be decrypted
/// there, so restoring it produces a confusing failure instead of a clean
/// absence. See `android/app/src/main/AndroidManifest.xml`.
///
/// **Known risk, accepted for the MVP.** Some OEM restore paths and some "clear
/// credentials" settings can drop keystore entries. If that happens the
/// database becomes unreadable. Key escrow is deliberately not built; V1.5's
/// encrypted backup and restore is the real mitigation, and until then the app
/// fails loudly rather than pretending.
final class SecureKeyStore implements DatabaseKeyStore {
  const SecureKeyStore([
    this._storage = const FlutterSecureStorage(aOptions: androidOptions),
  ]);

  final FlutterSecureStorage _storage;

  /// Namespaced, because this preferences file is shared with anything else
  /// the app stores securely later.
  static const String keyName = 'db.sqlcipher.key';

  /// **`resetOnError` is forced to false, and that is the whole point of
  /// spelling these options out.**
  ///
  /// `flutter_secure_storage` 11 changed the default to `true`, where 9.x had
  /// it `false`. Its own documentation says it will "PERMANENTLY erase the
  /// data when an error occurs" — which here means silently deleting the only
  /// copy of the key to a database full of a driver's settlements, on a
  /// transient keystore error, with no prompt and no trace.
  ///
  /// That is worse than the failure it prevents. An unreadable keystore entry
  /// should surface as [DatabaseKeyMissingError] and stop, so the driver is
  /// told what happened while the encrypted file is still on disk and a future
  /// recovery is still conceivable. A wipe forecloses that.
  ///
  /// `migrateOnAlgorithmChange` stays true: without it, the package's own
  /// documentation says data is lost when the algorithm changes unless
  /// `resetOnError` is true — and `resetOnError` is exactly what must not be.
  static const AndroidOptions androidOptions = AndroidOptions(
    resetOnError: false,
    migrateOnAlgorithmChange: true,
  );

  @override
  Future<String?> read() => _storage.read(key: keyName);

  @override
  Future<void> write(String key) => _storage.write(key: keyName, value: key);

  @override
  Future<void> delete() => _storage.delete(key: keyName);
}

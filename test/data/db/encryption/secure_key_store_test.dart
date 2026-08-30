import 'package:delivery_os/data/db/encryption/secure_key_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test/test.dart';

/// Pins the options the key store actually uses.
///
/// The plugin cannot run on the test host, but the options object is plain
/// Dart and is exactly where the danger is. `flutter_secure_storage` 11 flipped
/// `resetOnError` from `false` to `true` between majors, and its own
/// documentation says the flag will "PERMANENTLY erase the data when an error
/// occurs" — which here means silently deleting the only copy of the key to a
/// database of a driver's settlements, on a transient keystore error.
///
/// The value is correct today because it is set explicitly. This is what stops
/// a refactor of the construction, or the next major bump, from undoing that
/// without anyone noticing. Same argument as the SQLCipher runtime check: the
/// catastrophic-and-invisible failures are the ones that need a mechanical
/// guard rather than a comment.
void main() {
  Map<String, String> options() => SecureKeyStore.androidOptions.toMap();

  test('resetOnError is false', () {
    // If this ever reads true, an error in the keystore wipes the key and the
    // database becomes permanently unreadable with no prompt and no trace.
    // Failing loudly with the encrypted file intact is strictly better: a
    // future recovery stays conceivable, and the driver is told.
    expect(
      options()['resetOnError'],
      'false',
      reason:
          'resetOnError would permanently erase the database key on a '
          'transient keystore error. It must stay false.',
    );
  });

  test('migrateOnAlgorithmChange is true', () {
    // The package documents that without this, data is lost when the algorithm
    // changes *unless* resetOnError is true — and resetOnError is exactly what
    // must not be. So the two settings are a pair, and this is the half that
    // preserves the key across a plugin upgrade.
    expect(options()['migrateOnAlgorithmChange'], 'true');
  });

  test('the key material never leaves the device', () {
    // Biometrics are not required: a driver at 07:00 with cold hands and a
    // parcel in one hand must not be locked out of their own money. The
    // keystore key is still hardware-backed and non-exportable.
    expect(options()['enforceBiometrics'], 'false');
    expect(options()['migrateWithBackup'], 'false');
  });

  test('the storage cipher is authenticated encryption', () {
    // AES-GCM rather than 9.x's AES-CBC-PKCS7, and RSA-OAEP-SHA256 rather than
    // PKCS1v1.5 — the reason the major bump was taken at all.
    expect(options()['storageCipherAlgorithm'], contains('GCM'));
    expect(options()['keyCipherAlgorithm'], contains('OAEP'));
  });

  test('the stored key has a stable, namespaced name', () {
    // Changing this string orphans every existing installation's key.
    expect(SecureKeyStore.keyName, 'db.sqlcipher.key');
  });

  test('the defaults are not relied on', () {
    // The point of spelling the options out. A bare AndroidOptions() carries
    // the dangerous default, and this asserts the difference is real rather
    // than coincidental.
    expect(const AndroidOptions().toMap()['resetOnError'], 'true');
    expect(options()['resetOnError'], 'false');
  });
}

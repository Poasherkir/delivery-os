import 'dart:math';

import 'package:meta/meta.dart';

/// Thrown when a database file exists but its key does not.
///
/// **The most dangerous state this app can reach**, and the reason it has its
/// own type rather than being a generic failure. The correct response is to
/// tell the driver plainly and stop. It is never to generate a fresh key, and
/// never to delete the file.
final class DatabaseKeyMissingError extends Error {
  DatabaseKeyMissingError();

  @override
  String toString() =>
      'DatabaseKeyMissingError: a database file exists but no key was found. '
      'Generating a new key here would make the existing data permanently '
      'unreadable. This must be surfaced to the user, not recovered from.';
}

/// Thrown when key generation is attempted with a database already on disk.
final class DatabaseKeyGenerationRefusedError extends Error {
  DatabaseKeyGenerationRefusedError();

  @override
  String toString() =>
      'DatabaseKeyGenerationRefusedError: refused to generate a database key '
      'because a database file already exists. Key creation happens exactly '
      'once, at first launch, before any database.';
}

/// Where the database key is kept between launches.
///
/// An interface because the real implementation is a platform plugin and
/// cannot run on the test host — and because the rules in [DatabaseKeyProvider]
/// are the part worth testing exhaustively.
abstract interface class DatabaseKeyStore {
  /// The stored key, or null if there is none.
  Future<String?> read();

  Future<void> write(String key);

  /// Only for a deliberate, user-confirmed reset. Never called on a failure
  /// path.
  Future<void> delete();
}

/// Decides whether to read a key or mint one, and refuses the dangerous case.
///
/// The whole of this class is one rule:
///
/// > **Never generate a key when a database file already exists.**
///
/// A read-or-create helper that falls through to "create" when the read fails —
/// a keystore hiccup, a transient platform-channel exception, a wrong plugin
/// on a new OEM — will cheerfully mint a fresh key and leave the driver's
/// database permanently unreadable. There is no recovery from that and no way
/// for the driver to know it happened. So generation is gated on the absence of
/// a database file, and everything else throws.
final class DatabaseKeyProvider {
  DatabaseKeyProvider(this._store, {Random? random})
    : _random = random ?? Random.secure();

  final DatabaseKeyStore _store;
  final Random _random;

  /// A 256-bit raw key, as 64 hex characters.
  ///
  /// SQLCipher takes this as a raw key rather than a passphrase, so no KDF runs
  /// on open. That is the right trade for a key that was generated with a CSPRNG
  /// and never typed by a human: there is no weak input to stretch.
  static const int keyLengthBytes = 32;

  /// Returns the key for a database, generating one only if it is safe to.
  ///
  /// [databaseExists] must reflect the file on disk at the moment of the call.
  ///
  /// * key present — returned, whatever the file's state
  /// * no key, no database — first launch, so one is generated and stored
  /// * no key, database present — [DatabaseKeyMissingError]
  Future<String> obtain({required bool databaseExists}) async {
    final String? existing = await _store.read();
    if (existing != null) {
      return existing;
    }

    if (databaseExists) {
      // The dangerous branch, and the only correct thing to do in it is
      // nothing. See DatabaseKeyMissingError.
      throw DatabaseKeyMissingError();
    }

    final String generated = generateKey(random: _random);
    await _store.write(generated);
    return generated;
  }

  /// Generates and stores a key, refusing if a database already exists.
  ///
  /// Separate from [obtain] so a caller cannot reach generation by accident:
  /// this is only for the deliberate, user-confirmed reset after an
  /// unreadable database.
  Future<String> regenerateForEmptyDatabase({
    required bool databaseExists,
  }) async {
    if (databaseExists) {
      throw DatabaseKeyGenerationRefusedError();
    }
    final String generated = generateKey(random: _random);
    await _store.write(generated);
    return generated;
  }

  /// 64 lowercase hex characters from a cryptographic source.
  @visibleForTesting
  static String generateKey({Random? random}) {
    final Random source = random ?? Random.secure();
    final StringBuffer hex = StringBuffer();
    for (int i = 0; i < keyLengthBytes; i++) {
      hex.write(source.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return hex.toString();
  }
}

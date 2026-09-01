import 'dart:io';

import 'database_key.dart';

/// Destroys the local database and mints a fresh key, so the app can start over.
///
/// **The only sanctioned way out of an unreadable database, and it is
/// unrecoverable.** Everything the driver has recorded on this phone is gone:
/// deliveries and their history, customers and their saved pins, money records
/// and settlements. Nothing here can be undone, which is why the two-step
/// confirmation in front of it is the way it is.
///
/// The order is forced and not a preference. [DatabaseKeyProvider] refuses to
/// generate while a database file exists — deliberately, since minting a key
/// beside live data is how data becomes permanently unreadable — so the file
/// must go first.
///
/// That leaves a window where the file is gone and the key is not yet replaced.
/// **That state is safe, and it is safe by construction rather than by luck:**
/// with no file, the next launch takes the ordinary first-launch path and
/// `obtain(databaseExists: false)` hands back the key already in the store. A
/// reset interrupted at the worst possible moment leaves a fresh install, not a
/// driver stranded on the screen he was trying to escape. `database_reset_test`
/// asserts exactly that rather than assuming it.
final class DatabaseReset {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named — Dart forbids a named parameter
  /// called `_file`. Same shape as `UuidV7Generator` and `UserSettingsDao`.
  factory DatabaseReset({
    required File file,
    required DatabaseKeyProvider keys,
  }) => DatabaseReset._(file, keys);

  const DatabaseReset._(this._file, this._keys);

  final File _file;
  final DatabaseKeyProvider _keys;

  /// Deletes the database and replaces the key. Returns the new key.
  ///
  /// The caller must have closed the database first. Deleting a file that
  /// SQLite still holds open succeeds on POSIX and fails on Windows, and
  /// neither outcome is one to discover on a driver's phone.
  Future<String> run() async {
    _deleteDatabaseFiles();

    // Only now, and only because the file is gone. The refusal inside
    // regenerateForEmptyDatabase is a second lock on the same door: if the
    // delete silently failed, this throws rather than stranding the data.
    return _keys.regenerateForEmptyDatabase(databaseExists: _file.existsSync());
  }

  /// The database is three files, not one.
  ///
  /// WAL journalling (`PRAGMA journal_mode = WAL`, set in `beforeOpen`) keeps
  /// committed pages in `-wal` until a checkpoint. Deleting only the main file
  /// would leave the write-ahead log and shared-memory index behind, and SQLite
  /// would either recover pages of the "deleted" data on the next open or fail
  /// to open at all. Either is worse than the reset the driver asked for.
  void _deleteDatabaseFiles() {
    for (final String path in <String>[
      _file.path,
      '${_file.path}-wal',
      '${_file.path}-shm',
    ]) {
      final File f = File(path);
      if (f.existsSync()) {
        f.deleteSync();
      }
    }
  }
}

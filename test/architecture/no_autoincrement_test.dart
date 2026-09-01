import 'dart:io';

import 'package:test/test.dart';

/// Invariant 2: IDs are UUIDv7, generated client-side. No auto-increment, ever.
///
/// Offline creation cannot wait for a server to assign an id, and two devices
/// would both mint `41`. The failure is not a crash — it is two orders that
/// collide the first time anything syncs, months after the table was written.
///
/// A scan rather than a schema check on purpose: `autoIncrement()` in drift
/// produces an `INTEGER PRIMARY KEY AUTOINCREMENT` that looks perfectly healthy
/// in `sqlite_master`, and the damage only appears when a second device exists.
/// Catching the call site is catching it at the moment the decision is made.
///
/// `wilayas.code` and `communes.id` are integer primary keys and are *not* a
/// violation: those ids come from the national nomenclature and are not ours to
/// mint. Invariant 2 is about rows this app creates. SQLite makes them rowid
/// aliases, which is a separate hazard handled by the loader's explicit-code
/// rejection in `test/data/geo/geo_dataset_test.dart`.
void main() {
  test('no table definition uses autoIncrement', () {
    final List<String> offenders = <String>[];

    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final String path = entity.path.replaceAll(r'\', '/');
      // Generated output mirrors whatever the definitions say, so flagging it
      // would report the same mistake twice and point at a file nobody edits.
      if (path.endsWith('.g.dart') || path.contains('/generated/')) {
        continue;
      }

      final List<String> lines = entity.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('autoIncrement()')) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'invariant 2: ids are UUIDv7, generated client-side. An '
          'auto-increment column cannot be created offline without two devices '
          'eventually minting the same id. Use UuidPrimaryKey. '
          'Found at: ${offenders.join(', ')}',
    );
  });
}

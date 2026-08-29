import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet, sqlite3;
import 'package:test/test.dart';

/// What the bundled SQLite build must provide, checked at the lowest level
/// before any schema is built on top of it.
///
/// `package:sqlite3` 3.x bundles its own SQLite through Dart hooks on every
/// platform including the test host, so there is no plugin to install and no
/// `sqlite3.dll` to locate on Windows. Which build is bundled is chosen in
/// `pubspec.yaml` under `hooks.user_defines`.
void main() {
  test('the test host can open a database at all', () async {
    // If this fails, every DAO test in the project fails with it, and the
    // cause is the toolchain rather than anything in lib/.
    final GeneratedDatabase db = _Probe(NativeDatabase.memory());
    final QueryRow row = await db.customSelect('SELECT 1 AS one').getSingle();

    expect(row.read<int>('one'), 1);
    await db.close();
  });

  test('the bundled SQLite is recent enough for the schema', () {
    // 3.35 introduced RETURNING and DROP COLUMN, both of which the M0-20
    // migration harness leans on.
    final List<int> version = sqlite3.version.libVersion
        .split('.')
        .map(int.parse)
        .toList();

    expect(version[0], greaterThanOrEqualTo(3));
    expect(version[0] * 1000 + version[1], greaterThanOrEqualTo(3035));
  });

  test('the bundled build is SQLCipher, not plain SQLite', () {
    // Selected from the start so the engine never changes underneath the
    // schema: M0-19 adds the key, it does not swap the binary. If a dependency
    // update silently dropped encryption support the app would still run and
    // would still write an unencrypted database — this is the only place that
    // would notice.
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);

    final ResultSet result = db.select('PRAGMA cipher_version');

    expect(
      result,
      isNotEmpty,
      reason:
          'PRAGMA cipher_version returned nothing: the bundled build has no '
          'encryption support. Check hooks.user_defines in pubspec.yaml.',
    );
  });

  test('the key pragma is accepted', () {
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);

    // Keying a real file is M0-19. This only asserts the engine understands
    // the pragma, so that task cannot discover otherwise.
    expect(() => db.execute('PRAGMA key = "probe"'), returnsNormally);
  });
}

class _Probe extends GeneratedDatabase {
  _Probe(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      const <TableInfo<Table, dynamic>>[];

  @override
  int get schemaVersion => 1;
}

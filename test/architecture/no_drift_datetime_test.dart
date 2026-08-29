import 'dart:io';

import 'package:test/test.dart';

/// Where table definitions live.
const String _scanned = 'lib/data/db';

/// Drift's own `DateTime` column, which stores Unix **seconds**.
///
/// Banned outright rather than merely discouraged. Seconds cannot order three
/// parcels marked delivered in the same lift, and `delivery_attempts` and
/// `outbox` both need ordering within a second. Because the ban is total, it is
/// also mechanically checkable: any occurrence at all is a violation, so there
/// is no judgement call and nothing to argue about in review.
final RegExp _driftDateTime = RegExp(r'(?<![\w.$])dateTime\s*\(');

/// A column getter whose name ends in `At`, and everything up to its
/// terminating semicolon.
///
/// Restricted to declared column types so an ordinary getter that happens to
/// end in `At` is not caught.
final RegExp _timestampColumn = RegExp(
  r'(?:IntColumn|TextColumn|RealColumn|BoolColumn|DateTimeColumn)\s+'
  r'get\s+(\w*At)\s*=>(.*?);',
  dotAll: true,
);

/// Strips `//` and `///` lines so prose naming the forbidden call does not trip
/// the guard.
String _stripComments(String source) => source
    .split('\n')
    .where((String line) => !line.trimLeft().startsWith('//'))
    .join('\n');

String _posix(String path) => path.replaceAll(r'\', '/');

List<File> _files() {
  final Directory dir = Directory(_scanned);
  if (!dir.existsSync()) {
    return const <File>[];
  }
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'),
      )
      .toList();
}

void main() {
  test('no table uses drift dateTime()', () {
    // Timestamps are INTEGER milliseconds since the epoch, UTC, through
    // UtcMillisecondsConverter. See ARCHITECTURE.md §6.1.
    final List<String> violations = <String>[];

    for (final File file in _files()) {
      final List<String> lines = _stripComments(
        file.readAsStringSync(),
      ).split('\n');

      for (int i = 0; i < lines.length; i++) {
        if (_driftDateTime.hasMatch(lines[i])) {
          violations.add('${_posix(file.path)}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'dateTime() stores Unix seconds. Use '
          'integer().map(const UtcMillisecondsConverter()) instead.\n'
          '${violations.join('\n')}',
    );
  });

  test('every timestamp column converts through UtcMillisecondsConverter', () {
    // The other half. Banning dateTime() alone would still allow a plain
    // integer() column holding who-knows-what units, which would read back as
    // an int and quietly skip the UTC guarantee.
    final List<String> violations = <String>[];

    for (final File file in _files()) {
      final String source = _stripComments(file.readAsStringSync());

      for (final RegExpMatch match in _timestampColumn.allMatches(source)) {
        final String name = match.group(1)!;
        final String declaration = match.group(2)!;

        if (!declaration.contains('UtcMillisecondsConverter')) {
          violations.add('${_posix(file.path)}  $name');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'these columns look like timestamps but do not convert through '
          'UtcMillisecondsConverter:\n${violations.join('\n')}',
    );
  });

  test('the guard has something to scan', () {
    // Renaming or moving lib/data/db/ must not leave a guard that passes by
    // examining nothing.
    expect(_files(), isNotEmpty);
  });

  group('the rules themselves', () {
    test('dateTime() is caught however it is written', () {
      for (final String source in <String>[
        'DateTimeColumn get createdAt => dateTime()();',
        '  DateTimeColumn get x => dateTime().nullable()();',
        'dateTime ()',
      ]) {
        expect(_driftDateTime.hasMatch(source), isTrue, reason: source);
      }
    });

    test('lookalikes are not caught', () {
      for (final String source in <String>[
        'IntColumn get createdAt => integer().map(const UtcMillisecondsConverter())();',
        'final DateTime now = clock.nowUtc();',
        'someDateTime(value)',
        'x.dateTime()',
      ]) {
        expect(_driftDateTime.hasMatch(source), isFalse, reason: source);
      }
    });

    test('a bare integer timestamp column is caught', () {
      const String bad = 'IntColumn get occurredAt => integer()();';
      final RegExpMatch? match = _timestampColumn.firstMatch(bad);

      expect(match, isNotNull);
      expect(match!.group(1), 'occurredAt');
      expect(match.group(2), isNot(contains('UtcMillisecondsConverter')));
    });

    test('a converted one is not', () {
      const String good =
          'IntColumn get occurredAt => '
          'integer().map(const UtcMillisecondsConverter()).nullable()();';

      expect(
        _timestampColumn.firstMatch(good)!.group(2),
        contains('UtcMillisecondsConverter'),
      );
    });

    test('a getter that merely ends in At is ignored', () {
      // Only declared column types are examined.
      expect(_timestampColumn.hasMatch('bool get isAt => true;'), isFalse);
      expect(_timestampColumn.hasMatch('String get labelAt => "x";'), isFalse);
    });
  });
}

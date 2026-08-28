import 'dart:io';

import 'package:test/test.dart';

/// Everything `lib/domain/` is permitted to import.
///
/// **An allowlist, deliberately, not a list of forbidden packages.**
///
/// A denylist fails *open*: the day someone adds `path_provider`,
/// `shared_preferences`, `dio`, or any of the hundred packages nobody thought
/// to name, the guard passes and the domain layer is quietly no longer pure.
/// An allowlist fails *closed* — anything unrecognised trips it, and widening
/// the list is a visible line in a diff rather than a silent non-event.
///
/// This holds exactly what the code actually needs. `dart:core` is not here
/// because it never appears as a directive; `dart:convert` and
/// `dart:typed_data` are not here because nothing uses them yet, and
/// pre-widening a fail-closed list defeats the point of having one.
const List<String> allowedImports = <String>[
  'dart:math',
  'package:meta/meta.dart',
];

const String _domainRoot = 'lib/domain';
const String _selfPackageDomain = 'package:delivery_os/domain/';

/// Matches an `import`, `export` or `part` directive and captures its URI.
final RegExp _directive = RegExp(
  '''^\\s*(?:import|export|part)\\s+(?:'([^']*)'|"([^"]*)")''',
  multiLine: true,
);

String _posix(String path) => path.replaceAll(r'\', '/');

/// Resolves a relative URI against the directory of [fromFile].
String _resolve(String fromFile, String relativeUri) {
  final List<String> parts = _posix(fromFile).split('/')..removeLast();

  for (final String segment in relativeUri.split('/')) {
    if (segment == '.' || segment.isEmpty) {
      continue;
    }
    if (segment == '..') {
      if (parts.isNotEmpty) {
        parts.removeLast();
      }
      continue;
    }
    parts.add(segment);
  }

  return parts.join('/');
}

/// Why [uri], imported from [fromFile], is not allowed — or null if it is.
///
/// Extracted so the rule itself can be unit-tested against inputs that do not
/// exist on disk. A guard nobody has watched fail is not a guard.
String? violation(String fromFile, String uri) {
  if (uri.startsWith('dart:') || uri.startsWith('package:')) {
    if (uri.startsWith(_selfPackageDomain)) {
      return null;
    }
    if (allowedImports.contains(uri)) {
      return null;
    }
    return 'imports $uri, which is not on the domain allowlist';
  }

  final String resolved = _resolve(fromFile, uri);
  if (!resolved.startsWith('$_domainRoot/')) {
    return 'reaches outside the domain layer via $uri (resolves to $resolved)';
  }
  return null;
}

List<File> _domainFiles() {
  final Directory dir = Directory(_domainRoot);
  if (!dir.existsSync()) {
    return const <File>[];
  }
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();
}

void main() {
  test('lib/domain/ imports nothing outside the allowlist', () {
    // Invariant 4. The money engine, the state machine and the optimizer stay
    // unit-testable at millisecond speed with no device, and portable to a
    // Dart server later — but only while this holds.
    final List<String> violations = <String>[];

    for (final File file in _domainFiles()) {
      final String path = _posix(file.path);
      final String source = file.readAsStringSync();

      for (final RegExpMatch match in _directive.allMatches(source)) {
        final String uri = match.group(1) ?? match.group(2)!;
        final String? reason = violation(path, uri);
        if (reason != null) {
          violations.add('$path $reason');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'lib/domain/ must stay pure Dart. If a dependency is genuinely '
          'needed, move it behind an interface — or widen allowedImports '
          'deliberately.\n${violations.join('\n')}',
    );
  });

  test('the guard has something to scan', () {
    // Without this, moving or renaming lib/domain/ would leave a guard that
    // passes because it examines nothing.
    expect(_domainFiles(), isNotEmpty);
  });

  test(
    'the allowlist is exactly this, and widening it is a visible change',
    () {
      // Asserted by contents rather than length: adding an entry has to show up
      // as a reviewable line, not as a number changing.
      expect(allowedImports, <String>['dart:math', 'package:meta/meta.dart']);
    },
  );

  group('the rule itself', () {
    const String file = 'lib/domain/value_objects/thing.dart';

    test('permits what is on the list', () {
      expect(violation(file, 'dart:math'), isNull);
      expect(violation(file, 'package:meta/meta.dart'), isNull);
    });

    test('permits movement within the domain layer', () {
      expect(violation(file, 'centimes.dart'), isNull);
      expect(violation(file, '../entities/order.dart'), isNull);
      expect(
        violation(file, 'package:delivery_os/domain/rules/spec.dart'),
        isNull,
      );
    });

    test('rejects the layers domain must not know about', () {
      // The named ones from invariant 4.
      for (final String uri in <String>[
        'package:flutter/material.dart',
        'package:flutter/foundation.dart',
        'package:drift/drift.dart',
        'package:http/http.dart',
        'package:dio/dio.dart',
      ]) {
        expect(violation(file, uri), isNotNull, reason: uri);
      }
    });

    test(
      'rejects packages nobody thought to name — the point of an allowlist',
      () {
        // A denylist would pass every one of these. This is the failure mode the
        // shape of this guard exists to prevent.
        for (final String uri in <String>[
          'package:path_provider/path_provider.dart',
          'package:shared_preferences/shared_preferences.dart',
          'package:go_router/go_router.dart',
          'package:sqlite3/sqlite3.dart',
          'package:some_package_invented_in_2027/thing.dart',
        ]) {
          expect(violation(file, uri), isNotNull, reason: uri);
        }
      },
    );

    test('rejects dart: libraries that are not pure computation', () {
      // dart:io is the dangerous one — it compiles, it is not Flutter, and it
      // would make the domain layer unusable on the web and untestable without
      // a filesystem.
      expect(violation(file, 'dart:io'), isNotNull);
      expect(violation(file, 'dart:ui'), isNotNull);
      expect(violation(file, 'dart:isolate'), isNotNull);
    });

    test('rejects reaching into another layer of this package', () {
      expect(violation(file, '../../core/theme/tokens/tokens.dart'), isNotNull);
      expect(violation(file, '../../data/db/database.dart'), isNotNull);
      expect(
        violation(file, 'package:delivery_os/core/time/clock.dart'),
        isNotNull,
      );
      expect(
        violation(file, 'package:delivery_os/data/db/database.dart'),
        isNotNull,
      );
    });

    test('names what resolving a relative escape landed on', () {
      // The message has to be actionable: which import, and where it went.
      final String? reason = violation(file, '../../core/time/clock.dart');
      expect(reason, contains('core/time/clock.dart'));
      expect(reason, contains('lib/core/time/clock.dart'));
    });
  });

  group('directive matching', () {
    test('catches import, export and part alike', () {
      // An export re-exposes whatever it names, so it leaks a dependency just
      // as effectively as an import.
      for (final String source in <String>[
        "import 'dart:io';",
        "export 'dart:io';",
        "part 'dart:io';",
        '  import "dart:io";',
        "import 'dart:io' as io;",
        "import 'dart:io' show File;",
      ]) {
        final RegExpMatch? match = _directive.firstMatch(source);
        expect(match, isNotNull, reason: source);
        expect(match!.group(1) ?? match.group(2), 'dart:io', reason: source);
      }
    });

    test('does not fire on prose that mentions an import', () {
      for (final String source in <String>[
        "/// Never import 'dart:io' from here.",
        "// import 'dart:io';",
        "const String example = \"import 'dart:io';\";",
      ]) {
        final RegExpMatch? match = _directive.firstMatch(source);
        expect(match, isNull, reason: source);
      }
    });
  });
}

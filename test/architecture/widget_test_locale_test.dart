import 'dart:io';

import 'package:test/test.dart';

/// **Every `MaterialApp` a test builds names its locale.**
///
/// Converting a rule that was soft since M0-07, where it was found the hard
/// way: an RTL test was comparing RTL against RTL and passing for the wrong
/// reason. The runner reports `en-US`, and a test that names no locale gets
/// whatever that resolves to rather than what its author had in mind.
///
/// **What it resolves to has already changed once.** Before English shipped,
/// `en-US` matched nothing and fell back to Arabic — so a silent test ran RTL
/// while reading as LTR. Now it matches English. Both are wrong for a test
/// that believes it is checking French, which is the point: the hazard was
/// never the particular language, it was the locale being inherited instead
/// of chosen. A guard that had encoded "falls back to Arabic" as its
/// assertion would have gone green and stopped meaning anything the day the
/// supported list grew.
///
/// **Why the `MaterialApp` and not the `testWidgets` body.** The locale is
/// decided in exactly one place — the widget that installs
/// `Localizations` — and checking there is precise where checking the test
/// body is not. Most tests reach it through a shared `pump` helper, so a
/// per-test scan would flag every one of them for a locale their helper names
/// on their behalf; and a test body could name a locale it never passes
/// anywhere and satisfy that check while rendering the fallback. This scans
/// the thing that actually chooses.
///
/// A hard-coded locale in a helper satisfies this. So does one taken as a
/// parameter. What does not is leaving it out and inheriting whatever the
/// runner happens to report.
void main() {
  late List<File> testFiles;

  setUpAll(() {
    final Directory root = Directory('test');
    expect(
      root.existsSync(),
      isTrue,
      reason: 'test/ is missing; this guard cannot run',
    );

    testFiles = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();

    expect(
      testFiles,
      isNotEmpty,
      reason: 'the scan found no Dart files, so it proved nothing',
    );
  });

  test('every MaterialApp built in a test declares a locale', () {
    final List<String> missing = <String>[];
    int found = 0;

    for (final File file in testFiles) {
      final String source = file.readAsStringSync();

      for (final _Construction app in _materialApps(_codeOnly(source))) {
        found++;
        if (!app.arguments.contains('locale:')) {
          final int line =
              '\n'.allMatches(source.substring(0, app.offset)).length + 1;
          missing.add('${file.path}:$line');
        }
      }
    }

    // The subject set, asserted rather than assumed. A regex that stopped
    // matching — a rename, a wrapper, a formatter moving the paren — would
    // otherwise leave this passing forever while checking nothing.
    expect(
      found,
      greaterThanOrEqualTo(10),
      reason:
          'only $found MaterialApp constructions were found across '
          '${testFiles.length} test files, which is too few to be real: the '
          'scan has probably stopped matching',
    );

    expect(
      missing,
      isEmpty,
      reason:
          'these widget tests build a MaterialApp without naming a locale, so '
          'they run against the runner default (en-US), which falls back to '
          'Arabic — passing while reading as though they were French:\n'
          '${missing.join('\n')}',
    );
  });
}

/// One `MaterialApp(...)` or `MaterialApp.router(...)` and its arguments.
final class _Construction {
  const _Construction({required this.offset, required this.arguments});

  /// Index of the constructor name in the source, for reporting a line.
  final int offset;

  /// Everything between the constructor's parentheses.
  final String arguments;
}

/// Blanks comments and string literals, preserving every offset.
///
/// Without it this guard matches itself: its own prose says `MaterialApp(` and
/// its own regex is a string containing it, so the file that defines the rule
/// was the first thing reported as breaking it. That is the third time a guard
/// in this repo has caught its own source, which is why blanking rather than
/// skipping this one file — an exemption would have hidden the same shape in
/// any other test that mentions a `MaterialApp` in a comment.
///
/// Characters are replaced with spaces rather than removed so byte offsets
/// still map to the original line numbers. Handles line comments, nesting
/// block comments, single and double quotes, triple quotes and raw strings.
String _codeOnly(String source) {
  final List<String> out = List<String>.filled(source.length, ' ');
  int i = 0;
  int blockDepth = 0;

  bool startsWith(String token, int at) =>
      at + token.length <= source.length &&
      source.substring(at, at + token.length) == token;

  while (i < source.length) {
    final String char = source[i];

    // Newlines are kept in every state so line counting stays correct.
    if (char == '\n') {
      out[i] = char;
      i++;
      continue;
    }

    if (blockDepth > 0) {
      if (startsWith('/*', i)) {
        blockDepth++;
        i += 2;
        continue;
      }
      if (startsWith('*/', i)) {
        blockDepth--;
        i += 2;
        continue;
      }
      i++;
      continue;
    }

    if (startsWith('//', i)) {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }

    if (startsWith('/*', i)) {
      blockDepth++;
      i += 2;
      continue;
    }

    // A raw string's `r` prefix is code; the quoted body is not.
    final int quoteAt = (char == 'r' && i + 1 < source.length) ? i + 1 : i;
    final String quoteChar = source[quoteAt];

    if (quoteChar == "'" || quoteChar == '"') {
      final bool raw = quoteAt != i;
      final String triple = quoteChar * 3;
      final String delimiter = startsWith(triple, quoteAt) ? triple : quoteChar;

      if (raw) {
        out[i] = char;
      }
      i = quoteAt + delimiter.length;

      while (i < source.length) {
        if (!raw && source[i] == r'\') {
          // An escaped delimiter does not close the literal.
          i += 2;
          continue;
        }
        if (source[i] == '\n') {
          out[i] = '\n';
          i++;
          continue;
        }
        if (startsWith(delimiter, i)) {
          i += delimiter.length;
          break;
        }
        i++;
      }
      continue;
    }

    out[i] = char;
    i++;
  }

  return out.join();
}

/// Finds every `MaterialApp` construction in [source].
///
/// Parenthesis-balanced rather than line-based, because the argument list runs
/// across a dozen lines and nests freely. A fixed lookahead would read past the
/// end of a short one into the next widget's arguments and find a `locale:`
/// that belongs to something else.
///
/// Matches only the constructor call — `MaterialApp(` or `MaterialApp.router(`
/// — so the name appearing in a comment or inside `find.byType(MaterialApp)`
/// is not mistaken for one.
List<_Construction> _materialApps(String source) {
  final RegExp pattern = RegExp(r'MaterialApp(?:\.router)?\s*\(');
  final List<_Construction> found = <_Construction>[];

  for (final RegExpMatch match in pattern.allMatches(source)) {
    final int open = match.end - 1;
    int depth = 0;
    int cursor = open;

    while (cursor < source.length) {
      final String char = source[cursor];
      if (char == '(') {
        depth++;
      } else if (char == ')') {
        depth--;
        if (depth == 0) {
          break;
        }
      }
      cursor++;
    }

    if (depth != 0) {
      // Unbalanced to the end of the file. Reported as a construction with no
      // arguments so it fails loudly rather than being skipped: a scan that
      // silently drops what it cannot parse is a scan that checks less than it
      // claims.
      found.add(_Construction(offset: match.start, arguments: ''));
      continue;
    }

    found.add(
      _Construction(
        offset: match.start,
        arguments: source.substring(open, cursor + 1),
      ),
    );
  }

  return found;
}

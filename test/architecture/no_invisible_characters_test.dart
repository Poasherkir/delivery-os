import 'dart:io';

import 'package:test/test.dart';

/// Invisible and format characters must be built from codepoints, never pasted.
///
/// **This rule has now bitten twice, both times in a file whose entire purpose
/// was the thing it guards.** The first version of `project_rules_test.dart`
/// was written through a shell heredoc by someone who had just read the
/// no-heredoc rule; `money_format_test.dart` pasted two non-breaking spaces
/// into string literals while pinning a codepoint-built separator. Both were
/// caught only because the rule happened to be fresh in mind, which is exactly
/// the condition that does not persist.
///
/// **Scoped to invisible and format characters, not to all non-ASCII.** The
/// rule exists because these are unreviewable in a diff — a reader cannot see
/// an NBSP, a zero-width joiner or a bidi isolate, and a copy-paste silently
/// mangles them. Visible non-ASCII is the opposite: Arabic in a test literal
/// shows up as Arabic and a reader can check it. Flagging Arabic would make
/// this guard fire constantly on correct code, which is how guards get deleted.
///
/// Comments are exempt, per the rule. In valid Dart the only other place these
/// can appear is inside a string literal — one in code would be a syntax error
/// the analyzer already catches — so scanning everything outside a comment is
/// exactly the intended scope.

/// Characters a reader cannot see in a diff.
///
/// Spaces that are not `U+0020`, joiners, bidi controls, and the byte-order
/// mark. Written as ranges with names so adding one is a decision rather than
/// an edit to an opaque list.
bool _isInvisible(int c) =>
    c == 0x00A0 || // no-break space
    c == 0x00AD || // soft hyphen
    c == 0x061C || // Arabic letter mark
    c == 0x180E || // Mongolian vowel separator
    (c >= 0x2000 && c <= 0x200F) || // en/em spaces, ZWSP, ZWNJ, ZWJ, LRM, RLM
    (c >= 0x2028 && c <= 0x202F) || // line/para separators, bidi embedding
    (c >= 0x205F && c <= 0x2064) || // medium math space, word joiner
    (c >= 0x2066 && c <= 0x206F) || // bidi isolates and deprecated formats
    c == 0x3000 || // ideographic space
    c == 0xFEFF; // BOM / zero-width no-break space

/// A hit, with everything needed to find and fix it.
///
/// Public because `scan` is: the scanner is exercised directly by the tests
/// below, since a guard with this much logic can be wrong in both directions.
final class Finding {
  const Finding(this.path, this.line, this.codePoint);

  final String path;
  final int line;
  final int codePoint;

  @override
  String toString() =>
      '$path:$line uses U+${codePoint.toRadixString(16).toUpperCase().padLeft(4, '0')} '
      '— build it with String.fromCharCode(0x'
      '${codePoint.toRadixString(16).toUpperCase().padLeft(4, '0')}) instead';
}

/// Reports invisible characters outside comments.
///
/// A small state machine rather than the analyzer package: this needs to know
/// comment-or-not and nothing else, and a dependency on the analyzer would tie
/// a guard to the same version skew that already pins drift.
List<Finding> scan(String path, String source) {
  final List<Finding> found = <Finding>[];
  int line = 1;
  int i = 0;
  int blockDepth = 0;
  bool inLineComment = false;

  while (i < source.length) {
    final int c = source.codeUnitAt(i);

    if (c == 0x0A) {
      line++;
      inLineComment = false;
      i++;
      continue;
    }

    if (inLineComment) {
      i++;
      continue;
    }

    if (blockDepth > 0) {
      // Dart block comments nest, so `/*` inside one opens another.
      if (c == 0x2F &&
          i + 1 < source.length &&
          source.codeUnitAt(i + 1) == 0x2A) {
        blockDepth++;
        i += 2;
        continue;
      }
      if (c == 0x2A &&
          i + 1 < source.length &&
          source.codeUnitAt(i + 1) == 0x2F) {
        blockDepth--;
        i += 2;
        continue;
      }
      i++;
      continue;
    }

    if (c == 0x2F && i + 1 < source.length) {
      final int next = source.codeUnitAt(i + 1);
      if (next == 0x2F) {
        inLineComment = true;
        i += 2;
        continue;
      }
      if (next == 0x2A) {
        blockDepth = 1;
        i += 2;
        continue;
      }
    }

    if (_isInvisible(c)) {
      found.add(Finding(path, line, c));
    }
    i++;
  }

  return found;
}

void main() {
  test('no invisible character is pasted into lib/ or test/', () {
    final List<Finding> findings = <Finding>[];
    int scanned = 0;

    for (final String root in <String>['lib', 'test']) {
      for (final FileSystemEntity entity in Directory(
        root,
      ).listSync(recursive: true, followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String path = entity.path.replaceAll(r'\', '/');
        // Generated output is not written by hand, so there is nobody to tell
        // and nothing to review.
        if (path.endsWith('.g.dart') || path.contains('/generated/')) {
          continue;
        }

        scanned++;
        findings.addAll(scan(path, entity.readAsStringSync()));
      }
    }

    expect(
      scanned,
      greaterThan(50),
      reason:
          'the scan found almost no files, so it proved nothing — the glob or '
          'the paths have moved',
    );
    expect(
      findings,
      isEmpty,
      reason:
          'invisible characters are unreviewable in a diff and are silently '
          'mangled by a copy-paste:\n  ${findings.join('\n  ')}',
    );
  });

  group('the scanner itself', () {
    // A guard nobody has tested is a guard nobody should trust, and this one
    // has enough logic to be wrong in both directions.

    test('finds a pasted no-break space in a string literal', () {
      final String nbsp = String.fromCharCode(0x00A0);
      final List<Finding> found = scan('x.dart', "const a = 'one${nbsp}two';");

      expect(found, hasLength(1));
      expect(found.single.codePoint, 0x00A0);
      expect(found.single.line, 1);
    });

    test('and reports the line it is on', () {
      final String zwj = String.fromCharCode(0x200D);
      final List<Finding> found = scan(
        'x.dart',
        "final a = 1;\nfinal b = 2;\nfinal c = '$zwj';",
      );

      expect(found.single.line, 3);
    });

    test('names the codepoint and how to write it instead', () {
      // The message is the whole value of the guard: an invisible character
      // that a reader cannot see needs to be named, not pointed at.
      final String rlm = String.fromCharCode(0x200F);
      final Finding f = scan('x.dart', "const a = '$rlm';").single;

      expect(f.toString(), contains('U+200F'));
      expect(f.toString(), contains('String.fromCharCode(0x200F)'));
    });

    test('ignores one in a line comment', () {
      // Prose in comments is exempt, per the rule: a comment discussing an
      // invisible character is documentation, not a mangled literal.
      final String nbsp = String.fromCharCode(0x00A0);
      expect(scan('x.dart', '// a${nbsp}comment'), isEmpty);
    });

    test('ignores one in a block comment, including a nested one', () {
      final String nbsp = String.fromCharCode(0x00A0);
      expect(
        scan('x.dart', '/* outer /* inner$nbsp */ still outer$nbsp */'),
        isEmpty,
      );
    });

    test('resumes checking after a comment closes', () {
      // The failure that would make this guard useless: a scanner that never
      // leaves comment state passes everything.
      final String nbsp = String.fromCharCode(0x00A0);
      final List<Finding> found = scan(
        'x.dart',
        "// note$nbsp\nconst a = '$nbsp';",
      );

      expect(found, hasLength(1));
      expect(found.single.line, 2);
    });

    test('leaves visible non-ASCII alone', () {
      // The scoping decision. Arabic in a literal is reviewable — a reader
      // sees Arabic — and flagging it would make this fire constantly on
      // correct code, which is how guards get deleted.
      expect(scan('x.dart', "const a = 'باب الزوار';"), isEmpty);
      expect(scan('x.dart', "const b = 'Café — 3 400,00 DA';"), isEmpty);
    });

    test('catches a bidi isolate, which is the worst case', () {
      // Invisible, changes how everything after it renders, and survives a
      // copy-paste into a diff viewer that shows nothing.
      final String fsi = String.fromCharCode(0x2068);
      expect(scan('x.dart', "const a = '$fsi';"), hasLength(1));
    });

    test('catches a byte-order mark', () {
      expect(
        scan('x.dart', "const a = '${String.fromCharCode(0xFEFF)}';"),
        hasLength(1),
      );
    });
  });
}

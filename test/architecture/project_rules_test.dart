/// `CLAUDE.md` is the only file with a hard loading guarantee, so it is the only
/// file allowed to hold anything load-bearing.
///
/// This test looks odd until you notice it is the same move as the domain purity
/// guard, the raw-`Text` guard and the forbidden-vocabulary guard: a property
/// currently held by care, converted into one held by the build.
///
/// The property here is **"the rules are actually loaded"**, and it spent four
/// commits being false. Renaming this file to `CONTRIBUTING.md` broke it, and
/// nothing surfaced — the session that made the change already had the old file
/// in context, so every rule still appeared to apply. Two more rules were
/// written into the unloaded file before anyone noticed.
///
/// What this can and cannot do: it fails if the file is renamed, moved, or
/// loses a rule. It cannot tell you the file is being *read* at session start —
/// no test can. That half is the reporting rule in the workflow section.
library;

import 'dart:io';

import 'package:test/test.dart';

/// What makes a file a rules document rather than one that mentions a rule.
///
/// Section headings, plus the normative lead-in of a rule stated as an
/// instruction. Summarising a constraint in prose and pointing at CLAUDE.md
/// does not trip these; copying the rule does.
const List<String> _rulesDocumentMarkers = <String>[
  '## Non-negotiable invariants',
  '## PII in diagnostics',
  '## Testing bar',
  '## Explicitly out of scope',
  'Never pipe a gate command',
  'Never `git add -A`',
  'Amend freely while unpushed, never after',
  'Formatting and checking are two different commands',
  'A test that would pass against an empty implementation',
  'Write files with the Write tool, never a shell heredoc',
];

void main() {
  late String rules;

  setUpAll(() {
    final File file = File('CLAUDE.md');
    // Named separately from the content checks so a missing file reports as
    // "the file is gone" rather than as twenty-two missing rules.
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'CLAUDE.md must exist at the repository root. It is the only file '
          'loaded automatically at the start of a session, so moving or '
          'renaming it unloads every rule in it without anything failing.',
    );
    rules = file.readAsStringSync();
  });

  group('the sections are all present', () {
    // Losing a whole section is the failure a per-rule check would report as
    // scattered noise.
    for (final String heading in <String>[
      '## Non-negotiable invariants',
      '## Layering',
      '## PII in diagnostics',
      '## Commands',
      '## Workflow',
      '## Testing bar',
      '## Explicitly out of scope',
      '## UI rules',
    ]) {
      test('"$heading"', () => expect(rules, contains(heading)));
    }
  });

  group('every process rule is still here', () {
    // The inventory, in the order the rules were added. A rule deleted from
    // this file fails here rather than being quietly forgotten.
    for (final String rule in <String>[
      // From the original brief.
      'Plan before coding',
      'One concern per commit',
      'Work only inside the current milestone',
      'Every schema change needs a forward migration test',
      'When you are uncertain about a domain rule',
      // Added during M0, in order.
      'One rounded value per order', // M0-01
      'Five bottom-nav destinations. Not six', // M0-01
      'Never pipe a gate command', // M0-03
      'Amend freely while unpushed, never after', // M0-03
      'sets the locale', // M0-04, locale-explicit widget tests
      'derived independently of the', // M0-08, money-test expectations
      'Control and invisible characters are built from codepoints', // M0-09
      'Never `git add -A`', // M0-14
      'Write files with the Write tool, never a shell heredoc', // M0-16
      'On a major version bump of any dependency', // M0-19
      'regenerates the schema dump in the same', // M0-19
      'Formatting and checking are two different commands', // M0-22
      'A test that would pass against an empty implementation', // M1-00.2
      'cannot be verified by the session that', // M1-00.2, bootstrap files
    ]) {
      test('"$rule"', () {
        expect(
          rules,
          contains(rule),
          reason: 'this rule was removed from CLAUDE.md',
        );
      });
    }
  });

  group('the invariants are numbered one to twelve', () {
    test('all twelve are present', () {
      for (int i = 1; i <= 12; i++) {
        expect(
          rules,
          contains('\n$i. '),
          reason: 'invariant $i is missing from the numbered list',
        );
      }
    });
  });

  test('no other file in the repository holds rules', () {
    // Inverted from a check that only forbade the name CONTRIBUTING.md — the
    // same denylist mistake the import guard replaced at M0-12. A denylist of
    // one name lets RULES.md, GUIDELINES.md or docs/process.md through, and the
    // property wanted is "there is one rules document", not "one particular
    // filename is absent".
    //
    // Scans every tracked text file for the markers that make a file a rules
    // document. A README summarising a constraint and pointing here is fine;
    // restating one normatively is a second place to look, and the two drift
    // with nothing to notice.
    final List<String> offenders = <String>[];

    for (final FileSystemEntity entity in Directory(
      '.',
    ).listSync(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final String path = entity.path.replaceAll(r'\', '/');
      if (!path.endsWith('.md') ||
          path.contains('/build/') ||
          path.contains('/.git/') ||
          path.contains('/.dart_tool/') ||
          path.endsWith('/CLAUDE.md') ||
          path == './CLAUDE.md') {
        continue;
      }

      final String text = entity.readAsStringSync();
      for (final String marker in _rulesDocumentMarkers) {
        if (text.contains(marker)) {
          offenders.add('$path contains "$marker"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'these files restate rules that belong only in CLAUDE.md: '
          '${offenders.join('; ')}',
    );
  });

  test('the PII rule still names what must be masked', () {
    // The most consequential rule in the file, and the one whose absence would
    // be least visible: nothing fails when a phone number reaches a log line.
    expect(rules, contains('country code and last three digits'));
    expect(rules, contains('two decimal places'));
  });

  test('the network ban still carries its M4 carve-out', () {
    // Without the exception the rule reads as absolute and someone eventually
    // "fixes" it; without the ban the exception is a licence.
    expect(rules, contains('No HTTP client of any kind before M4'));
    expect(rules, contains('Mapbox Matrix API'));
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Directories where text is rendered and the guarantee must hold.
const List<String> _scanned = <String>['lib/features', 'lib/shared'];

/// The one implementation allowed to construct a raw [Text], plus the throwaway
/// token gallery, which deliberately renders unstyled specimens.
const List<String> _allowed = <String>[
  'lib/shared/widgets/app_text.dart',
  'lib/features/_dev/',
];

/// Matches `Text(` and `Text.rich(` but not `AppText(`, `RichText(`,
/// `SelectableText(`, `TextButton(`, `TextField(`, `TextStyle(` or `TextSpan(`.
final RegExp _rawText = RegExp(r'(?<![\w.$])Text\s*(\(|\.rich\s*\()');

/// Strips `//` and `///` comment lines so prose mentioning `Text(` does not
/// trip the guard. Block comments are not handled; do not hide a violation in
/// one.
String _stripComments(String source) => source
    .split('\n')
    .where((String line) => !line.trimLeft().startsWith('//'))
    .join('\n');

List<File> _dartFilesIn(String directory) {
  final Directory dir = Directory(directory);
  if (!dir.existsSync()) {
    return const <File>[];
  }
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();
}

String _posix(String path) => path.replaceAll(r'\', '/');

void main() {
  test('no raw Text() outside AppText', () {
    // Discipline does not survive forty screens. AppText pairs every style
    // with the forced strut that keeps AR and FR line boxes identical; a bare
    // Text silently drops it and the layout shifts on locale switch.
    final List<String> violations = <String>[];

    for (final String directory in _scanned) {
      for (final File file in _dartFilesIn(directory)) {
        final String path = _posix(file.path);
        if (_allowed.any(path.contains)) {
          continue;
        }

        final List<String> lines = _stripComments(
          file.readAsStringSync(),
        ).split('\n');

        for (int i = 0; i < lines.length; i++) {
          if (_rawText.hasMatch(lines[i])) {
            violations.add('$path:${i + 1}  ${lines[i].trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use AppText(data, AppTextStyle.body) instead of a raw Text.\n'
          '${violations.join('\n')}',
    );
  });

  test('the guard actually matches a raw Text', () {
    // A guard that cannot fail is not a guard. These pin the regex so a future
    // "simplification" of it cannot quietly disable the check.
    expect(_rawText.hasMatch('return Text(data);'), isTrue);
    expect(_rawText.hasMatch('const Text('), isTrue);
    expect(_rawText.hasMatch('child: Text.rich(span)'), isTrue);
    expect(_rawText.hasMatch('Text (data)'), isTrue);
  });

  test('the guard does not match lookalikes', () {
    for (final String source in <String>[
      'AppText(data, AppTextStyle.body)',
      'RichText(text: span)',
      'SelectableText(data)',
      'TextButton(onPressed: null)',
      'TextField(controller: c)',
      'TextStyle(fontSize: 16)',
      'TextSpan(text: data)',
      'DefaultTextStyle(style: s)',
    ]) {
      expect(
        _rawText.hasMatch(source),
        isFalse,
        reason: 'false positive on: $source',
      );
    }
  });

  test('the allow list stays small', () {
    // Every entry here is a hole in the guarantee.
    expect(_allowed, hasLength(2));
  });
}

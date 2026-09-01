// Fails the build when `lib/domain/` line coverage falls below the bar.
//
// The bar is 90, not 100, and that is deliberate. A 100 gate turns every newly
// written uncovered line into a red build, which produces pressure to write
// tests that exist to move a number rather than to catch a defect. The project
// is at 100 today because the code deserved it, not because a gate demanded it.
//
// Domain only. It is pure Dart with no I/O and no platform, so there is no
// excuse there — which is not true of `data/`, where a meaningful share of the
// code is only reachable on a device.
//
// Usage: flutter test --coverage && dart run tool/check_domain_coverage.dart

import 'dart:io';

const double _threshold = 90.0;
const String _lcov = 'coverage/lcov.info';
const String _scope = 'lib/domain/';

void main() {
  final File file = File(_lcov);
  if (!file.existsSync()) {
    stderr.writeln(
      'no $_lcov — run `flutter test --coverage` before this check.',
    );
    exit(2);
  }

  String? current;
  int hit = 0;
  int total = 0;
  final Map<String, List<int>> perFile = <String, List<int>>{};

  for (final String line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).replaceAll(r'\', '/');
      perFile.putIfAbsent(current, () => <int>[0, 0]);
    } else if (line.startsWith('DA:') && current != null) {
      if (!current.contains(_scope)) {
        continue;
      }
      final List<String> parts = line.substring(3).split(',');
      final bool covered = int.parse(parts[1]) > 0;
      total++;
      perFile[current]![1]++;
      if (covered) {
        hit++;
        perFile[current]![0]++;
      }
    }
  }

  if (total == 0) {
    // Not "nothing to check" — an empty scope means the path moved or the
    // coverage run produced nothing, and passing silently would make this gate
    // permanently green for the wrong reason.
    stderr.writeln('no lines found under $_scope; the gate checked nothing.');
    exit(2);
  }

  final double pct = 100.0 * hit / total;
  stdout.writeln(
    'lib/domain/ line coverage: $hit/$total = ${pct.toStringAsFixed(2)}% '
    '(bar: ${_threshold.toStringAsFixed(0)}%)',
  );

  if (pct >= _threshold) {
    return;
  }

  // Name the worst offenders, so the failure says where to look rather than
  // only that a number moved.
  final List<MapEntry<String, List<int>>> worst =
      perFile.entries.where((MapEntry<String, List<int>> e) {
          return e.key.contains(_scope) && e.value[1] > 0;
        }).toList()
        ..sort((MapEntry<String, List<int>> a, MapEntry<String, List<int>> b) {
          return (a.value[0] / a.value[1]).compareTo(b.value[0] / b.value[1]);
        });

  stderr.writeln('below the bar. Least covered:');
  for (final MapEntry<String, List<int>> e in worst.take(5)) {
    final double p = 100.0 * e.value[0] / e.value[1];
    stderr.writeln(
      '  ${e.key.split('lib/').last}  '
      '${e.value[0]}/${e.value[1]}  ${p.toStringAsFixed(1)}%',
    );
  }
  exit(1);
}

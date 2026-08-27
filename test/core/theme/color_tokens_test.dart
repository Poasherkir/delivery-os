import 'dart:math' as math;

import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// (foreground, background, minimum ratio, why).
typedef _Check = (String, String, double, String);

const List<_Check> _checks = <_Check>[
  // Body text is held to AAA, not AA. This is read in direct Algerian sun.
  ('textPrimary', 'canvas', 7.0, 'primary text, outdoor'),
  ('textPrimary', 'surface', 7.0, 'primary text, outdoor'),
  ('textSecondary', 'canvas', 4.5, 'secondary text'),
  ('textSecondary', 'surface', 4.5, 'secondary text'),
  ('textDisabled', 'surface', 3.0, 'disabled text stays legible'),
  ('onAccent', 'accent', 4.5, 'label on the primary action'),
  ('accent', 'surface', 3.0, 'accent as a UI component'),
  ('accent', 'canvas', 3.0, 'accent as a UI component'),
  ('statusNeutralFg', 'statusNeutralBg', 4.5, 'pending chip'),
  ('statusProgressFg', 'statusProgressBg', 4.5, 'on_route / arrived chip'),
  ('statusSuccessFg', 'statusSuccessBg', 4.5, 'delivered chip'),
  ('statusProblemFg', 'statusProblemBg', 4.5, 'failed / returned chip'),
  ('moneyEarningFg', 'moneyEarningBg', 4.5, 'earnings figure'),
  ('moneyOwedFg', 'moneyOwedBg', 4.5, 'owed-to-company figure'),
  ('borderStrong', 'surface', 3.0, 'input outline must be perceivable'),
];

void main() {
  const Map<String, ColorTokens> themes = <String, ColorTokens>{
    'light': ColorTokens.light,
    'dark': ColorTokens.dark,
  };

  group('contrast', () {
    for (final MapEntry<String, ColorTokens> theme in themes.entries) {
      for (final _Check check in _checks) {
        final (String fg, String bg, double min, String why) = check;

        test('$fg on $bg meets $min:1 in ${theme.key} — $why', () {
          final Map<String, Color> all = theme.value.all;
          expect(
            _contrast(all[fg]!, all[bg]!),
            greaterThanOrEqualTo(min),
            reason: '$fg/$bg in ${theme.key}',
          );
        });
      }
    }
  });

  group('parity', () {
    test('light and dark define exactly the same roles', () {
      expect(ColorTokens.light.all.keys, ColorTokens.dark.all.keys);
    });

    test('no role is identical across the two themes', () {
      // A role that never changes is a role that was not really designed for
      // both themes.
      for (final String key in ColorTokens.light.all.keys) {
        expect(
          ColorTokens.light.all[key],
          isNot(ColorTokens.dark.all[key]),
          reason: '$key is the same in light and dark',
        );
      }
    });
  });

  group('the accent is reserved for actions', () {
    for (final MapEntry<String, ColorTokens> theme in themes.entries) {
      test('no status or money role reuses the accent in ${theme.key}', () {
        final ColorTokens t = theme.value;
        final List<Color> semantic = <Color>[
          t.statusNeutralFg,
          t.statusNeutralBg,
          t.statusProgressFg,
          t.statusProgressBg,
          t.statusSuccessFg,
          t.statusSuccessBg,
          t.statusProblemFg,
          t.statusProblemBg,
          t.moneyEarningFg,
          t.moneyEarningBg,
          t.moneyOwedFg,
          t.moneyOwedBg,
        ];
        expect(semantic, isNot(contains(t.accent)));
      });

      test('money-owed is not the problem colour in ${theme.key}', () {
        // Cash held on the company's behalf is custodial, not a failure.
        final ColorTokens t = theme.value;
        expect(t.moneyOwedFg, isNot(t.statusProblemFg));
        expect(t.moneyOwedBg, isNot(t.statusProblemBg));
      });
    }
  });
}

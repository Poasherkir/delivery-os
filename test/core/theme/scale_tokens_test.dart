import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

String _shape(ConfidenceTreatment t) =>
    '${t.borderWidth}|${t.dashPattern}|${t.filled}|${t.badge}';

void main() {
  group('spacing', () {
    test('the scale increases monotonically', () {
      for (int i = 1; i < SpaceTokens.scale.length; i++) {
        expect(SpaceTokens.scale[i], greaterThan(SpaceTokens.scale[i - 1]));
      }
    });

    test('every step sits on the 2pt grid', () {
      for (final double step in SpaceTokens.scale) {
        expect(step % 2, 0, reason: '$step is off-grid');
      }
    });

    test('the minimum tap target is 48 and the primary action exceeds it', () {
      expect(SpaceTokens.minTapTarget, 48);
      expect(
        SpaceTokens.primaryActionHeight,
        greaterThan(SpaceTokens.minTapTarget),
      );
    });
  });

  group('radius', () {
    test('the scale increases monotonically', () {
      for (int i = 1; i < RadiusTokens.scale.length; i++) {
        expect(RadiusTokens.scale[i], greaterThan(RadiusTokens.scale[i - 1]));
      }
    });

    test('nothing below the pill is soft enough to look consumer', () {
      expect(RadiusTokens.large, lessThanOrEqualTo(12));
    });
  });

  group('elevation', () {
    test('depth is carried by borders, not shadows', () {
      // The two levels almost everything uses must be shadowless.
      expect(ElevationTokens.flat.opacity, 0);
      expect(ElevationTokens.resting.opacity, 0);
      expect(ElevationTokens.resting.borderWidth, greaterThan(0));
    });

    test('no level exceeds the shadow ceiling', () {
      for (final ElevationToken token in ElevationTokens.scale) {
        expect(
          token.opacity,
          lessThanOrEqualTo(ElevationTokens.maxOpacity),
          reason: '${token.name} is heavier than the ceiling',
        );
      }
    });

    test('the scale never steps backwards', () {
      for (int i = 1; i < ElevationTokens.scale.length; i++) {
        expect(
          ElevationTokens.scale[i].opacity,
          greaterThanOrEqualTo(ElevationTokens.scale[i - 1].opacity),
        );
      }
    });
  });

  group('motion', () {
    test('the scale increases monotonically', () {
      for (int i = 1; i < MotionTokens.scale.length; i++) {
        expect(MotionTokens.scale[i], greaterThan(MotionTokens.scale[i - 1]));
      }
    });

    test('nothing animates for longer than a glance', () {
      expect(MotionTokens.slow.inMilliseconds, lessThanOrEqualTo(260));
    });
  });

  group('confidence', () {
    test('there is a treatment for every schema tier, in order', () {
      expect(ConfidenceTokens.byTier, hasLength(5));
      for (int i = 0; i < ConfidenceTokens.byTier.length; i++) {
        expect(ConfidenceTokens.byTier[i].tier, i);
      }
    });

    test('no two tiers look alike', () {
      // Confidence is read at a glance on a map. Two tiers sharing a treatment
      // would be indistinguishable, which defeats the point of the tiering.
      final Set<String> shapes = ConfidenceTokens.byTier.map(_shape).toSet();
      expect(shapes, hasLength(ConfidenceTokens.byTier.length));
    });

    test('only the unroutable tier and the confirmed tier carry a badge', () {
      expect(ConfidenceTokens.none.badge, ConfidenceBadge.unknown);
      expect(ConfidenceTokens.confirmed.badge, ConfidenceBadge.confirmed);
      for (final ConfidenceTreatment t in <ConfidenceTreatment>[
        ConfidenceTokens.centroid,
        ConfidenceTokens.geocoded,
        ConfidenceTokens.pinned,
      ]) {
        expect(t.badge, ConfidenceBadge.none, reason: 'tier ${t.tier}');
      }
    });

    test('confidence rises with solidity', () {
      // Dashed and hollow at the bottom, solid and filled at the top.
      expect(ConfidenceTokens.none.dashPattern, isNotNull);
      expect(ConfidenceTokens.centroid.dashPattern, isNotNull);
      expect(ConfidenceTokens.geocoded.dashPattern, isNull);
      expect(ConfidenceTokens.pinned.filled, isTrue);
      expect(ConfidenceTokens.confirmed.filled, isTrue);
      expect(ConfidenceTokens.none.filled, isFalse);
    });
  });
}

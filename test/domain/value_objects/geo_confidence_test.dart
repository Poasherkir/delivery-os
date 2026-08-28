import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:test/test.dart';

void main() {
  group('tiers match the schema', () {
    test('there are five, numbered 0 to 4 in order', () {
      // customer_addresses.geo_confidence persists these numbers, so they are
      // part of the schema. Reordering the enum would silently reinterpret
      // every stored pin.
      expect(GeoConfidence.values, hasLength(5));
      expect(GeoConfidence.values.map((GeoConfidence c) => c.tier), <int>[
        0,
        1,
        2,
        3,
        4,
      ]);
    });

    test('each name is bound to the tier the schema documents', () {
      expect(GeoConfidence.none.tier, 0);
      expect(GeoConfidence.communeCentroid.tier, 1);
      expect(GeoConfidence.geocoded.tier, 2);
      expect(GeoConfidence.driverPinned.tier, 3);
      expect(GeoConfidence.gpsConfirmed.tier, 4);
    });

    test('fromTier round-trips every tier', () {
      for (final GeoConfidence confidence in GeoConfidence.values) {
        expect(GeoConfidence.fromTier(confidence.tier), confidence);
      }
    });

    test('fromTier throws rather than degrading', () {
      // Degrading up would over-trust a coordinate the code does not
      // understand; degrading to none would silently drop a stop off the
      // route. Both are worse than failing loudly on data we wrote ourselves.
      for (final int unknown in <int>[-1, 5, 99]) {
        expect(() => GeoConfidence.fromTier(unknown), throwsArgumentError);
      }
    });
  });

  group('routing treatment, per §10.1', () {
    test('confidence 0 is never routable — invariant 9', () {
      expect(GeoConfidence.none.isRoutable, isFalse);
    });

    test('every other tier is routable', () {
      for (final GeoConfidence confidence in GeoConfidence.values) {
        if (confidence != GeoConfidence.none) {
          expect(confidence.isRoutable, isTrue, reason: confidence.name);
        }
      }
    });

    test('only a commune centroid is zone-only', () {
      // A centroid can be kilometres from the door, so it is clustered rather
      // than treated as an address.
      for (final GeoConfidence confidence in GeoConfidence.values) {
        expect(
          confidence.isZoneOnly,
          confidence == GeoConfidence.communeCentroid,
          reason: confidence.name,
        );
      }
    });

    test('only a geocoded string is flagged approximate', () {
      for (final GeoConfidence confidence in GeoConfidence.values) {
        expect(
          confidence.isApproximate,
          confidence == GeoConfidence.geocoded,
          reason: confidence.name,
        );
      }
    });

    test('driver-pinned and GPS-confirmed are exact', () {
      expect(GeoConfidence.driverPinned.isExact, isTrue);
      expect(GeoConfidence.gpsConfirmed.isExact, isTrue);
      expect(GeoConfidence.geocoded.isExact, isFalse);
      expect(GeoConfidence.communeCentroid.isExact, isFalse);
      expect(GeoConfidence.none.isExact, isFalse);
    });

    test('the four treatments partition the routable tiers', () {
      // Every routable tier gets exactly one treatment: no stop can be both
      // zone-clustered and exact, and none can fall through uncategorised.
      for (final GeoConfidence confidence in GeoConfidence.values) {
        if (!confidence.isRoutable) {
          continue;
        }
        final int treatments = <bool>[
          confidence.isZoneOnly,
          confidence.isApproximate,
          confidence.isExact,
        ].where((bool applies) => applies).length;

        expect(treatments, 1, reason: confidence.name);
      }
    });
  });

  group('ordering', () {
    test('compares by tier', () {
      expect(GeoConfidence.none < GeoConfidence.gpsConfirmed, isTrue);
      expect(GeoConfidence.gpsConfirmed > GeoConfidence.driverPinned, isTrue);
      expect(GeoConfidence.geocoded >= GeoConfidence.geocoded, isTrue);
      expect(GeoConfidence.geocoded <= GeoConfidence.geocoded, isTrue);
      expect(GeoConfidence.driverPinned < GeoConfidence.geocoded, isFalse);
    });

    test('is a total order over every pair', () {
      for (final GeoConfidence a in GeoConfidence.values) {
        for (final GeoConfidence b in GeoConfidence.values) {
          expect(
            (a < b) || (a > b) || a == b,
            isTrue,
            reason: '${a.name} vs ${b.name}',
          );
          expect(a.compareTo(b).sign, a.tier.compareTo(b.tier).sign);
        }
      }
    });

    test('sorts ascending', () {
      final List<GeoConfidence> shuffled = <GeoConfidence>[
        GeoConfidence.gpsConfirmed,
        GeoConfidence.none,
        GeoConfidence.geocoded,
        GeoConfidence.driverPinned,
        GeoConfidence.communeCentroid,
      ]..sort();

      expect(shuffled, GeoConfidence.values);
    });
  });

  group('upgrade is monotonic', () {
    test('never lowers, for any pair', () {
      // The property, over all 25 combinations rather than a sample.
      for (final GeoConfidence current in GeoConfidence.values) {
        for (final GeoConfidence evidence in GeoConfidence.values) {
          expect(
            current.upgrade(evidence) >= current,
            isTrue,
            reason: '${current.name}.upgrade(${evidence.name}) went down',
          );
        }
      }
    });

    test('takes the higher of the two', () {
      for (final GeoConfidence current in GeoConfidence.values) {
        for (final GeoConfidence evidence in GeoConfidence.values) {
          final GeoConfidence expected = current.tier >= evidence.tier
              ? current
              : evidence;
          expect(current.upgrade(evidence), expected);
        }
      }
    });

    test('weaker evidence is simply ignored', () {
      // A GPS fix does not stop being a GPS fix because a later order arrived
      // carrying only a commune.
      expect(
        GeoConfidence.gpsConfirmed.upgrade(GeoConfidence.communeCentroid),
        GeoConfidence.gpsConfirmed,
      );
      expect(
        GeoConfidence.gpsConfirmed.upgrade(GeoConfidence.none),
        GeoConfidence.gpsConfirmed,
      );
    });

    test('is idempotent and commutative', () {
      for (final GeoConfidence a in GeoConfidence.values) {
        expect(a.upgrade(a), a);
        for (final GeoConfidence b in GeoConfidence.values) {
          expect(a.upgrade(b), b.upgrade(a));
        }
      }
    });
  });

  group('demote is the only way down', () {
    test('reports what changed, and why', () {
      final PinCorrection correction = GeoConfidence.gpsConfirmed.demote(
        to: GeoConfidence.none,
        reason: PinCorrectionReason.capturedAwayFromDeliveryPoint,
      );

      // Everything an audit_logs entry needs, without the caller having to
      // assemble it.
      expect(correction.previous, GeoConfidence.gpsConfirmed);
      expect(correction.confidence, GeoConfidence.none);
      expect(
        correction.reason,
        PinCorrectionReason.capturedAwayFromDeliveryPoint,
      );
    });

    test('lowers to the requested tier', () {
      expect(
        GeoConfidence.gpsConfirmed
            .demote(
              to: GeoConfidence.communeCentroid,
              reason: PinCorrectionReason.reportedIncorrect,
            )
            .confidence,
        GeoConfidence.communeCentroid,
      );
    });

    test('refuses to raise', () {
      // Raising is upgrade's job. Allowing it here would let a correction path
      // quietly become a promotion path.
      expect(
        () => GeoConfidence.communeCentroid.demote(
          to: GeoConfidence.gpsConfirmed,
          reason: PinCorrectionReason.reportedIncorrect,
        ),
        throwsArgumentError,
      );
    });

    test('refuses a no-op', () {
      // Demoting to the tier you are already at almost certainly means the
      // caller has the direction wrong.
      for (final GeoConfidence confidence in GeoConfidence.values) {
        expect(
          () => confidence.demote(
            to: confidence,
            reason: PinCorrectionReason.reportedIncorrect,
          ),
          throwsArgumentError,
          reason: confidence.name,
        );
      }
    });

    test('nothing can be demoted below none', () {
      for (final GeoConfidence to in GeoConfidence.values) {
        expect(
          () => GeoConfidence.none.demote(
            to: to,
            reason: PinCorrectionReason.reportedIncorrect,
          ),
          throwsArgumentError,
        );
      }
    });

    test('every lowering pair is permitted', () {
      for (final GeoConfidence from in GeoConfidence.values) {
        for (final GeoConfidence to in GeoConfidence.values) {
          if (to < from) {
            final PinCorrection correction = from.demote(
              to: to,
              reason: PinCorrectionReason.reportedIncorrect,
            );
            expect(correction.confidence, to);
            expect(correction.previous, from);
          }
        }
      }
    });

    test('the error names the tier, never a coordinate', () {
      // Per the PII rule: nothing that reaches a log carries a location.
      try {
        // Assigned rather than discarded: demote is @useResult, so throwing
        // the value away does not compile cleanly.
        final PinCorrection unreachable = GeoConfidence.geocoded.demote(
          to: GeoConfidence.gpsConfirmed,
          reason: PinCorrectionReason.reportedIncorrect,
        );
        fail('expected an ArgumentError, got $unreachable');
      } on ArgumentError catch (e) {
        expect(e.toString(), contains('geocoded'));
      }
    });
  });

  group('PinCorrection', () {
    PinCorrection correction() => GeoConfidence.gpsConfirmed.demote(
      to: GeoConfidence.driverPinned,
      reason: PinCorrectionReason.reportedIncorrect,
    );

    test('is equal by value', () {
      expect(correction(), correction());
      expect(correction().hashCode, correction().hashCode);
      expect(
        correction(),
        isNot(
          GeoConfidence.gpsConfirmed.demote(
            to: GeoConfidence.none,
            reason: PinCorrectionReason.reportedIncorrect,
          ),
        ),
      );
    });

    test('always records a strict lowering', () {
      expect(correction().confidence < correction().previous, isTrue);
    });

    test('toString carries tiers and a reason, never a coordinate', () {
      expect(
        correction().toString(),
        'PinCorrection(gpsConfirmed -> driverPinned, reportedIncorrect)',
      );
    });
  });

  group('correction reasons', () {
    test('are enumerated, not free text', () {
      // Countable: "how often are we promoting fixes taken away from the door"
      // has to be answerable without parsing prose.
      expect(PinCorrectionReason.values, isNotEmpty);
      expect(
        PinCorrectionReason.values,
        contains(PinCorrectionReason.capturedAwayFromDeliveryPoint),
      );
      expect(
        PinCorrectionReason.values,
        contains(PinCorrectionReason.reportedIncorrect),
      );
    });
  });
}

import 'package:delivery_os/domain/entities/address.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:test/test.dart';

Address anAddress({
  String id = 'a1',
  int version = 1,
  String? detail,
  GeoConfidence confidence = GeoConfidence.none,
}) => Address(
  id: id,
  customerId: 'cust1',
  wilayaCode: 16,
  communeId: 1601,
  isPrimary: true,
  version: version,
  detail: detail,
  confidence: confidence,
);

void main() {
  group('identity is the id and the version together', () {
    test('the same row at the same version is the same address', () {
      expect(anAddress(), anAddress());
    });

    test('a different row is not', () {
      expect(anAddress(id: 'a1'), isNot(anAddress(id: 'a2')));
    });

    test('and the same row after a write is not', () {
      expect(anAddress(version: 1), isNot(anAddress(version: 2)));
    });

    test('an address is not equal to something else entirely', () {
      expect(anAddress(), isNot('a1'));
    });

    test('hashCode agrees with ==', () {
      expect(anAddress().hashCode, anAddress().hashCode);
      expect(anAddress(id: 'a1').hashCode, isNot(anAddress(id: 'a2').hashCode));
    });
  });

  group('isRoutable', () {
    test('is false at tier 0, which is where typing lands', () {
      // Invariant 9: never route a confidence-0 stop.
      expect(anAddress().isRoutable, isFalse);
    });

    test('and true from tier 1 upward', () {
      // Every tier is named, so a new one has to be decided rather than
      // inherited. A commune centroid is routable — clustered as a zone stop
      // rather than an address, which is §10.1's job, not this getter's.
      expect(
        anAddress(confidence: GeoConfidence.communeCentroid).isRoutable,
        isTrue,
      );
      expect(anAddress(confidence: GeoConfidence.geocoded).isRoutable, isTrue);
      expect(
        anAddress(confidence: GeoConfidence.driverPinned).isRoutable,
        isTrue,
      );
      expect(
        anAddress(confidence: GeoConfidence.gpsConfirmed).isRoutable,
        isTrue,
      );
    });

    test('and the check covers every tier there is', () {
      // The list above goes stale on its own. This fails the day a sixth tier
      // is added without a decision about whether it can be routed.
      expect(GeoConfidence.values, hasLength(5));
    });
  });

  group('toString', () {
    test('carries the commune, which is not a front door', () {
      expect(anAddress().toString(), contains('1601'));
      expect(anAddress().toString(), contains('a1'));
      expect(anAddress().toString(), contains('none'));
    });

    test('and never the detail', () {
      // With the phone number, a home address is the most sensitive pair in
      // this system. A leaked log line naming a building and a floor is a
      // household's front door.
      final String rendered = anAddress(detail: 'Bt 12, 3e étage').toString();

      expect(rendered, isNot(contains('Bt 12')));
      expect(rendered, isNot(contains('étage')));
    });
  });
}

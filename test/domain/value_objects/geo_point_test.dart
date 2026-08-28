import 'package:delivery_os/domain/value_objects/geo_point.dart';
import 'package:test/test.dart';

/// Algiers and Oran, used throughout. Rounded city coordinates, not anyone's
/// home.
final GeoPoint algiers = GeoPoint(36.7538, 3.0588);
final GeoPoint oran = GeoPoint(35.6969, -0.6331);

void main() {
  group('range validation', () {
    test('accepts the extremes', () {
      expect(GeoPoint(90, 180).latitude, 90);
      expect(GeoPoint(-90, -180).longitude, -180);
      expect(GeoPoint(0, 0).latitude, 0);
    });

    test('rejects out of range', () {
      for (final (double lat, double lon) in <(double, double)>[
        (90.0001, 0),
        (-90.0001, 0),
        (0, 180.0001),
        (0, -180.0001),
        (1000, 0),
        (0, 1000),
      ]) {
        expect(
          GeoPoint.tryCreate(lat, lon),
          isNull,
          reason: '($lat, $lon) was accepted',
        );
        expect(() => GeoPoint(lat, lon), throwsArgumentError);
      }
    });

    test('rejects NaN and infinity', () {
      // A NaN coordinate would propagate silently through every distance
      // calculation and produce a route with no error anywhere.
      for (final double bad in <double>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(GeoPoint.tryCreate(bad, 0), isNull);
        expect(GeoPoint.tryCreate(0, bad), isNull);
      }
    });

    test('does not reject coordinates outside Algeria', () {
      // Construction validates range, never geography. Rejecting here would
      // make the type unusable for map taps, test fixtures and anything near a
      // border.
      expect(GeoPoint.tryCreate(48.8566, 2.3522), isNotNull); // Paris
      expect(GeoPoint.tryCreate(-33.8688, 151.2093), isNotNull); // Sydney
    });
  });

  group('isPlausiblyAlgerian', () {
    test('recognises Algerian cities', () {
      for (final GeoPoint point in <GeoPoint>[
        algiers,
        oran,
        GeoPoint(36.365, 6.6147), // Constantine
        GeoPoint(22.785, 5.5228), // Tamanrasset, deep south
        GeoPoint(27.6738, -8.1478), // Tindouf, far west
      ]) {
        expect(point.isPlausiblyAlgerian, isTrue, reason: '$point');
      }
    });

    test('rejects grossly wrong coordinates', () {
      for (final GeoPoint point in <GeoPoint>[
        GeoPoint(48.8566, 2.3522), // Paris
        GeoPoint(-33.8688, 151.2093), // Sydney
        GeoPoint(0, 0), // a zeroed fix
        GeoPoint(
          3.0588,
          36.7538,
        ), // Algiers with latitude and longitude swapped
      ]) {
        expect(point.isPlausiblyAlgerian, isFalse, reason: '$point');
      }
    });

    test('but does NOT exclude the neighbours, and cannot', () {
      // Pinned deliberately. Algeria's bounding rectangle spans about
      // 18.9N-37.2N and 8.7W-12.1E, which necessarily contains Casablanca and
      // Tunis — a rectangle cannot trace a border. Asserting the false
      // positives keeps anyone from later reading this as a nationality test.
      expect(
        GeoPoint(33.5731, -7.5898).isPlausiblyAlgerian,
        isTrue,
      ); // Casablanca
      expect(GeoPoint(36.8065, 10.1815).isPlausiblyAlgerian, isTrue); // Tunis
    });

    test('is a helper and not a guard', () {
      // The property that matters: a point can fail the check and still exist.
      final GeoPoint paris = GeoPoint(48.8566, 2.3522);
      expect(paris.isPlausiblyAlgerian, isFalse);
      expect(paris.latitude, 48.8566);
    });
  });

  group('geohash', () {
    test('matches the published reference vector', () {
      // The canonical geohash example: (57.64911, 10.40744) encodes to
      // u4pruydqqvj at precision 11. Taken from the published specification,
      // not from this implementation — an expected value derived from the code
      // under test would verify nothing.
      expect(
        GeoPoint(57.64911, 10.40744).geohash(precision: 11),
        'u4pruydqqvj',
      );
    });

    test('encodes the corners', () {
      // The south-west corner is all-zero and the north-east all-z by
      // construction: every subdivision goes low, or every one goes high.
      expect(GeoPoint(-90, -180).geohash(), '000000000');
      expect(GeoPoint(90, 180).geohash(), 'zzzzzzzzz');
    });

    test('a point exactly on a midpoint takes the lower cell', () {
      // (0, 0) sits on the boundary of four cells. The convention is
      // documented rather than incidental: implementations that compare with
      // >= produce 's00000000' here instead.
      expect(GeoPoint(0, 0).geohash(), '7zzzzzzzz');
    });

    test('produces exactly the requested number of characters', () {
      for (int precision = 1; precision <= 12; precision++) {
        expect(
          algiers.geohash(precision: precision),
          hasLength(precision),
          reason: 'precision $precision',
        );
      }
    });

    test('is a prefix code', () {
      // The property the proximity index depends on: a shorter hash is always
      // a prefix of a longer one for the same point.
      final String full = algiers.geohash(precision: 12);
      for (int precision = 1; precision < 12; precision++) {
        expect(
          full.startsWith(algiers.geohash(precision: precision)),
          isTrue,
          reason: 'precision $precision is not a prefix of the full hash',
        );
      }
    });

    test('nearby points share a long prefix', () {
      // Two addresses about 30 m apart in the same Algiers block.
      final GeoPoint a = GeoPoint(36.7538, 3.0588);
      final GeoPoint b = GeoPoint(36.7540, 3.0590);

      expect(a.distanceTo(b), lessThan(50));
      expect(
        a.geohash(precision: 5),
        b.geohash(precision: 5),
        reason: 'a 5-character cell is ~5 km and should contain both',
      );
    });

    test('distant points share nothing', () {
      expect(algiers.geohash(precision: 1), isNot(oran.geohash(precision: 1)));
    });

    test('uses the geohash alphabet, which omits a, i, l and o', () {
      // Those four are excluded to avoid transcription errors. A hash
      // containing one would mean the alphabet string had been mistyped.
      final String hash = algiers.geohash(precision: 12);
      for (final String forbidden in <String>['a', 'i', 'l', 'o']) {
        expect(hash, isNot(contains(forbidden)));
      }
      expect(RegExp(r'^[0-9b-hjkmnp-z]+$').hasMatch(hash), isTrue);
    });

    test('rejects a precision outside 1..12', () {
      expect(() => algiers.geohash(precision: 0), throwsArgumentError);
      expect(() => algiers.geohash(precision: -1), throwsArgumentError);
      expect(() => algiers.geohash(precision: 13), throwsArgumentError);
    });
  });

  group('distanceTo', () {
    // Anchors are closed forms, checkable on paper against
    // GeoPoint.earthRadiusMetres = 6371008.8.
    const double metresPerDegree = 111195.0802; // R * pi / 180

    test('is zero for the same point', () {
      expect(algiers.distanceTo(algiers), 0);
    });

    test('one degree of latitude is R * pi / 180', () {
      // A degree along a meridian is exactly one degree of arc, so this is the
      // definition of the radian rather than a measurement.
      expect(
        GeoPoint(0, 0).distanceTo(GeoPoint(1, 0)),
        closeTo(metresPerDegree, 0.01),
      );
      expect(
        GeoPoint(45, 3).distanceTo(GeoPoint(46, 3)),
        closeTo(metresPerDegree, 0.01),
      );
    });

    test('one degree of longitude at the equator is the same', () {
      expect(
        GeoPoint(0, 0).distanceTo(GeoPoint(0, 1)),
        closeTo(metresPerDegree, 0.01),
      );
    });

    test('a degree of longitude shrinks by cos(latitude)', () {
      // At 60 degrees north, cos(60) = 0.5 exactly, so the spacing halves.
      expect(
        GeoPoint(60, 0).distanceTo(GeoPoint(60, 1)),
        closeTo(metresPerDegree * 0.5, 50),
      );
    });

    test('antipodal points are half the circumference', () {
      // pi * R.
      expect(
        GeoPoint(0, 0).distanceTo(GeoPoint(0, 180)),
        closeTo(3.141592653589793 * GeoPoint.earthRadiusMetres, 1),
      );
      expect(
        GeoPoint(-90, 0).distanceTo(GeoPoint(90, 0)),
        closeTo(3.141592653589793 * GeoPoint.earthRadiusMetres, 1),
      );
    });

    test('Algiers to Oran is about 351 km', () {
      // Independent sanity check on a real pair: the straight-line distance is
      // commonly given as roughly 350 km.
      expect(algiers.distanceTo(oran), closeTo(351371, 500));
    });

    test('is symmetric', () {
      expect(algiers.distanceTo(oran), closeTo(oran.distanceTo(algiers), 1e-6));
    });

    test('handles very short distances without cancellation', () {
      // The asin form is chosen for exactly this case; the atan2 form loses
      // precision when the points are metres apart, which is the common case
      // here.
      final GeoPoint a = GeoPoint(36.75380, 3.05880);
      final GeoPoint b = GeoPoint(36.75381, 3.05880);

      // One hundred-thousandth of a degree of latitude.
      expect(a.distanceTo(b), closeTo(metresPerDegree * 1e-5, 0.01));
    });

    test('crosses the antimeridian by the short way', () {
      // Two points two degrees apart with 179 and -179 longitude. A naive
      // difference would call this 358 degrees.
      final double distance = GeoPoint(0, 179).distanceTo(GeoPoint(0, -179));
      expect(distance, closeTo(metresPerDegree * 2, 1));
    });
  });

  group('identity', () {
    test('equality is by both components', () {
      expect(GeoPoint(36.7538, 3.0588), GeoPoint(36.7538, 3.0588));
      expect(GeoPoint(36.7538, 3.0588), isNot(GeoPoint(36.7539, 3.0588)));
      expect(GeoPoint(36.7538, 3.0588), isNot(GeoPoint(36.7538, 3.0589)));
    });

    test('transposed coordinates are not equal', () {
      // A lat/lng swap is the classic geo bug; it must not compare equal.
      expect(GeoPoint(3.0588, 36.7538), isNot(GeoPoint(36.7538, 3.0588)));
    });

    test('hashes agree with equality', () {
      expect(
        GeoPoint(36.7538, 3.0588).hashCode,
        GeoPoint(36.7538, 3.0588).hashCode,
      );
    });
  });

  group('toString is masked', () {
    test('rounds to two decimal places', () {
      // Two decimals is about a kilometre: enough to tell Algiers from Oran in
      // a log, not enough to find a house.
      expect(algiers.toString(), 'GeoPoint(36.75, 3.06)');
      expect(oran.toString(), 'GeoPoint(35.70, -0.63)');
    });

    test('never carries the full precision', () {
      final GeoPoint precise = GeoPoint(36.753821, 3.058812);
      expect(precise.toString(), isNot(contains('753821')));
      expect(precise.toString(), isNot(contains('058812')));
      expect(precise.latitude, 36.753821);
    });
  });
}

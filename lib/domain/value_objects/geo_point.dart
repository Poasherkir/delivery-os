import 'dart:math' as math;

/// A WGS84 coordinate.
///
/// Deliberately **only** a latitude and a longitude. No accuracy radius, no
/// timestamp, no confidence — those describe a *measurement*, and most of the
/// coordinates in this app are not measurements. A commune centroid, a map tap
/// and a route origin have no accuracy radius, and adding the field here would
/// force every one of them to carry a meaningless null.
///
/// Accuracy lives on the rows that record a fix (`customer_addresses.accuracy_m`,
/// `delivery_attempts.accuracy_m`, see `docs/ARCHITECTURE.md` §10.5) and
/// confidence is its own value object.
final class GeoPoint {
  const GeoPoint._(this.latitude, this.longitude);

  /// Throws [ArgumentError] unless both values are finite and in range.
  ///
  /// Range only. There is deliberately no bounding-box check here — see
  /// [isPlausiblyAlgerian] for why that must not gate construction.
  factory GeoPoint(double latitude, double longitude) {
    final GeoPoint? point = tryCreate(latitude, longitude);
    if (point == null) {
      throw ArgumentError(
        'latitude must be a finite value in [-90, 90] and longitude a finite '
        'value in [-180, 180]',
      );
    }
    return point;
  }

  /// Returns null rather than throwing.
  static GeoPoint? tryCreate(double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite) {
      return null;
    }
    if (latitude < minLatitude || latitude > maxLatitude) {
      return null;
    }
    if (longitude < minLongitude || longitude > maxLongitude) {
      return null;
    }
    return GeoPoint._(latitude, longitude);
  }

  static const double minLatitude = -90;
  static const double maxLatitude = 90;
  static const double minLongitude = -180;
  static const double maxLongitude = 180;

  /// WGS84 mean radius, in metres. The sphere the haversine assumes.
  static const double earthRadiusMetres = 6371008.8;

  static const int minGeohashPrecision = 1;

  /// 12 characters is 60 bits, a cell a few centimetres across — far finer
  /// than any consumer GPS fix.
  static const int maxGeohashPrecision = 12;

  /// Stored in `customer_addresses.geohash`. Nine characters is roughly a
  /// 5-metre cell; shorter prefixes are queried for proximity.
  static const int defaultGeohashPrecision = 9;

  final double latitude;
  final double longitude;

  /// Whether this sits inside Algeria's bounding box.
  ///
  /// **A helper, never a constructor guard.** A bounding box is a rectangle and
  /// a country is not: rejecting a real pin because a border town in Tindouf
  /// falls a few kilometres outside a rectangle somebody typed is a worse
  /// failure than storing an odd coordinate. Use it to warn or to flag for
  /// review, never to refuse data the driver is standing in front of.
  ///
  /// **It is a weak signal, in both directions.** Algeria's rectangle spans
  /// roughly 18.9°N–37.2°N and 8.7°W–12.1°E, which also contains Casablanca,
  /// Tunis, and parts of Mali, Niger, Libya and Mauritania. This answers "is
  /// this coordinate grossly wrong" — a transposed latitude and longitude, a
  /// zeroed fix, a European address — and nothing finer. It is not a
  /// nationality test and must never be described as one.
  bool get isPlausiblyAlgerian =>
      latitude >= _algeriaMinLatitude &&
      latitude <= _algeriaMaxLatitude &&
      longitude >= _algeriaMinLongitude &&
      longitude <= _algeriaMaxLongitude;

  static const double _algeriaMinLatitude = 18.9;
  static const double _algeriaMaxLatitude = 37.2;
  static const double _algeriaMinLongitude = -8.7;
  static const double _algeriaMaxLongitude = 12.1;

  /// The geohash of this point at [precision] characters.
  ///
  /// Geohash is a prefix code: a shorter hash is always a prefix of a longer
  /// one for the same point, and two nearby points share a long prefix. That is
  /// what makes it a usable proximity index on SQLite, which has no PostGIS.
  ///
  /// The converse does not hold and must not be assumed: two points either side
  /// of a cell boundary can be metres apart and share no prefix at all. A
  /// prefix query is a cheap first pass, not an answer.
  ///
  /// A coordinate falling exactly on a cell midpoint takes the lower cell.
  String geohash({int precision = defaultGeohashPrecision}) {
    if (precision < minGeohashPrecision || precision > maxGeohashPrecision) {
      throw ArgumentError.value(
        precision,
        'precision',
        'must be between $minGeohashPrecision and $maxGeohashPrecision',
      );
    }

    double latitudeLow = minLatitude;
    double latitudeHigh = maxLatitude;
    double longitudeLow = minLongitude;
    double longitudeHigh = maxLongitude;

    final StringBuffer hash = StringBuffer();
    int bits = 0;
    int accumulator = 0;
    bool longitudeTurn = true;

    while (hash.length < precision) {
      if (longitudeTurn) {
        final double middle = (longitudeLow + longitudeHigh) / 2;
        if (longitude > middle) {
          accumulator = (accumulator << 1) | 1;
          longitudeLow = middle;
        } else {
          accumulator <<= 1;
          longitudeHigh = middle;
        }
      } else {
        final double middle = (latitudeLow + latitudeHigh) / 2;
        if (latitude > middle) {
          accumulator = (accumulator << 1) | 1;
          latitudeLow = middle;
        } else {
          accumulator <<= 1;
          latitudeHigh = middle;
        }
      }

      longitudeTurn = !longitudeTurn;
      bits++;

      if (bits == 5) {
        hash.write(_base32[accumulator]);
        bits = 0;
        accumulator = 0;
      }
    }

    return hash.toString();
  }

  /// Great-circle distance to [other], in metres.
  ///
  /// Haversine on a sphere of [earthRadiusMetres]. Good to a few tenths of a
  /// percent against the WGS84 ellipsoid, which is far inside the error of the
  /// coordinates themselves — and this feeds a fallback distance matrix, not a
  /// survey.
  double distanceTo(GeoPoint other) {
    final double lat1 = _toRadians(latitude);
    final double lat2 = _toRadians(other.latitude);
    final double deltaLat = lat2 - lat1;
    final double deltaLon = _toRadians(other.longitude - longitude);

    // Squared by multiplication rather than math.pow, which returns num and
    // drags a cast through the expression.
    final double halfLat = math.sin(deltaLat / 2);
    final double halfLon = math.sin(deltaLon / 2);
    final double a =
        halfLat * halfLat + math.cos(lat1) * math.cos(lat2) * halfLon * halfLon;

    // asin form rather than atan2: numerically better for the very short
    // distances that dominate here, where a is tiny.
    return 2 * earthRadiusMetres * math.asin(math.sqrt(a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  /// Masked to two decimal places — roughly a kilometre.
  ///
  /// A customer's exact home coordinates in a crash payload is the same
  /// disclosure as their phone number (§13). Two decimals is enough to tell
  /// Algiers from Oran in a log and not enough to find a house. The exact
  /// values are on [latitude] and [longitude].
  @override
  String toString() =>
      'GeoPoint(${latitude.toStringAsFixed(2)}, '
      '${longitude.toStringAsFixed(2)})';

  /// Geohash alphabet: base32 with a, i, l and o removed.
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
}

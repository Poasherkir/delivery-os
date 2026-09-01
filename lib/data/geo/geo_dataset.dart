import 'dart:convert';

import '../../domain/value_objects/geo_point.dart';

/// A bundled geography file could not be trusted, so nothing was loaded.
///
/// Every failure here is a broken build artifact rather than anything a driver
/// did, so it fails loudly and completely: a half-loaded geography table would
/// show a picker that silently omits wilayas.
final class GeoDatasetFormatException implements Exception {
  const GeoDatasetFormatException(this.message);

  final String message;

  @override
  String toString() => 'GeoDatasetFormatException: $message';
}

/// One wilaya from the bundled dataset.
final class WilayaRecord {
  const WilayaRecord({
    required this.code,
    required this.nameFr,
    required this.nameAr,
    this.point,
  });

  final int code;
  final String nameFr;
  final String nameAr;

  /// Null when the dataset ships names without coordinates. A wilaya with no
  /// centroid is still a valid wilaya for the address picker.
  final GeoPoint? point;

  /// Computed here, never read from the file.
  ///
  /// A geohash in the dataset would be a second source of truth that can
  /// disagree with the coordinates beside it, and nothing would notice.
  String? get geohash => point?.geohash();
}

/// One commune from the bundled dataset.
final class CommuneRecord {
  const CommuneRecord({
    required this.id,
    required this.wilayaCode,
    required this.nameFr,
    required this.nameAr,
    this.point,
    this.boundary,
  });

  final int id;
  final int wilayaCode;
  final String nameFr;
  final String nameAr;
  final GeoPoint? point;

  /// GeoJSON polygon, re-encoded compactly. Null when the dataset has none, and
  /// that is expected rather than exceptional — §10.5 gate 2 degrades to a
  /// wilaya-scaled radius without it.
  final String? boundary;

  String? get geohash => point?.geohash();
}

/// A parsed, validated pair of geography files.
///
/// Parsing and hydration are deliberately separate: everything that can be
/// wrong with the *file* is caught here, on plain strings, with no database in
/// play. `GeoLoader` then only has to worry about what is already in the table.
final class GeoDataset {
  const GeoDataset({
    required this.version,
    required this.wilayas,
    required this.communes,
  });

  final String version;
  final List<WilayaRecord> wilayas;
  final List<CommuneRecord> communes;

  /// The version of the wilayas file, without touching the communes file.
  ///
  /// Exists so a launch that has nothing to do can decide that cheaply. The
  /// wilayas file is 69 rows; the communes file is roughly 1,541 and may carry
  /// boundary polygons, so decoding it on every cold start to discover there is
  /// no work would be the single most expensive thing startup does — on a 2 GB
  /// phone, for nothing.
  static String peekVersion(String wilayasJson) => _requiredString(
    _object(wilayasJson, 'wilayas file')['version'],
    'wilayas file "version"',
  );

  /// Parses both files together, because the commune → wilaya foreign key
  /// cannot be checked from either one alone.
  ///
  /// **No assertion about how many wilayas exist.** Algeria went 48 → 58 in
  /// 2019 → 69 in 2025, and which structure is correct for this app is a
  /// carrier question rather than a state one (§1.5): a driver reconciles
  /// against the company's bordereau, not the Journal Officiel. A code is valid
  /// if and only if it is in the file.
  static GeoDataset parse({
    required String wilayasJson,
    required String communesJson,
  }) {
    final Map<String, Object?> wilayaDoc = _object(wilayasJson, 'wilayas file');
    final Map<String, Object?> communeDoc = _object(
      communesJson,
      'communes file',
    );

    final String version = _requiredString(
      wilayaDoc['version'],
      'wilayas file "version"',
    );
    final String communeVersion = _requiredString(
      communeDoc['version'],
      'communes file "version"',
    );
    if (version != communeVersion) {
      // Two halves of one dataset. Mixing them would produce a commune list
      // built against a wilaya structure it was never checked against, which
      // is the failure mode the 2025 reform makes likely.
      throw GeoDatasetFormatException(
        'version mismatch: wilayas file is "$version", communes file is '
        '"$communeVersion"',
      );
    }

    final List<WilayaRecord> wilayas = _parseWilayas(
      _requiredList(wilayaDoc['wilayas'], 'wilayas file "wilayas"'),
    );
    final List<CommuneRecord> communes = _parseCommunes(
      _requiredList(communeDoc['communes'], 'communes file "communes"'),
      knownWilayas: <int>{for (final WilayaRecord w in wilayas) w.code},
    );

    return GeoDataset(version: version, wilayas: wilayas, communes: communes);
  }

  static List<WilayaRecord> _parseWilayas(List<Object?> raw) {
    if (raw.isEmpty) {
      // A dataset with no wilayas is a broken file, not an empty one. Accepting
      // it would retire every wilaya in the table on the next load.
      throw const GeoDatasetFormatException('the wilayas file lists none');
    }

    final List<WilayaRecord> out = <WilayaRecord>[];
    final Set<int> seen = <int>{};

    for (int i = 0; i < raw.length; i++) {
      final Map<String, Object?> row = _rowAt(raw, i, 'wilaya');

      // The rowid-alias guard, and the reason this loader exists in this shape.
      //
      // `wilayas.code` is an INTEGER PRIMARY KEY, which SQLite makes an alias
      // for the rowid: a row inserted without one is silently assigned 1, 2,
      // 3... and wilaya 1 is Adrar. A dataset missing a code would not fail —
      // it would quietly produce a geography table that looks populated and
      // maps every address to the wrong province.
      final int code = _requiredInt(row['code'], 'wilaya at index $i: "code"');
      if (!seen.add(code)) {
        throw GeoDatasetFormatException('wilaya code $code appears twice');
      }

      out.add(
        WilayaRecord(
          code: code,
          nameFr: _requiredString(row['name_fr'], 'wilaya $code: "name_fr"'),
          nameAr: _requiredString(row['name_ar'], 'wilaya $code: "name_ar"'),
          point: _optionalPoint(row, 'wilaya $code'),
        ),
      );
    }

    return out;
  }

  static List<CommuneRecord> _parseCommunes(
    List<Object?> raw, {
    required Set<int> knownWilayas,
  }) {
    if (raw.isEmpty) {
      throw const GeoDatasetFormatException('the communes file lists none');
    }

    final List<CommuneRecord> out = <CommuneRecord>[];
    final Set<int> seen = <int>{};

    for (int i = 0; i < raw.length; i++) {
      final Map<String, Object?> row = _rowAt(raw, i, 'commune');

      final int id = _requiredInt(row['id'], 'commune at index $i: "id"');
      if (!seen.add(id)) {
        throw GeoDatasetFormatException('commune id $id appears twice');
      }

      final int wilayaCode = _requiredInt(
        row['wilaya'],
        'commune $id: "wilaya"',
      );
      if (!knownWilayas.contains(wilayaCode)) {
        // The check the 2025 reform makes worth having. Commune *shapes* did
        // not move when eleven wilayas were carved out of existing ones, but
        // their *parent* did — so a pre-reform commune file paired with a
        // post-reform wilaya file points at a province that is not there.
        throw GeoDatasetFormatException(
          'commune $id belongs to wilaya $wilayaCode, which the wilayas file '
          'does not list',
        );
      }

      final Object? boundary = row['boundary'];

      out.add(
        CommuneRecord(
          id: id,
          wilayaCode: wilayaCode,
          nameFr: _requiredString(row['name_fr'], 'commune $id: "name_fr"'),
          nameAr: _requiredString(row['name_ar'], 'commune $id: "name_ar"'),
          point: _optionalPoint(row, 'commune $id'),
          // Re-encoded rather than passed through, so whitespace in the source
          // file cannot change what lands in the column.
          boundary: boundary == null ? null : jsonEncode(boundary),
        ),
      );
    }

    return out;
  }

  /// Coordinates are optional, but half a coordinate is a bug rather than a
  /// partial dataset — a lone latitude cannot be plotted or geohashed.
  static GeoPoint? _optionalPoint(Map<String, Object?> row, String where) {
    final Object? lat = row['lat'];
    final Object? lon = row['lon'];

    if (lat == null && lon == null) {
      return null;
    }
    if (lat == null || lon == null) {
      throw GeoDatasetFormatException(
        '$where has only one of "lat" and "lon"; a half coordinate cannot be '
        'plotted',
      );
    }

    final GeoPoint? point = GeoPoint.tryCreate(
      _requiredDouble(lat, '$where: "lat"'),
      _requiredDouble(lon, '$where: "lon"'),
    );
    if (point == null) {
      throw GeoDatasetFormatException('$where has out-of-range coordinates');
    }
    return point;
  }

  static Map<String, Object?> _object(String json, String where) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (e) {
      throw GeoDatasetFormatException('$where is not valid JSON: ${e.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw GeoDatasetFormatException('$where is not a JSON object');
    }
    return decoded;
  }

  static Map<String, Object?> _rowAt(List<Object?> raw, int i, String what) {
    final Object? row = raw[i];
    if (row is! Map<String, Object?>) {
      throw GeoDatasetFormatException('$what at index $i is not an object');
    }
    return row;
  }

  static List<Object?> _requiredList(Object? value, String where) {
    if (value is! List<Object?>) {
      throw GeoDatasetFormatException('$where is missing or not a list');
    }
    return value;
  }

  static String _requiredString(Object? value, String where) {
    if (value is! String || value.trim().isEmpty) {
      throw GeoDatasetFormatException('$where is missing or empty');
    }
    return value;
  }

  static int _requiredInt(Object? value, String where) {
    if (value is! int) {
      throw GeoDatasetFormatException(
        '$where is missing or not a whole number',
      );
    }
    return value;
  }

  static double _requiredDouble(Object? value, String where) {
    if (value is num) {
      return value.toDouble();
    }
    throw GeoDatasetFormatException('$where is not a number');
  }
}

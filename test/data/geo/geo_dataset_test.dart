import 'dart:convert';
import 'dart:io';

import 'package:delivery_os/data/geo/geo_dataset.dart';
import 'package:test/test.dart';

String _read(String name) => File('test/fixtures/geo/$name').readAsStringSync();

/// Re-serializes the fixture with one edit, so a malformed case is a *planted*
/// change to a real file rather than a hand-written string that might not
/// resemble the real thing in any other respect.
String _wilayasWith(void Function(List<Map<String, Object?>> rows) edit) {
  final Map<String, Object?> doc =
      jsonDecode(_read('wilayas.json')) as Map<String, Object?>;
  final List<Map<String, Object?>> rows = <Map<String, Object?>>[
    for (final Object? r in doc['wilayas']! as List<Object?>)
      Map<String, Object?>.of(r! as Map<String, Object?>),
  ];
  edit(rows);
  doc['wilayas'] = rows;
  return jsonEncode(doc);
}

String _communesWith(void Function(List<Map<String, Object?>> rows) edit) {
  final Map<String, Object?> doc =
      jsonDecode(_read('communes.json')) as Map<String, Object?>;
  final List<Map<String, Object?>> rows = <Map<String, Object?>>[
    for (final Object? r in doc['communes']! as List<Object?>)
      Map<String, Object?>.of(r! as Map<String, Object?>),
  ];
  edit(rows);
  doc['communes'] = rows;
  return jsonEncode(doc);
}

GeoDataset _parse({String? wilayas, String? communes}) => GeoDataset.parse(
  wilayasJson: wilayas ?? _read('wilayas.json'),
  communesJson: communes ?? _read('communes.json'),
);

Matcher _rejects(String fragment) => throwsA(
  isA<GeoDatasetFormatException>().having(
    (GeoDatasetFormatException e) => e.message,
    'message',
    contains(fragment),
  ),
);

void main() {
  group('the fixture parses', () {
    test('and yields every row', () {
      final GeoDataset d = _parse();

      expect(d.version, 'fixture-1');
      expect(d.wilayas, hasLength(3));
      expect(d.communes, hasLength(4));
    });

    test('with no assertion about how many wilayas exist', () {
      // Deliberate. 48 in 2019, 58, then 69 in 2025 — and which structure is
      // right for this app is a carrier question, not a state one: the driver
      // reconciles against the company's bordereau. A code is valid if and only
      // if the file lists it, so a one-wilaya file is as valid as a 69-wilaya
      // one.
      final GeoDataset d = _parse(
        wilayas: _wilayasWith(
          (List<Map<String, Object?>> rows) => rows.removeRange(1, 3),
        ),
        communes: _communesWith(
          (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['wilaya'] != 16),
        ),
      );

      expect(d.wilayas, hasLength(1));
    });
  });

  group('the rowid-alias guard', () {
    // `wilayas.code` is an INTEGER PRIMARY KEY, which SQLite makes an alias for
    // the rowid. A row inserted without one is silently assigned 1, 2, 3 — and
    // wilaya 1 is Adrar. Without this rejection the app would come up with a
    // geography table that looks fully populated and maps addresses to the
    // wrong province, with nothing anywhere to notice.

    test('a wilaya with no code is rejected', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0].remove('code'),
          ),
        ),
        _rejects('"code" is missing'),
      );
    });

    test('a wilaya with a null code is rejected', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0]['code'] = null,
          ),
        ),
        _rejects('"code" is missing'),
      );
    });

    test('a non-integer code is rejected', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0]['code'] = '16',
          ),
        ),
        _rejects('not a whole number'),
      );
    });

    test('a commune with no id is rejected the same way', () {
      expect(
        () => _parse(
          communes: _communesWith(
            (List<Map<String, Object?>> rows) => rows[0].remove('id'),
          ),
        ),
        _rejects('"id" is missing'),
      );
    });

    test('the error names which row, so it can be found in a large file', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[2].remove('code'),
          ),
        ),
        _rejects('index 2'),
      );
    });
  });

  group('duplicates', () {
    test('two wilayas with the same code are rejected', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[1]['code'] = 16,
          ),
        ),
        _rejects('code 16 appears twice'),
      );
    });

    test('two communes with the same id are rejected', () {
      expect(
        () => _parse(
          communes: _communesWith(
            (List<Map<String, Object?>> rows) => rows[1]['id'] = 1601,
          ),
        ),
        _rejects('id 1601 appears twice'),
      );
    });
  });

  group('the commune to wilaya link', () {
    test('a commune pointing at an unlisted wilaya is rejected', () {
      // The check the November 2025 reform makes worth having. Commune shapes
      // did not move when eleven wilayas were carved out of existing ones, but
      // their parent did — so a pre-reform commune file paired with a
      // post-reform wilaya file points at a province that is not there.
      expect(
        () => _parse(
          communes: _communesWith(
            (List<Map<String, Object?>> rows) => rows[0]['wilaya'] = 58,
          ),
        ),
        _rejects('which the wilayas file does not list'),
      );
    });

    test('and a missing wilaya key is rejected too', () {
      expect(
        () => _parse(
          communes: _communesWith(
            (List<Map<String, Object?>> rows) => rows[0].remove('wilaya'),
          ),
        ),
        _rejects('"wilaya" is missing'),
      );
    });
  });

  group('names are required', () {
    test('a missing Arabic name is rejected', () {
      // Arabic is the primary display name for most drivers, so it is not
      // optional the way a coordinate is.
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0].remove('name_ar'),
          ),
        ),
        _rejects('"name_ar" is missing'),
      );
    });

    test('an empty name is rejected as firmly as a missing one', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0]['name_fr'] = '   ',
          ),
        ),
        _rejects('"name_fr" is missing or empty'),
      );
    });
  });

  group('coordinates are optional', () {
    test('a wilaya without them still loads', () {
      // Adrar in the fixture. Better a usable list than no list.
      final WilayaRecord adrar = _parse().wilayas.firstWhere(
        (WilayaRecord w) => w.code == 1,
      );

      expect(adrar.point, isNull);
      expect(adrar.geohash, isNull);
      expect(adrar.nameAr, isNotEmpty);
    });

    test('but half a coordinate is a bug, not a partial dataset', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0].remove('lon'),
          ),
        ),
        _rejects('only one of "lat" and "lon"'),
      );
    });

    test('and out-of-range coordinates are rejected', () {
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows[0]['lat'] = 91.0,
          ),
        ),
        _rejects('out-of-range'),
      );
    });

    test('an integer coordinate is accepted, not just a double', () {
      // JSON has one number type, so a whole-degree coordinate arrives as int.
      final GeoDataset d = _parse(
        wilayas: _wilayasWith((List<Map<String, Object?>> rows) {
          rows[0]['lat'] = 36;
          rows[0]['lon'] = 3;
        }),
      );

      expect(d.wilayas.first.point!.latitude, 36.0);
    });
  });

  group('the geohash is computed, never read', () {
    test('it comes from the coordinates in the file', () {
      final WilayaRecord alger = _parse().wilayas.firstWhere(
        (WilayaRecord w) => w.code == 16,
      );

      // Derived independently: precision-9 geohash of 36.7538, 3.0588. The
      // record must agree with GeoPoint rather than with anything in the file.
      expect(alger.geohash, alger.point!.geohash());
      expect(alger.geohash, hasLength(9));
    });

    test('a geohash in the file is ignored entirely', () {
      // A geohash in the dataset would be a second source of truth that can
      // disagree with the coordinates beside it, silently. The file does not
      // get a vote.
      final GeoDataset d = _parse(
        wilayas: _wilayasWith(
          (List<Map<String, Object?>> rows) => rows[0]['geohash'] = 'zzzzzzzzz',
        ),
      );

      expect(d.wilayas.first.geohash, isNot('zzzzzzzzz'));
    });
  });

  group('boundaries', () {
    test('are optional', () {
      final CommuneRecord husseinDey = _parse().communes.firstWhere(
        (CommuneRecord c) => c.id == 1605,
      );

      expect(husseinDey.boundary, isNull);
    });

    test(
      'are re-encoded, so source whitespace cannot leak into the column',
      () {
        final CommuneRecord babEzzouar = _parse().communes.firstWhere(
          (CommuneRecord c) => c.id == 1601,
        );

        expect(babEzzouar.boundary, isNotNull);
        expect(babEzzouar.boundary, isNot(contains('\n')));
        expect(
          jsonDecode(babEzzouar.boundary!),
          isA<Map<String, Object?>>().having(
            (Map<String, Object?> m) => m['type'],
            'type',
            'Polygon',
          ),
        );
      },
    );
  });

  group('the two files must belong together', () {
    test('a version mismatch is rejected', () {
      // Mixing halves would produce a commune list built against a wilaya
      // structure it was never checked against — likely, given the reform.
      final Map<String, Object?> doc =
          jsonDecode(_read('communes.json')) as Map<String, Object?>;
      doc['version'] = 'fixture-2';

      expect(
        () => _parse(communes: jsonEncode(doc)),
        _rejects('version mismatch'),
      );
    });
  });

  group('an empty list is a broken file, not an empty one', () {
    test('no wilayas is rejected', () {
      // Accepting it would retire every wilaya in the table on the next load.
      expect(
        () => _parse(
          wilayas: _wilayasWith(
            (List<Map<String, Object?>> rows) => rows.clear(),
          ),
        ),
        _rejects('the wilayas file lists none'),
      );
    });

    test('no communes is rejected', () {
      expect(
        () => _parse(
          communes: _communesWith(
            (List<Map<String, Object?>> rows) => rows.clear(),
          ),
        ),
        _rejects('the communes file lists none'),
      );
    });
  });

  test('malformed JSON fails with a readable message', () {
    expect(() => _parse(wilayas: '{ not json'), _rejects('not valid JSON'));
  });
}

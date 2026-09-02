import 'dart:convert';
import 'dart:io';

// Only AppDatabase: the Drift Wilaya and Commune collide with the domain
// types, and both names are correct for what they are.
import 'package:delivery_os/data/db/app_database.dart' show AppDatabase;
import 'package:delivery_os/data/geo/geo_dataset.dart';
import 'package:delivery_os/data/geo/geo_loader.dart';
import 'package:delivery_os/data/repositories/drift_geography_repository.dart';
import 'package:delivery_os/domain/entities/place.dart';
import 'package:delivery_os/domain/repositories/geography_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

String _asset(String name) => File('assets/geo/$name').readAsStringSync();

/// The bundled fixture, optionally with rows removed to simulate a dataset
/// update that retires them.
GeoDataset _dataset({
  bool Function(Map<String, Object?> row)? keepWilaya,
  bool Function(Map<String, Object?> row)? keepCommune,
  String version = 'fixture-1',
}) {
  Map<String, Object?> doc(
    String file,
    String key,
    bool Function(Map<String, Object?>)? keep,
  ) {
    final Map<String, Object?> d =
        jsonDecode(_asset(file)) as Map<String, Object?>;
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[
      for (final Object? r in d[key]! as List<Object?>)
        Map<String, Object?>.of(r! as Map<String, Object?>),
    ];
    d[key] = keep == null ? rows : rows.where(keep).toList();
    d['version'] = version;
    return d;
  }

  return GeoDataset.parse(
    wilayasJson: jsonEncode(doc('wilayas.json', 'wilayas', keepWilaya)),
    communesJson: jsonEncode(doc('communes.json', 'communes', keepCommune)),
  );
}

void main() {
  late AppDatabase db;
  late GeographyRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = DriftGeographyRepository(db);
    await GeoLoader(db).load(_dataset());
  });

  tearDown(() => db.close());

  group('choosing', () {
    test('wilayas come back in code order, not alphabetical', () async {
      // The wilaya number is what every carrier and every bordereau uses, so a
      // driver looking for 16 scans for 16. Alphabetical would put Adrar first
      // by accident and Alger second by coincidence, and break at the tenth.
      expect((await repo.selectableWilayas()).map((Wilaya w) => w.code), <int>[
        1,
        16,
        31,
      ]);
    });

    test('communes are scoped to their wilaya', () async {
      final List<Commune> alger = await repo.selectableCommunes(16);

      expect(alger.map((Commune c) => c.nameFr), <String>[
        'Bab Ezzouar',
        'Hussein Dey',
      ]);
    });

    test('search matches the French name', () async {
      expect(
        (await repo.searchCommunes('ezzouar')).map((Commune c) => c.id),
        <int>[1601],
      );
    });

    test('and the Arabic name', () async {
      // A driver reading a French label off a parcel and a driver typing
      // Arabic have to find the same commune.
      expect((await repo.searchCommunes('باب')).map((Commune c) => c.id), <int>[
        1601,
      ]);
    });

    test('search can be scoped to one wilaya', () async {
      expect(await repo.searchCommunes('a', wilayaCode: 31), hasLength(1));
      expect(
        (await repo.searchCommunes('a', wilayaCode: 31)).single.nameFr,
        'Oran',
      );
    });

    test('an empty query inside a wilaya lists it', () async {
      // A picker that has been opened but not typed into shows the wilaya's
      // communes rather than nothing.
      expect(await repo.searchCommunes('', wilayaCode: 16), hasLength(2));
    });

    test('an empty unscoped query returns nothing, not everything', () async {
      // 1,541 rows into a phone that will render twelve of them is work nobody
      // sees, and it is not what an empty search field means here.
      expect(await repo.searchCommunes('   '), isEmpty);
    });
  });

  group('a retired row', () {
    setUp(() async {
      // Oran disappears, as an administrative merge would make it.
      await GeoLoader(db).load(
        _dataset(
          keepWilaya: (Map<String, Object?> w) => w['code'] != 31,
          keepCommune: (Map<String, Object?> c) => c['wilaya'] != 31,
          version: 'fixture-2',
        ),
      );
    });

    test('is never offered', () async {
      // Offering a driver a wilaya the state has abolished would produce
      // addresses nobody can deliver to.
      expect(
        (await repo.selectableWilayas()).map((Wilaya w) => w.code),
        isNot(contains(31)),
      );
      expect(await repo.selectableCommunes(31), isEmpty);
    });

    test('and never matches a search', () async {
      expect(await repo.searchCommunes('oran'), isEmpty);
    });

    test('but still resolves by code, with its name', () async {
      // The other half, and the reason retirement exists instead of deletion:
      // an address recorded before the reform has to keep rendering.
      final Wilaya? oran = await repo.wilayaByCode(31);

      expect(oran, isNotNull);
      expect(oran!.nameFr, 'Oran');
      expect(oran.isRetired, isTrue);
    });

    test('and by commune id', () async {
      final Commune? c = await repo.communeById(3101);

      expect(c, isNotNull);
      expect(c!.nameFr, 'Oran');
      expect(c.isRetired, isTrue);
    });

    test('and comes back when the dataset lists it again', () async {
      await GeoLoader(db).load(_dataset(version: 'fixture-3'));

      expect(
        (await repo.selectableWilayas()).map((Wilaya w) => w.code),
        contains(31),
      );
    });
  });

  group('resolving something that never existed', () {
    test('returns null rather than inventing a placeholder', () async {
      // A stored id with no row is a real bug — a dataset that dropped a code
      // it should have retired. Returning an empty-named Wilaya would render
      // as a blank and hide it.
      expect(await repo.wilayaByCode(99), isNull);
      expect(await repo.communeById(999999), isNull);
    });
  });
}

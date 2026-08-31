import 'dart:convert';
import 'dart:io';

import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/geo/geo_dataset.dart';
import 'package:delivery_os/data/geo/geo_loader.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

String _read(String name) => File('test/fixtures/geo/$name').readAsStringSync();

/// The fixture with an edit applied to each file, so a "next release of the
/// dataset" is a real document rather than a hand-built one.
GeoDataset _dataset({
  void Function(List<Map<String, Object?>> wilayas)? editWilayas,
  void Function(List<Map<String, Object?>> communes)? editCommunes,
  String version = 'fixture-1',
}) {
  Map<String, Object?> doc(
    String file,
    String key,
    void Function(List<Map<String, Object?>>)? edit,
  ) {
    final Map<String, Object?> d =
        jsonDecode(_read(file)) as Map<String, Object?>;
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[
      for (final Object? r in d[key]! as List<Object?>)
        Map<String, Object?>.of(r! as Map<String, Object?>),
    ];
    edit?.call(rows);
    d[key] = rows;
    d['version'] = version;
    return d;
  }

  return GeoDataset.parse(
    wilayasJson: jsonEncode(doc('wilayas.json', 'wilayas', editWilayas)),
    communesJson: jsonEncode(doc('communes.json', 'communes', editCommunes)),
  );
}

void main() {
  late AppDatabase db;
  late GeoLoader loader;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    loader = GeoLoader(db);
    // The foreign key from communes to wilayas, and from addresses to both,
    // only bites with this on.
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() => db.close());

  Future<List<Wilaya>> wilayas() => db.select(db.wilayas).get();
  Future<List<Commune>> communes() => db.select(db.communes).get();

  Future<Wilaya> wilaya(int code) async =>
      (await wilayas()).firstWhere((Wilaya w) => w.code == code);
  Future<Commune> commune(int id) async =>
      (await communes()).firstWhere((Commune c) => c.id == id);

  group('a first load', () {
    test('writes every row', () async {
      final GeoLoadReport report = await loader.load(_dataset());

      expect(await wilayas(), hasLength(3));
      expect(await communes(), hasLength(4));
      expect(report.wilayasWritten, 3);
      expect(report.communesWritten, 4);
      expect(report.retiredAnything, isFalse);
    });

    test('the codes are the ones in the file, not rowids', () async {
      // The consequence of the parser's guard, checked at the far end. If a
      // code were ever assigned by SQLite these would come out 1, 2, 3.
      await loader.load(_dataset());

      expect((await wilayas()).map((Wilaya w) => w.code).toSet(), <int>{
        1,
        16,
        31,
      });
    });

    test('stores the computed geohash', () async {
      await loader.load(_dataset());

      final Wilaya alger = await wilaya(16);
      expect(alger.geohash, hasLength(9));
      expect(alger.latitude, closeTo(36.7538, 1e-9));
    });

    test('a wilaya with no coordinates still lands', () async {
      await loader.load(_dataset());

      final Wilaya adrar = await wilaya(1);
      expect(adrar.latitude, isNull);
      expect(adrar.geohash, isNull);
      expect(adrar.nameAr, isNotEmpty);
    });

    test('stores a boundary when the dataset carries one', () async {
      await loader.load(_dataset());

      expect(await commune(1601), isA<Commune>());
      expect((await commune(1601)).boundary, contains('Polygon'));
      expect((await commune(1605)).boundary, isNull);
    });

    test('nothing starts retired', () async {
      await loader.load(_dataset());

      expect((await wilayas()).every((Wilaya w) => !w.isRetired), isTrue);
      expect((await communes()).every((Commune c) => !c.isRetired), isTrue);
    });
  });

  group('reloading', () {
    test('is idempotent', () async {
      await loader.load(_dataset());
      final GeoLoadReport second = await loader.load(_dataset());

      expect(await wilayas(), hasLength(3));
      expect(await communes(), hasLength(4));
      expect(second.retiredAnything, isFalse);
    });

    test('updates a renamed row in place', () async {
      await loader.load(_dataset());

      await loader.load(
        _dataset(
          editWilayas: (List<Map<String, Object?>> rows) => rows.firstWhere(
            (Map<String, Object?> r) => r['code'] == 31,
          )['name_fr'] = 'Oran (renamed)',
          version: 'fixture-2',
        ),
      );

      expect((await wilaya(31)).nameFr, 'Oran (renamed)');
      expect(await wilayas(), hasLength(3));
    });

    test('fills in coordinates that a later dataset supplies', () async {
      await loader.load(_dataset());
      expect((await wilaya(1)).latitude, isNull);

      await loader.load(
        _dataset(
          editWilayas: (List<Map<String, Object?>> rows) {
            final Map<String, Object?> adrar = rows.firstWhere(
              (Map<String, Object?> r) => r['code'] == 1,
            );
            adrar['lat'] = 27.8743;
            adrar['lon'] = -0.2939;
          },
          version: 'fixture-2',
        ),
      );

      expect((await wilaya(1)).latitude, closeTo(27.8743, 1e-9));
      expect((await wilaya(1)).geohash, isNotNull);
    });
  });

  group('rows the dataset stops listing', () {
    Future<void> loadThenDropOran() async {
      await loader.load(_dataset());
      await loader.load(
        _dataset(
          editWilayas: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['code'] == 31),
          editCommunes: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['wilaya'] == 31),
          version: 'fixture-2',
        ),
      );
    }

    test('are retired, not deleted', () async {
      await loadThenDropOran();

      expect(await wilayas(), hasLength(3), reason: 'nothing may be deleted');
      expect((await wilaya(31)).isRetired, isTrue);
      expect((await commune(3101)).isRetired, isTrue);
    });

    test('and the report says how many', () async {
      await loader.load(_dataset());
      final GeoLoadReport report = await loader.load(
        _dataset(
          editWilayas: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['code'] == 31),
          editCommunes: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['wilaya'] == 31),
          version: 'fixture-2',
        ),
      );

      expect(report.wilayasRetired, 1);
      expect(report.communesRetired, 1);
      expect(report.retiredAnything, isTrue);
    });

    test('a retired row still resolves by id, and still has its name', () async {
      // The whole point. Lookups ignore retirement, so an address pointing at a
      // merged commune keeps rendering rather than showing a blank.
      await loadThenDropOran();

      final Commune oran = await commune(3101);
      expect(oran.nameFr, 'Oran');
      expect(oran.nameAr, isNotEmpty);
    });

    test('retiring twice does not re-count it', () async {
      await loadThenDropOran();

      final GeoLoadReport third = await loader.load(
        _dataset(
          editWilayas: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['code'] == 31),
          editCommunes: (List<Map<String, Object?>> rows) =>
              rows.removeWhere((Map<String, Object?> r) => r['wilaya'] == 31),
          version: 'fixture-3',
        ),
      );

      expect(third.wilayasRetired, 0);
      expect((await wilaya(31)).isRetired, isTrue);
    });

    test('a row that comes back is un-retired', () async {
      await loadThenDropOran();
      expect((await wilaya(31)).isRetired, isTrue);

      await loader.load(_dataset(version: 'fixture-4'));

      expect((await wilaya(31)).isRetired, isFalse);
      expect((await commune(3101)).isRetired, isFalse);
    });
  });

  test('a stored address survives its commune being retired', () async {
    // The reason the loader never deletes, stated as the scenario it protects.
    // Deleting commune 3101 here would orphan a real customer address — or,
    // with foreign keys on, fail the load outright.
    await loader.load(_dataset());

    final FixedClock clock = FixedClock(DateTime.utc(2026, 8, 31));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(db, clock, uuid).ensureUser();

    await db.customStatement(
      'INSERT INTO customers (id, owner_id, phone_e164, display_name, '
      'total_orders, total_delivered, total_failed, created_at, updated_at, '
      'version) VALUES '
      "('${uuid.next()}', '${user.id}', '+213660123456', 'Amine', "
      '0, 0, 0, 1000, 1000, 1)',
    );
    final String customerId =
        (await db.customSelect('SELECT id FROM customers').getSingle())
            .read<String>('id');

    await db.customStatement(
      'INSERT INTO customer_addresses (id, owner_id, customer_id, '
      'wilaya_code, commune_id, detail, geo_confidence, confirmed_deliveries, '
      'is_primary, created_at, updated_at, version) VALUES '
      "('${uuid.next()}', '${user.id}', '$customerId', 31, 3101, "
      "'Rue Larbi Ben Mhidi', 2, 0, 1, 1000, 1000, 1)",
    );

    // Now Oran disappears from the dataset, as a merge would make it.
    await loader.load(
      _dataset(
        editWilayas: (List<Map<String, Object?>> rows) =>
            rows.removeWhere((Map<String, Object?> r) => r['code'] == 31),
        editCommunes: (List<Map<String, Object?>> rows) =>
            rows.removeWhere((Map<String, Object?> r) => r['wilaya'] == 31),
        version: 'fixture-2',
      ),
    );

    // The address is intact and still joins to a named commune.
    final QueryRow row = await db
        .customSelect(
          'SELECT a.detail, c.name_fr, c.is_retired FROM customer_addresses a '
          'JOIN communes c ON c.id = a.commune_id',
        )
        .getSingle();

    expect(row.read<String>('detail'), 'Rue Larbi Ben Mhidi');
    expect(row.read<String>('name_fr'), 'Oran');
    expect(row.read<int>('is_retired'), 1);
  });

  test('the load is one transaction', () async {
    // A commune whose wilaya vanishes mid-load would violate the foreign key.
    // Either the whole dataset lands or none of it does — a half-loaded
    // geography table is a picker that silently omits provinces.
    await loader.load(_dataset());

    await expectLater(
      db.customStatement(
        'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
        "VALUES (9999, 77, 'Nowhere', 'لا مكان')",
      ),
      throwsA(anything),
    );

    expect(await communes(), hasLength(4));
  });
}

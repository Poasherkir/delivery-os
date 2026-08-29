import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/conventions/entity_stamp.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

const String _userId = '0199a1b2-c3d4-7000-8000-000000000001';
const String _companyId = '0199a1b2-c3d4-7000-8000-000000000002';
const String _ruleId = '0199a1b2-c3d4-7000-8000-000000000003';

Set<String> _columns(TableInfo<Table, Object?> table) =>
    table.$columns.map((GeneratedColumn<Object?> c) => c.name).toSet();

void main() {
  late AppDatabase db;
  late EntityStamper stamper;
  late EntityStamp stamp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    stamper = EntityStamper(FixedClock(DateTime.utc(2026, 8, 29, 7, 30)));
    stamp = stamper.forInsert();
    // Off by default in SQLite. M0-18 turns it on for the app; the tests that
    // assert a constraint actually bites need it here.
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() => db.close());

  Future<void> insertUser({String id = _userId, PhoneE164? phone}) => db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          id: id,
          displayName: 'Malik',
          createdAt: stamp.createdAt,
          updatedAt: stamp.updatedAt,
          phone: Value<PhoneE164?>(phone),
        ),
      );

  Future<void> insertCompany({String id = _companyId, String? owner}) => db
      .into(db.companies)
      .insert(
        CompaniesCompanion.insert(
          id: id,
          name: 'Yalidine',
          ownerId: owner ?? _userId,
          createdAt: stamp.createdAt,
          updatedAt: stamp.updatedAt,
          version: stamp.version,
        ),
      );

  group('the five tables exist with the right shape', () {
    test('users has no owner and no version', () {
      final Set<String> columns = _columns(db.users);

      expect(
        columns,
        containsAll(<String>[
          'id',
          'phone',
          'display_name',
          'locale',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );
      // It *is* the owner, and an account-less MVP has one of them.
      expect(columns, isNot(contains('owner_id')));
      expect(columns, isNot(contains('version')));
    });

    test('companies is an owned mutable entity', () {
      expect(
        _columns(db.companies),
        containsAll(<String>[
          'id',
          'owner_id',
          'name',
          'logo_path',
          'contact_phone',
          'notes',
          'is_active',
          'created_at',
          'updated_at',
          'deleted_at',
          'version',
        ]),
      );
    });

    test('payment_rules is append-only, and says rule_version', () {
      final Set<String> columns = _columns(db.paymentRules);

      expect(
        columns,
        containsAll(<String>[
          'id',
          'owner_id',
          'company_id',
          'rule_version',
          'spec',
          'effective_from',
          'created_at',
        ]),
      );
      // The absences are invariant 8 made structural. A rule that can be
      // updated breaks every settlement computed from it.
      expect(columns, isNot(contains('updated_at')));
      expect(columns, isNot(contains('deleted_at')));
      // And the name: `version` here would be the audit column, which somebody
      // would eventually attach a stamper to.
      expect(columns, isNot(contains('version')));
    });

    test('reference tables carry no audit columns at all', () {
      for (final Set<String> columns in <Set<String>>[
        _columns(db.wilayas),
        _columns(db.communes),
      ]) {
        for (final String audit in <String>[
          'owner_id',
          'created_at',
          'updated_at',
          'deleted_at',
          'version',
        ]) {
          expect(columns, isNot(contains(audit)));
        }
      }
    });

    test('communes carries a nullable boundary for point-in-polygon', () {
      final Map<String, GeneratedColumn<Object?>> columns =
          <String, GeneratedColumn<Object?>>{
            for (final GeneratedColumn<Object?> c in db.communes.$columns)
              c.name: c,
          };

      expect(columns.keys, contains('boundary'));
      expect(columns['boundary']!.$nullable, isTrue);
      // A dataset without centroids must still load.
      expect(columns['latitude']!.$nullable, isTrue);
      expect(columns['longitude']!.$nullable, isTrue);
    });
  });

  group('every owned table declares its owner foreign key', () {
    test('read out of the real DDL, not the Dart', () async {
      // The FK cannot live on the mixin — drift will not resolve a `references`
      // written there — so each table overrides ownerId. This is what stops
      // that override from being something a table has to remember: it reads
      // what SQLite actually created.
      final List<QueryRow> tables = await db
          .customSelect(
            "SELECT name, sql FROM sqlite_master WHERE type = 'table'",
          )
          .get();

      final List<String> missing = <String>[];
      for (final QueryRow row in tables) {
        final String sql = row.read<String>('sql');
        if (!sql.contains('owner_id')) {
          continue;
        }
        if (!sql.contains('REFERENCES users')) {
          missing.add(row.read<String>('name'));
        }
      }

      expect(
        missing,
        isEmpty,
        reason:
            'these tables have an owner_id with no foreign key to users: '
            '${missing.join(', ')}',
      );
    });

    test('and the constraint actually bites', () async {
      await insertUser();

      expect(
        () => insertCompany(owner: '0199a1b2-c3d4-7000-8000-00000000dead'),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('users', () {
    test(
      'accepts a driver with no phone, because the MVP has no account',
      () async {
        await insertUser();
        final User row = await db.select(db.users).getSingle();

        expect(row.phone, isNull);
        expect(row.displayName, 'Malik');
      },
    );

    test('defaults the locale to Arabic', () async {
      await insertUser();
      expect((await db.select(db.users).getSingle()).locale, 'ar');
    });

    test(
      'allows several rows with no phone, but not a duplicate one',
      () async {
        // SQLite permits many nulls in a unique index, which is why nullable is
        // safe here. A real duplicate is still rejected.
        await insertUser();
        await insertUser(id: '0199a1b2-c3d4-7000-8000-00000000000a');

        await db.delete(db.users).go();
        await insertUser(phone: PhoneE164.parse('0550123456'));

        expect(
          () => insertUser(
            id: '0199a1b2-c3d4-7000-8000-00000000000b',
            phone: PhoneE164.parse('+213 550 123 456'),
          ),
          throwsA(isA<SqliteException>()),
        );
      },
    );
  });

  group('payment_rules', () {
    Future<void> insertRule({
      required int ruleVersion,
      String id = _ruleId,
      String spec = '{"version":1}',
    }) => db
        .into(db.paymentRules)
        .insert(
          PaymentRulesCompanion.insert(
            id: id,
            ownerId: _userId,
            companyId: _companyId,
            ruleVersion: ruleVersion,
            spec: spec,
            effectiveFrom: '2026-08-29',
            createdAt: stamp.createdAt,
          ),
        );

    setUp(() async {
      await insertUser();
      await insertCompany();
    });

    test('a company may hold many versions', () async {
      await insertRule(ruleVersion: 1);
      await insertRule(
        ruleVersion: 2,
        id: '0199a1b2-c3d4-7000-8000-00000000000c',
      );

      expect(await db.select(db.paymentRules).get(), hasLength(2));
    });

    test('but not the same version twice', () async {
      await insertRule(ruleVersion: 1);

      expect(
        () => insertRule(
          ruleVersion: 1,
          id: '0199a1b2-c3d4-7000-8000-00000000000d',
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'the spec round-trips byte for byte, unknown fields included',
      () async {
        // The reason this column has no typed converter. A rule written by a
        // future build, carrying a field this one has never heard of, must come
        // back exactly as stored — otherwise the settlements computed from it
        // stop being reproducible.
        const String futureSpec =
            '{"version":9,"delivered":{"driver_commission":'
            '{"type":"invented_in_2028","amount":30000}},"unknown_field":true}';

        await insertRule(ruleVersion: 1, spec: futureSpec);

        final PaymentRule row = await db.select(db.paymentRules).getSingle();
        expect(row.spec, futureSpec);
      },
    );

    test('effective_from is a calendar date, stored as text', () async {
      await insertRule(ruleVersion: 1);

      final QueryRow raw = await db
          .customSelect('SELECT effective_from FROM payment_rules')
          .getSingle();

      expect(raw.read<String>('effective_from'), '2026-08-29');
    });
  });

  group('geography', () {
    test('a wilaya loads without a centroid', () async {
      await db
          .into(db.wilayas)
          .insert(
            WilayasCompanion.insert(
              code: const Value<int>(16),
              nameFr: 'Alger',
              nameAr: 'الجزائر',
            ),
          );

      final Wilaya row = await db.select(db.wilayas).getSingle();
      expect(row.code, 16);
      expect(row.latitude, isNull);
      expect(row.geohash, isNull);
    });

    test('a commune belongs to a wilaya, and the constraint bites', () async {
      await db
          .into(db.wilayas)
          .insert(
            WilayasCompanion.insert(
              code: const Value<int>(16),
              nameFr: 'Alger',
              nameAr: 'الجزائر',
            ),
          );
      await db
          .into(db.communes)
          .insert(
            CommunesCompanion.insert(
              id: const Value<int>(1601),
              wilayaCode: 16,
              nameFr: 'Bab Ezzouar',
              nameAr: 'باب الزوار',
            ),
          );

      expect(await db.select(db.communes).getSingle(), isA<Commune>());
      expect(
        () => db
            .into(db.communes)
            .insert(
              CommunesCompanion.insert(
                id: const Value<int>(9901),
                wilayaCode: 99,
                nameFr: 'Nowhere',
                nameAr: 'لا مكان',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a wilaya inserted without a code gets an invented one', () async {
      // Pinned because it is a hazard, not because it is desirable.
      //
      // `code` is INTEGER and the primary key, which makes it a rowid alias
      // even though the PRIMARY KEY is declared as a table constraint — so
      // NOT NULL does not bite, and a missing code is silently assigned 1, 2,
      // 3. For bundled reference data that would mean inventing wilaya codes
      // that no dataset ever contained.
      //
      // Nothing in the schema can prevent it, so M0-22's loader is the guard:
      // it supplies every code explicitly from the dataset and fails on a row
      // that has none. This test exists so that requirement is discoverable
      // from here rather than being folklore.
      final int assigned = await db
          .into(db.wilayas)
          .insert(
            WilayasCompanion.insert(nameFr: 'Nowhere', nameAr: 'لا مكان'),
          );

      expect(assigned, 1);
      expect((await db.select(db.wilayas).getSingle()).code, 1);
    });

    test('wilaya codes are not range-checked', () async {
      // Algeria went 48 -> 58 -> 69. A code is valid iff it is in this table.
      await db
          .into(db.wilayas)
          .insert(
            WilayasCompanion.insert(
              code: const Value<int>(69),
              nameFr: 'El Meniaa',
              nameAr: 'المنيعة',
            ),
          );
      expect(await db.select(db.wilayas).getSingle(), isA<Wilaya>());
    });
  });
}

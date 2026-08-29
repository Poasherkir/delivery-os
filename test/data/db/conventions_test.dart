import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/conventions/converters.dart';
import 'package:delivery_os/data/db/conventions/entity_stamp.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'conventions_fixture.dart';

const String _id = '0199a1b2-c3d4-7e5f-8a9b-0c1d2e3f4a5b';
const String _ownerId = '0199a1b2-c3d4-7000-8000-000000000001';

Set<String> _columnNames(TableInfo<Table, Object?> table) =>
    table.$columns.map((GeneratedColumn<Object?> c) => c.name).toSet();

void main() {
  late ConventionsFixtureDb db;
  late FixedClock clock;
  late EntityStamper stamper;

  setUp(() {
    db = ConventionsFixtureDb(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 8, 29, 7, 30, 15, 250));
    stamper = EntityStamper(clock);
  });

  tearDown(() => db.close());

  group('invariant 3: each category gets exactly its own columns', () {
    test('an owned mutable entity carries all five', () {
      expect(
        _columnNames(db.ownedThings),
        containsAll(<String>[
          'id',
          'owner_id',
          'created_at',
          'updated_at',
          'deleted_at',
          'version',
        ]),
      );
    });

    test(
      'an append-only record carries owner_id and created_at, and no more',
      () {
        final Set<String> columns = _columnNames(db.appendOnlyThings);

        expect(columns, containsAll(<String>['id', 'owner_id', 'created_at']));
        // The absences are the point. An updated_at on a row that is never
        // updated would be a lie, and a soft delete would rewrite history —
        // which is what invariant 7 forbids for settlements.
        expect(columns, isNot(contains('updated_at')));
        expect(columns, isNot(contains('deleted_at')));
        expect(columns, isNot(contains('version')));
      },
    );

    test('route_stops-shaped tables mutate but do not version', () {
      final Set<String> columns = _columnNames(db.stopThings);

      expect(columns, containsAll(<String>['created_at', 'updated_at']));
      expect(columns, isNot(contains('version')));
      expect(columns, isNot(contains('deleted_at')));
      expect(columns, isNot(contains('owner_id')));
    });

    test('users-shaped tables have no owner, because they are the owner', () {
      final Set<String> columns = _columnNames(db.userThings);

      expect(
        columns,
        containsAll(<String>['created_at', 'updated_at', 'deleted_at']),
      );
      expect(columns, isNot(contains('owner_id')));
      expect(columns, isNot(contains('version')));
    });

    test('deleted_at is nullable and version is not', () {
      final Map<String, GeneratedColumn<Object?>> columns =
          <String, GeneratedColumn<Object?>>{
            for (final GeneratedColumn<Object?> c in db.ownedThings.$columns)
              c.name: c,
          };

      expect(columns['deleted_at']!.$nullable, isTrue);
      expect(columns['version']!.$nullable, isFalse);
      expect(columns['created_at']!.$nullable, isFalse);
      expect(columns['owner_id']!.$nullable, isFalse);
    });
  });

  group('storage shapes', () {
    Future<void> insertOne({
      FixtureStatus status = FixtureStatus.delivered,
      Centimes amount = const Centimes(-1250),
      String id = _id,
      EntityStamp? stamp,
    }) async {
      final EntityStamp s = stamp ?? stamper.forInsert();
      await db
          .into(db.ownedThings)
          .insert(
            OwnedThingsCompanion.insert(
              id: id,
              name: 'thing',
              amount: amount,
              confidence: GeoConfidence.gpsConfirmed,
              status: status,
              ownerId: _ownerId,
              createdAt: s.createdAt,
              updatedAt: s.updatedAt,
              deletedAt: Value<DateTime?>(s.deletedAt),
              version: s.version,
              phone: Value<PhoneE164?>(PhoneE164.parse('0550123456')),
            ),
          );
    }

    test('timestamps are milliseconds since epoch, not seconds', () {
      // Drift's own dateTime() stores Unix seconds, which cannot order three
      // parcels marked delivered in the same lift.
      return insertOne().then((_) async {
        final QueryRow raw = await db
            .customSelect('SELECT created_at FROM owned_things')
            .getSingle();

        expect(
          raw.read<int>('created_at'),
          DateTime.utc(2026, 8, 29, 7, 30, 15, 250).millisecondsSinceEpoch,
        );
        // Seconds would have dropped the 250.
        expect(raw.read<int>('created_at') % 1000, 250);
      });
    });

    test('timestamps come back as UTC', () async {
      await insertOne();
      final OwnedThing row = await db.select(db.ownedThings).getSingle();

      expect(row.createdAt.isUtc, isTrue);
      expect(row.createdAt, clock.nowUtc());
    });

    test('enums are stored as TEXT by name, never as an ordinal', () async {
      // An ordinal makes reordering the enum silently reassign every existing
      // row: inserting a status in the middle would turn every delivered
      // order into something else, with no error anywhere.
      await insertOne(status: FixtureStatus.returnedToAgency);

      final QueryRow raw = await db
          .customSelect('SELECT status FROM owned_things')
          .getSingle();

      expect(raw.read<String>('status'), 'returnedToAgency');
    });

    test('money is stored as a plain integer, sign intact', () async {
      await insertOne(amount: const Centimes(-1250));

      final QueryRow raw = await db
          .customSelect('SELECT amount FROM owned_things')
          .getSingle();
      expect(raw.read<int>('amount'), -1250);

      final OwnedThing row = await db.select(db.ownedThings).getSingle();
      expect(row.amount, const Centimes(-1250));
    });

    test('a phone round-trips through its canonical form', () async {
      await insertOne();

      final QueryRow raw = await db
          .customSelect('SELECT phone FROM owned_things')
          .getSingle();
      expect(raw.read<String>('phone'), '+213550123456');

      final OwnedThing row = await db.select(db.ownedThings).getSingle();
      expect(row.phone, PhoneE164.parse('0550 12 34 56'));
    });

    test('confidence is stored as its numeric tier', () async {
      await insertOne();

      final QueryRow raw = await db
          .customSelect('SELECT confidence FROM owned_things')
          .getSingle();
      expect(raw.read<int>('confidence'), 4);
    });
  });

  group('corrupt values fail loudly', () {
    test('an unknown enum name throws rather than defaulting', () async {
      // Defaulting to `pending` would resurrect a delivered order and lose the
      // money attached to it.
      await db.customStatement(
        'INSERT INTO owned_things '
        '(id, owner_id, created_at, updated_at, version, name, amount, '
        'confidence, status) '
        "VALUES ('$_id', '$_ownerId', 0, 0, 1, 'x', 0, 4, 'shipped_to_mars')",
      );

      expect(
        () => db.select(db.ownedThings).getSingle(),
        throwsA(isA<UnknownStoredValueError>()),
      );
    });

    test('the failure names the value and what was expected', () {
      const EnumTextConverter<FixtureStatus> converter =
          EnumTextConverter<FixtureStatus>(
            FixtureStatus.values,
            'FixtureStatus',
          );

      try {
        converter.fromSql('shipped_to_mars');
        fail('expected UnknownStoredValueError');
      } on UnknownStoredValueError catch (e) {
        expect(e.toString(), contains('shipped_to_mars'));
        expect(e.toString(), contains('FixtureStatus'));
        expect(e.toString(), contains('delivered'));
      }
    });

    test('an unknown confidence tier throws', () async {
      await db.customStatement(
        'INSERT INTO owned_things '
        '(id, owner_id, created_at, updated_at, version, name, amount, '
        'confidence, status) '
        "VALUES ('$_id', '$_ownerId', 0, 0, 1, 'x', 0, 9, 'pending')",
      );

      expect(() => db.select(db.ownedThings).getSingle(), throwsArgumentError);
    });
  });

  group('ordering convention: created_at, then id', () {
    test('the id breaks a millisecond tie deterministically', () async {
      // Milliseconds collide. UUIDv7 is time-sortable, so ordering by
      // (created_at, id) is the creation order rather than an arbitrary one.
      final EntityStamp stamp = stamper.forInsert();
      final List<String> ids = <String>[
        '0199a1b2-c3d4-7000-8000-00000000000c',
        '0199a1b2-c3d4-7000-8000-00000000000a',
        '0199a1b2-c3d4-7000-8000-00000000000b',
      ];

      for (final String id in ids) {
        await db
            .into(db.ownedThings)
            .insert(
              OwnedThingsCompanion.insert(
                id: id,
                name: 'thing',
                amount: Centimes.zero,
                confidence: GeoConfidence.none,
                status: FixtureStatus.pending,
                ownerId: _ownerId,
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
                version: stamp.version,
              ),
            );
      }

      final List<OwnedThing> ordered =
          await (db.select(db.ownedThings)
                ..orderBy(<OrderClauseGenerator<OwnedThings>>[
                  (OwnedThings t) => OrderingTerm(expression: t.createdAt),
                  (OwnedThings t) => OrderingTerm(expression: t.id),
                ]))
              .get();

      expect(ordered.map((OwnedThing t) => t.id), <String>[...ids]..sort());
    });
  });
}

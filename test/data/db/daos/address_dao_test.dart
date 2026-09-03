import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late AddressDao dao;
  late String ownerId;
  late String customerId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(db, clock, uuid).ensureUser();
    ownerId = user.id;

    await db.customStatement(
      "INSERT INTO wilayas (code, name_fr, name_ar) VALUES (16, 'Alger', 'x')",
    );
    await db.customStatement(
      'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
      "VALUES (1601, 16, 'Bab Ezzouar', 'x')",
    );

    customerId =
        (await CustomerDao(
              database: db,
              clock: clock,
              uuid: uuid,
              deviceId: 'device-under-test',
            ).create(
              ownerId: ownerId,
              phone: PhoneE164.parse('0550123456'),
              displayName: 'Amine',
            ))
            .id;

    dao = AddressDao(
      database: db,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => db.close());

  Future<CustomerAddress> add({String? label, bool? primary}) => dao.create(
    ownerId: ownerId,
    customerId: customerId,
    wilayaCode: 16,
    communeId: 1601,
    label: label,
    isPrimary: primary,
  );

  group('an address typed without coordinates', () {
    test('is stored, at confidence none', () async {
      // Refusing an address without a pin would refuse most of them. A driver
      // who knows the building does not need one, and the pin arrives on its
      // own the first time a delivery is confirmed there.
      final CustomerAddress a = await add();

      expect(a.geoConfidence, GeoConfidence.none);
      expect(a.latitude, isNull);
      expect(a.longitude, isNull);
    });

    test('and starts at version 1, not deleted', () async {
      final CustomerAddress a = await add();

      expect(a.version, 1);
      expect(a.createdAt, DateTime.utc(2026, 9, 3, 7));
      expect(a.deletedAt, isNull);
    });
  });

  group('exactly one primary', () {
    test('the first address is primary without being asked', () async {
      // Making the driver choose when there is nothing to choose between is a
      // tap that answers a question they were not asked.
      expect((await add()).isPrimary, isTrue);
    });

    test('a second is not, unless asked for', () async {
      await add(label: 'maison');
      expect((await add(label: 'travail')).isPrimary, isFalse);
    });

    test('promoting one demotes the other, in the same breath', () async {
      // Two primaries is a state no screen knows how to render, so it must not
      // exist even briefly.
      final CustomerAddress home = await add(label: 'maison');
      final CustomerAddress work = await add(label: 'travail');

      await dao.makePrimary(work);

      final List<CustomerAddress> all = await dao.forCustomer(customerId);
      expect(all.where((CustomerAddress a) => a.isPrimary), hasLength(1));
      expect(all.first.id, work.id);
      expect(
        (await dao.byId(home.id))!.isPrimary,
        isFalse,
        reason: 'the old primary kept its flag',
      );
    });

    test('creating one as primary demotes the incumbent too', () async {
      final CustomerAddress home = await add(label: 'maison');

      await add(label: 'travail', primary: true);

      expect((await dao.byId(home.id))!.isPrimary, isFalse);
    });
  });

  group('listing', () {
    test('puts the primary first, then oldest', () async {
      // The entry flow offers the top one by default, and the address a driver
      // has been to five times should be that default rather than whichever
      // was typed most recently.
      final CustomerAddress first = await add(label: 'a');
      clock.advance(const Duration(minutes: 1));
      final CustomerAddress second = await add(label: 'b');
      clock.advance(const Duration(minutes: 1));
      final CustomerAddress third = await add(label: 'c');

      await dao.makePrimary(third);

      expect(
        (await dao.forCustomer(customerId)).map((CustomerAddress a) => a.id),
        <String>[third.id, first.id, second.id],
      );
    });

    test('skips the deleted', () async {
      final CustomerAddress a = await add(label: 'a');
      await add(label: 'b');

      await dao.softDelete(a);

      expect(await dao.forCustomer(customerId), hasLength(1));
    });
  });

  group('deleting the primary', () {
    test('promotes the oldest survivor', () async {
      // A customer with addresses but no primary is a state the entry flow
      // would have to invent an answer for every time it ran.
      final CustomerAddress home = await add(label: 'maison');
      clock.advance(const Duration(minutes: 1));
      final CustomerAddress work = await add(label: 'travail');

      await dao.softDelete(home);

      final List<CustomerAddress> left = await dao.forCustomer(customerId);
      expect(left, hasLength(1));
      expect(left.single.id, work.id);
      expect(left.single.isPrimary, isTrue);
    });

    test('and the last one leaves none, rather than a ghost', () async {
      final CustomerAddress only = await add();

      await dao.softDelete(only);

      expect(await dao.forCustomer(customerId), isEmpty);
      expect((await dao.byId(only.id))!.isPrimary, isFalse);
    });

    test('deleting a non-primary does not disturb the primary', () async {
      final CustomerAddress home = await add(label: 'maison');
      final CustomerAddress work = await add(label: 'travail');

      await dao.softDelete(work);

      expect((await dao.byId(home.id))!.isPrimary, isTrue);
    });

    test(
      'the row survives, so an order pointing at it still resolves',
      () async {
        final CustomerAddress a = await add();

        await dao.softDelete(a);

        expect(await dao.byId(a.id), isNotNull);
        expect((await dao.byId(a.id))!.deletedAt, isNotNull);
      },
    );
  });

  group('editing', () {
    test('moves only the named fields and bumps the version', () async {
      final CustomerAddress a = await add(label: 'maison');
      clock.advance(const Duration(hours: 1));

      final CustomerAddress edited = await dao.edit(
        current: a,
        detail: 'Bt 12, 3e étage',
      );

      expect(edited.detail, 'Bt 12, 3e étage');
      expect(edited.label, 'maison', reason: 'an unnamed field moved');
      expect(edited.version, 2);
      expect(edited.createdAt, a.createdAt);
      expect(edited.updatedAt, DateTime.utc(2026, 9, 3, 8));
    });
  });

  test('an address must point at a commune that exists', () async {
    // Foreign keys are on. A commune id from a stale dataset would otherwise
    // produce an address nobody can render.
    await expectLater(
      dao.create(
        ownerId: ownerId,
        customerId: customerId,
        wilayaCode: 16,
        communeId: 999999,
      ),
      throwsA(anything),
    );
  });
}

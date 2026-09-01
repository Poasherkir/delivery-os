import 'dart:convert';

import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late CustomerDao dao;
  late String ownerId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 1, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    ownerId = (await AppBootstrap(db, clock, uuid).ensureUser()).id;
    dao = CustomerDao(
      database: db,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => db.close());

  Future<Customer> create({
    String phone = '0550123456',
    String name = 'Amine',
  }) => dao.create(
    ownerId: ownerId,
    phone: PhoneE164.parse(phone),
    displayName: name,
  );

  group('identity by phone', () {
    test('every spelling of one number finds the same row', () async {
      // The identity key is normalized on the way in, so the lookup does not
      // have to know which shape the driver typed.
      final Customer c = await create(phone: '0550123456');

      for (final String spelling in <String>[
        '0550123456',
        '+213550123456',
        '00213550123456',
        '0550 12 34 56',
      ]) {
        expect(
          (await dao.findByPhone(
            ownerId: ownerId,
            phone: PhoneE164.parse(spelling),
          ))?.id,
          c.id,
          reason: '"$spelling" did not resolve to the same customer',
        );
      }
    });

    test('a soft-deleted customer is invisible', () async {
      final Customer c = await create();
      await dao.softDelete(c);

      expect(
        await dao.findByPhone(
          ownerId: ownerId,
          phone: PhoneE164.parse('0550123456'),
        ),
        isNull,
      );
    });

    test('and does not block re-adding the number', () async {
      // The whole point of the partial unique index. Being refused by a row
      // they cannot see would be inexplicable to a driver.
      final Customer first = await create();
      await dao.softDelete(first);

      final Customer second = await create(name: 'Amine again');

      expect(second.id, isNot(first.id));
      expect(
        (await dao.findByPhone(
          ownerId: ownerId,
          phone: PhoneE164.parse('0550123456'),
        ))?.id,
        second.id,
      );
    });

    test('a live duplicate is refused', () async {
      // Not silently merged: reconciling two records has consequences for
      // orders and learned pins, and that decision is not this method's.
      await create();

      await expectLater(create(name: 'Someone else'), throwsA(anything));
    });
  });

  group('stamping', () {
    test('a new customer starts at version 1, not deleted', () async {
      final Customer c = await create();

      expect(c.version, 1);
      expect(c.createdAt, DateTime.utc(2026, 9, 1, 7));
      expect(c.updatedAt, c.createdAt);
      expect(c.deletedAt, isNull);
    });

    test('an edit bumps the version and moves only updated_at', () async {
      final Customer c = await create();
      clock.advance(const Duration(hours: 2));

      final Customer edited = await dao.edit(
        current: c,
        riskFlag: CustomerRiskFlag.watch,
      );

      expect(edited.version, 2);
      expect(edited.createdAt, c.createdAt);
      expect(edited.updatedAt, DateTime.utc(2026, 9, 1, 9));
    });

    test('an edit moves only the fields it was given', () async {
      final Customer c = await dao.create(
        ownerId: ownerId,
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine',
        notes: 'careful',
      );

      final Customer edited = await dao.edit(
        current: c,
        riskFlag: CustomerRiskFlag.problem,
      );

      expect(edited.riskFlag, CustomerRiskFlag.problem);
      expect(edited.displayName, 'Amine', reason: 'an unnamed field moved');
      expect(edited.notes, 'careful', reason: 'an unnamed field moved');
    });

    test('a soft delete is a write, so it bumps the version too', () async {
      final Customer c = await create();
      clock.advance(const Duration(minutes: 30));

      await dao.softDelete(c);
      final Customer row = await db.select(db.customers).getSingle();

      expect(row.version, 2);
      expect(row.deletedAt, DateTime.utc(2026, 9, 1, 7, 30));
      expect(row.createdAt, c.createdAt);
    });
  });

  group('the queued command', () {
    Future<List<OutboxData>> queue() => (db.select(
      db.outbox,
    )..where(($OutboxTable o) => o.entityType.equals('customer'))).get();

    test('a create carries the fields it wrote', () async {
      await dao.create(
        ownerId: ownerId,
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine',
        notes: 'careful',
      );

      final Map<String, Object?> payload =
          jsonDecode((await queue()).single.payload) as Map<String, Object?>;

      expect(payload['phone_e164'], '+213550123456');
      expect(payload['display_name'], 'Amine');
      expect(payload['notes'], 'careful');
      expect(payload['risk_flag'], 'none');
    });

    test('an edit carries only what changed', () async {
      // §11.2: a command, not a state diff. Replaying `{risk_flag: watch}` is
      // correct whatever else moved in the meantime; replaying the whole row
      // would silently overwrite another device's edit.
      final Customer c = await create();
      await dao.edit(current: c, riskFlag: CustomerRiskFlag.watch);

      final Map<String, Object?> payload =
          jsonDecode((await queue()).last.payload) as Map<String, Object?>;

      expect(payload, <String, Object?>{'risk_flag': 'watch'});
    });

    test('every command names the operation that happened', () async {
      final Customer c = await create();
      await dao.edit(current: c, riskFlag: CustomerRiskFlag.watch);
      await dao.softDelete(c);

      expect(
        (await queue()).map((OutboxData o) => o.operation.name).toList(),
        <String>['create', 'update', 'delete'],
      );
    });

    test('nothing is queued when the write fails', () async {
      // The transaction is what guarantees it. A queued command describing a
      // row that was never written would be replayed against nothing at V2.
      await create();
      final int before = (await queue()).length;

      await create(name: 'duplicate').then<void>(
        (_) => fail('expected the unique index to refuse'),
        onError: (Object _) {},
      );

      expect((await queue()).length, before);
    });
  });

  group('listing', () {
    test('is oldest first and skips the deleted', () async {
      final Customer a = await create(phone: '0550000001');
      clock.advance(const Duration(seconds: 1));
      final Customer b = await create(phone: '0550000002');
      clock.advance(const Duration(seconds: 1));
      final Customer c = await create(phone: '0550000003');

      await dao.softDelete(b);

      expect(
        (await dao.all(ownerId: ownerId)).map((Customer x) => x.id).toList(),
        <String>[a.id, c.id],
      );
    });
  });
}

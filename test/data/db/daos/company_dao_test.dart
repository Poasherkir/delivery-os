import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late CompanyDao dao;
  late UuidV7Generator uuid;
  late String ownerId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(db, clock, uuid).ensureUser();
    ownerId = user.id;

    dao = CompanyDao(
      database: db,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => db.close());

  Future<Company> add(String name, {String? phone, String? notes}) => dao
      .create(ownerId: ownerId, name: name, contactPhone: phone, notes: notes);

  group('creating', () {
    test('a name is the only thing a driver has to type', () async {
      final Company c = await add('Yalidine');

      expect(c.name, 'Yalidine');
      expect(c.contactPhone, isNull);
      expect(c.notes, isNull);
    });

    test('and it starts at version 1, live and active', () async {
      final Company c = await add('Yalidine');

      expect(c.version, 1);
      expect(c.createdAt, DateTime.utc(2026, 9, 3, 7));
      expect(c.deletedAt, isNull);
      expect(c.isActive, isTrue);
    });

    test('phone is free text, not a parsed number', () async {
      // Agencies hand out a mobile and a landline together. This is
      // dial-and-display data; nothing joins on it and nothing normalizes it.
      final Company c = await add(
        'ZR Express',
        phone: '0770 11 22 33 / 021 44 55 66',
      );

      expect(c.contactPhone, '0770 11 22 33 / 021 44 55 66');
    });

    test('two companies may share a name', () async {
      // Two agencies really can. A uniqueness rule invented here would block a
      // real case to prevent a typo the driver can see and fix.
      final Company first = await add('Express');
      final Company second = await add('Express');

      expect(second.id, isNot(first.id));
      expect(await dao.selectable(ownerId: ownerId), hasLength(2));
    });
  });

  group('the picker list', () {
    test('is ordered by name, not by when they were added', () async {
      // A driver has three companies, not thirty. A list that reorders itself
      // under the thumb is worse than one that does not.
      await add('Yalidine');
      await add('Anderson');
      await add('ZR Express');

      expect(
        (await dao.selectable(ownerId: ownerId)).map((Company c) => c.name),
        <String>['Anderson', 'Yalidine', 'ZR Express'],
      );
    });

    test('skips the deleted', () async {
      final Company gone = await add('Anderson');
      await add('Yalidine');

      await dao.softDelete(gone);

      expect(
        (await dao.selectable(ownerId: ownerId)).map((Company c) => c.name),
        <String>['Yalidine'],
      );
    });

    test('skips the inactive too', () async {
      // Nothing sets `is_active` false yet, so this drives it directly. The
      // filter is in the query now because the day something does set it, the
      // query without it would be silently wrong — and a filter no test
      // exercises is a filter that could already be missing.
      final Company retired = await add('Anderson');
      await add('Yalidine');

      await db.customStatement(
        'UPDATE companies SET is_active = 0 WHERE id = ?',
        <Object?>[retired.id],
      );

      expect(
        (await dao.selectable(ownerId: ownerId)).map((Company c) => c.name),
        <String>['Yalidine'],
      );
    });

    test('and belongs to one owner', () async {
      // owner_id is dormant in MVP but the query filters on it, so a second
      // owner's rows must not appear. Both rows are written directly because
      // there is no second driver and there will not be one before sync — and
      // an unfiltered query would pass every other test in this file.
      final Company mine = await add('Yalidine');
      final String otherUser = uuid.next();
      final String otherCompany = uuid.next();
      await db.customStatement(
        'INSERT INTO users (id, created_at, updated_at) VALUES (?, 0, 0)',
        <Object?>[otherUser],
      );
      await db.customStatement(
        'INSERT INTO companies (id, owner_id, name, created_at, updated_at, '
        'version, is_active) VALUES (?, ?, ?, 0, 0, 1, 1)',
        <Object?>[otherCompany, otherUser, 'Anderson'],
      );

      expect(
        (await dao.selectable(ownerId: ownerId)).map((Company c) => c.id),
        <String>[mine.id],
      );
    });
  });

  group('byId resolves what the picker will not offer', () {
    test('a deleted company still reads', () async {
      // A batch from last month points at it and that batch has to render.
      final Company c = await add('Anderson');

      await dao.softDelete(c);

      expect((await dao.byId(c.id))!.name, 'Anderson');
    });

    test('an inactive one does too', () async {
      final Company c = await add('Anderson');
      await db.customStatement(
        'UPDATE companies SET is_active = 0 WHERE id = ?',
        <Object?>[c.id],
      );

      expect(await dao.byId(c.id), isNotNull);
    });

    test('and an id nobody wrote is null, not an error', () async {
      expect(await dao.byId('no-such-company'), isNull);
    });
  });

  group('editing', () {
    test('moves only the named fields and bumps the version', () async {
      final Company c = await add('Yalidin', phone: '0770 11 22 33');
      clock.advance(const Duration(hours: 1));

      final Company edited = await dao.edit(current: c, name: 'Yalidine');

      expect(edited.name, 'Yalidine');
      expect(
        edited.contactPhone,
        '0770 11 22 33',
        reason: 'an unnamed field moved',
      );
      expect(edited.version, 2);
      expect(edited.createdAt, c.createdAt);
      expect(edited.updatedAt, DateTime.utc(2026, 9, 3, 8));
    });

    test('editing nothing is still a write', () async {
      // The version bump is what a later sync reconciles on. A no-op edit that
      // did not bump would be a write the queue records and the row denies.
      final Company c = await add('Yalidine');

      expect((await dao.edit(current: c)).version, 2);
    });
  });

  group('deleting', () {
    test(
      'the row survives, so a batch pointing at it still resolves',
      () async {
        final Company c = await add('Yalidine');

        await dao.softDelete(c);

        expect((await dao.byId(c.id))!.deletedAt, isNotNull);
        expect((await dao.byId(c.id))!.version, 2);
      },
    );

    test('twice keeps the first death, not the second', () async {
      final Company c = await add('Yalidine');
      await dao.softDelete(c);
      final DateTime died = (await dao.byId(c.id))!.deletedAt!;

      clock.advance(const Duration(hours: 3));
      await dao.softDelete((await dao.byId(c.id))!);

      expect(
        (await dao.byId(c.id))!.deletedAt,
        died,
        reason: 'the row died once; moving the timestamp would falsify when',
      );
    });
  });
}

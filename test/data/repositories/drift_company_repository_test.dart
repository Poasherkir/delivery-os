import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/repositories/drift_company_repository.dart';
import 'package:delivery_os/domain/entities/company.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late CompanyDao dao;
  late CompanyRepository repo;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();

    dao = CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    repo = DriftCompanyRepository(dao: dao, ownerId: user.id);
  });

  tearDown(() => database.close());

  test('a created company comes back as a domain company', () async {
    // The point of the boundary: `features/` gets this, not a Drift row.
    final Company c = await repo.create(
      name: 'Yalidine',
      contactPhone: '0770 11 22 33',
      notes: 'Bab Ezzouar hub',
    );

    expect(c, isA<Company>());
    expect(c.name, 'Yalidine');
    expect(c.contactPhone, '0770 11 22 33');
    expect(c.notes, 'Bab Ezzouar hub');
    expect(c.version, 1);
  });

  group('the name is trimmed', () {
    test('on create', () async {
      // A trailing space from a soft keyboard is invisible in a list and puts
      // the company in the wrong place under an ORDER BY.
      expect((await repo.create(name: '  Yalidine  ')).name, 'Yalidine');
    });

    test('and on edit', () async {
      final Company c = await repo.create(name: 'Yalidin');

      expect(
        (await repo.edit(current: c, name: ' Yalidine ')).name,
        'Yalidine',
      );
    });

    test('but a name left alone is left alone', () async {
      final Company c = await repo.create(name: 'Yalidine', notes: 'a');

      final Company edited = await repo.edit(current: c, notes: 'b');

      expect(edited.name, 'Yalidine');
      expect(edited.notes, 'b');
    });
  });

  test('selectable offers the live and active, by name', () async {
    await repo.create(name: 'Yalidine');
    final Company gone = await repo.create(name: 'Anderson');
    await repo.create(name: 'ZR Express');

    await repo.softDelete(gone);

    expect((await repo.selectable()).map((Company c) => c.name), <String>[
      'Yalidine',
      'ZR Express',
    ]);
  });

  test('byId resolves what selectable will not offer', () async {
    final Company c = await repo.create(name: 'Anderson');

    await repo.softDelete(c);

    expect((await repo.byId(c.id))!.name, 'Anderson');
    expect(await repo.selectable(), isEmpty);
  });

  test('and an unknown id is null, not an error', () async {
    expect(await repo.byId('no-such-company'), isNull);
  });

  group('editing re-reads the row rather than trusting the caller', () {
    test('so a stale version does not overwrite what moved', () async {
      // The company a form is holding was fetched two minutes ago. If the DAO
      // stamped from that object's version, this edit would write version 2
      // over a row that is already at 2 — losing the change in between and
      // leaving the version saying it never happened.
      final Company stale = await repo.create(name: 'Yalidine');
      await repo.edit(current: stale, notes: 'first');

      final Company second = await repo.edit(current: stale, notes: 'second');

      expect(second.version, 3);
      expect(second.notes, 'second');
    });

    test('and a company deleted out from under the form fails loudly', () async {
      // Not silently recreated. A row that is gone is a state the screen has to
      // handle, and inventing one here would hide it.
      final Company c = await repo.create(name: 'Yalidine');
      await database.customStatement(
        'DELETE FROM companies WHERE id = ?',
        <Object?>[c.id],
      );

      await expectLater(
        repo.edit(current: c, name: 'Yalidine 2'),
        throwsA(isA<StateError>()),
      );
    });
  });
}

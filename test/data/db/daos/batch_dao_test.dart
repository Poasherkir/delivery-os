import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
// Only the exception: the domain entity of the same name is not what this DAO
// returns, and the row class should keep reading as `Batch` here.
import 'package:delivery_os/domain/repositories/batch_repository.dart'
    show BatchNotOpenException;
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase database;
  late FixedClock clock;
  late BatchDao dao;
  late String ownerId;
  late String companyId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(database, clock, uuid).ensureUser();
    ownerId = user.id;

    companyId = (await CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    ).create(ownerId: ownerId, name: 'Yalidine')).id;

    dao = BatchDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => database.close());

  Future<Batch> ensure({String? company, String date = '2026-09-03'}) =>
      dao.ensureOpenBatch(
        ownerId: ownerId,
        companyId: company ?? companyId,
        serviceDate: date,
      );

  Future<int> batchCount() async =>
      (await database
              .customSelect('SELECT count(*) c FROM batches')
              .getSingle())
          .read<int>('c');

  Future<int> outboxCount() async =>
      (await database.customSelect('SELECT count(*) c FROM outbox').getSingle())
          .read<int>('c');

  group('the first call opens the day', () {
    test('and the batch is open, at version 1', () async {
      final Batch b = await ensure();

      expect(b.status, BatchStatus.open);
      expect(b.version, 1);
      expect(b.serviceDate, '2026-09-03');
      expect(b.companyId, companyId);
      expect(b.closedAt, isNull);
      expect(b.deletedAt, isNull);
    });

    test('and it queues one command', () async {
      final int before = await outboxCount();

      await ensure();

      expect(await outboxCount(), before + 1);
    });
  });

  group('every call after that finds it', () {
    test('the same batch comes back, not a second one', () async {
      // `(owner_id, company_id, service_date)` is unique, so a second insert is
      // not a duplicate row — it is a constraint violation in the middle of the
      // driver's fastest path.
      final Batch first = await ensure();
      clock.advance(const Duration(hours: 2));

      final Batch second = await ensure();

      expect(second.id, first.id);
      expect(second.version, 1, reason: 'finding a batch is not a write');
      expect(await batchCount(), 1);
    });

    test('and queues nothing', () async {
      // The half that matters. A queued `create` on every order entered would
      // replay at V2 as a hundred attempts to make the same batch.
      await ensure();
      final int after = await outboxCount();

      await ensure();
      await ensure();

      expect(await outboxCount(), after);
    });
  });

  group('what counts as a different day of work', () {
    test('another date is another batch', () async {
      final int before = await outboxCount();

      final Batch today = await ensure();
      final Batch tomorrow = await ensure(date: '2026-09-04');

      expect(tomorrow.id, isNot(today.id));
      expect(tomorrow.serviceDate, '2026-09-04');
      expect(
        await outboxCount(),
        before + 2,
        reason: 'two batches were opened, so two commands were queued',
      );
    });

    test('another company on the same date is another batch', () async {
      // One driver, one company, one service date. A driver working two
      // companies in one day has two batches and one route.
      final UuidV7Generator uuid = UuidV7Generator(clock: clock);
      final String other = (await CompanyDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ).create(ownerId: ownerId, name: 'ZR Express')).id;

      final Batch first = await ensure();
      final Batch second = await ensure(company: other);

      expect(second.id, isNot(first.id));
      expect(second.serviceDate, first.serviceDate);
    });
  });

  group('a batch that cannot take orders', () {
    /// Driven by raw SQL because nothing in M1 closes or settles a batch. That
    /// is the point: this is the state M2 will create, and the guard has to
    /// exist before the thing it guards against does.
    Future<void> setStatus(String id, String status) =>
        database.customStatement(
          'UPDATE batches SET status = ? WHERE id = ?',
          <Object?>[status, id],
        );

    test('a closed one throws rather than reopening itself', () async {
      final Batch b = await ensure();
      await setStatus(b.id, 'closed');

      await expectLater(ensure(), throwsA(isA<BatchNotOpenException>()));
    });

    test('a settled one throws — that is invariant 7', () async {
      // Silently appending an order to a settled batch would change what the
      // driver is owed for a day whose money is already confirmed.
      final Batch b = await ensure();
      await setStatus(b.id, 'settled');

      await expectLater(ensure(), throwsA(isA<BatchNotOpenException>()));
    });

    test('a soft-deleted one throws too', () async {
      // The unique key covers deleted rows, so a second batch cannot be opened
      // beside it. Failing is the only honest answer left.
      final Batch b = await ensure();
      await database.customStatement(
        'UPDATE batches SET deleted_at = 0 WHERE id = ?',
        <Object?>[b.id],
      );

      await expectLater(ensure(), throwsA(isA<BatchNotOpenException>()));
    });

    test('and the failure says which batch and why', () async {
      final Batch b = await ensure();
      await setStatus(b.id, 'settled');

      await expectLater(
        ensure(),
        throwsA(
          isA<BatchNotOpenException>()
              .having((BatchNotOpenException e) => e.batchId, 'batchId', b.id)
              .having(
                (BatchNotOpenException e) => e.status,
                'status',
                BatchStatus.settled,
              )
              .having(
                (BatchNotOpenException e) => e.isDeleted,
                'isDeleted',
                isFalse,
              ),
        ),
      );
    });

    test('and nothing was written on the way out', () async {
      final Batch b = await ensure();
      await setStatus(b.id, 'closed');
      final int after = await outboxCount();

      await expectLater(ensure(), throwsA(isA<BatchNotOpenException>()));

      expect(await outboxCount(), after);
      expect(await batchCount(), 1);
    });
  });

  test('a batch must point at a company that exists', () async {
    // Foreign keys are on.
    await expectLater(
      ensure(company: '00000000-0000-7000-8000-000000000000'),
      throwsA(anything),
    );
  });
}

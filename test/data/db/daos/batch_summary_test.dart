import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// `BatchDao.summariesForDate`: the batch list's one query.
///
/// The counts are what the screen decides on, so the two ways they can be
/// quietly wrong are what this tests — a conditional sum that counts the wrong
/// statuses, and a join that multiplies or drops rows.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late BatchDao batches;
  late OrderDao orders;
  late CompanyDao companies;
  late String ownerId;
  late String companyId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(database, clock, uuid).ensureUser();
    ownerId = user.id;

    companies = CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    batches = BatchDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    orders = OrderDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    companyId = (await companies.create(ownerId: ownerId, name: 'Yalidine')).id;
  });

  tearDown(() => database.close());

  Future<Batch> openBatch({String? company, String date = '2026-09-03'}) =>
      batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: company ?? companyId,
        serviceDate: date,
      );

  Future<Order> addOrder(
    Batch batch, {
    required String tracking,
    String? company,
    Centimes cod = Centimes.zero,
  }) => orders.create(
    ownerId: ownerId,
    batchId: batch.id,
    companyId: company ?? companyId,
    trackingNumber: tracking,
    codAmount: cod,
  );

  Future<void> setStatus(Order order, OrderStatus status) =>
      database.customStatement(
        'UPDATE orders SET status = ? WHERE id = ?',
        <Object?>[status.name, order.id],
      );

  Future<List<BatchSummaryRow>> summaries({String date = '2026-09-03'}) =>
      batches.summariesForDate(ownerId: ownerId, serviceDate: date);

  group('a batch with nothing in it', () {
    test('still appears, with zeroes rather than absent', () async {
      // The left join's whole job. A batch opened and not yet filled is a real
      // state — it is what the first scan of the morning creates.
      final Batch batch = await openBatch();

      final BatchSummaryRow row = (await summaries()).single;

      expect(row.id, batch.id);
      expect(row.companyName, 'Yalidine');
      expect(row.totalOrders, 0);
      expect(row.openOrders, 0);
      expect(row.expectedCollection, Centimes.zero);
      expect(row.status, BatchStatus.open);
    });
  });

  group('the counts', () {
    test('separate what is finished from what is not', () async {
      final Batch batch = await openBatch();
      final Order a = await addOrder(batch, tracking: 'YAL-0001');
      final Order b = await addOrder(batch, tracking: 'YAL-0002');
      await addOrder(batch, tracking: 'YAL-0003');
      await setStatus(a, OrderStatus.delivered);
      await setStatus(b, OrderStatus.returnedToAgency);

      final BatchSummaryRow row = (await summaries()).single;

      expect(row.totalOrders, 3);
      expect(row.openOrders, 1, reason: 'only YAL-0003 is still pending');
    });

    test(
      'and count failed as open, which is the whole reason they exist',
      () async {
        // A failed parcel looks finished and is not: the disposition is
        // undecided, so the money is undecided.
        final Batch batch = await openBatch();
        final Order order = await addOrder(batch, tracking: 'YAL-0001');
        await setStatus(order, OrderStatus.failed);

        expect((await summaries()).single.openOrders, 1);
      },
    );

    test('agree with OrderStatus.isOpen for every status', () async {
      // Walked rather than sampled, so a ninth status added without a decision
      // about which side it falls on fails here — the same shape as the close
      // precondition's own test, and deliberately the same rule.
      for (final OrderStatus status in OrderStatus.values) {
        final String date =
            '2026-11-${(status.index + 1).toString().padLeft(2, '0')}';
        final Batch batch = await openBatch(date: date);
        final Order order = await addOrder(
          batch,
          tracking: 'YAL-${status.name}',
        );
        await setStatus(order, status);

        expect(
          (await summaries(date: date)).single.openOrders,
          status.isOpen ? 1 : 0,
          reason: '${status.name} was counted on the wrong side',
        );
      }
    });

    test('and a soft-deleted parcel is in neither', () async {
      final Batch batch = await openBatch();
      final Order gone = await addOrder(batch, tracking: 'YAL-0001');
      await addOrder(batch, tracking: 'YAL-0002');
      await orders.softDelete(gone);

      final BatchSummaryRow row = (await summaries()).single;

      expect(row.totalOrders, 1);
      expect(row.openOrders, 1);
    });
  });

  group('the expected collection', () {
    test('sums what is owed at the doors, in centimes', () async {
      // 4500 + 2500 = 7000 DA, which is 700000 centimes: 7000 × 100 by the
      // definition of the unit. Summed in SQL, so this also checks the
      // converter round-trips through an aggregate.
      final Batch batch = await openBatch();
      await addOrder(
        batch,
        tracking: 'YAL-0001',
        cod: Centimes.fromDinars(4500),
      );
      await addOrder(
        batch,
        tracking: 'YAL-0002',
        cod: Centimes.fromDinars(2500),
      );

      expect(
        (await summaries()).single.expectedCollection,
        const Centimes(700000),
      );
    });

    test('and a batch with no money owed reads zero, not null', () async {
      await openBatch();

      expect((await summaries()).single.expectedCollection, Centimes.zero);
    });

    test('and a deleted parcel takes its money out of the total', () async {
      final Batch batch = await openBatch();
      final Order gone = await addOrder(
        batch,
        tracking: 'YAL-0001',
        cod: Centimes.fromDinars(4500),
      );
      await addOrder(
        batch,
        tracking: 'YAL-0002',
        cod: Centimes.fromDinars(2500),
      );
      await orders.softDelete(gone);

      expect(
        (await summaries()).single.expectedCollection,
        const Centimes(250000),
      );
    });
  });

  group('several companies in one day', () {
    test('are separate batches, each with its own counts', () async {
      // The join must not smear one company's parcels across another's row.
      final String other = (await companies.create(
        ownerId: ownerId,
        name: 'Anderson',
      )).id;
      final Batch mine = await openBatch();
      final Batch theirs = await openBatch(company: other);
      await addOrder(mine, tracking: 'YAL-0001');
      await addOrder(mine, tracking: 'YAL-0002');
      await addOrder(theirs, tracking: 'AND-0001', company: other);

      final List<BatchSummaryRow> rows = await summaries();

      expect(rows, hasLength(2));
      // Ordered by company name: Anderson before Yalidine.
      expect(rows.first.companyName, 'Anderson');
      expect(rows.first.totalOrders, 1);
      expect(rows.last.companyName, 'Yalidine');
      expect(rows.last.totalOrders, 2);
      expect(rows.first.id, theirs.id);
      expect(rows.last.id, mine.id);
    });
  });

  group('scope', () {
    test('is one day', () async {
      await openBatch();
      await openBatch(date: '2026-09-04');

      expect(await summaries(date: '2026-09-03'), hasLength(1));
      expect(await summaries(date: '2026-09-05'), isEmpty);
    });

    test('and a closed batch still appears, marked closed', () async {
      // A finished day has to render as finished rather than vanish.
      final Batch batch = await openBatch();
      await batches.close(batch);

      final BatchSummaryRow row = (await summaries()).single;

      expect(row.status, BatchStatus.closed);
      expect(row.version, batch.version + 1);
    });
  });
}

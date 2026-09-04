import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart'
    show
        BatchHasOpenOrdersException,
        BatchNotClosedException,
        BatchNotOpenException;
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Closing and reopening a batch.
///
/// The precondition is the substance: a batch cannot close while any parcel
/// still holds it open, because `failed` means the disposition is undecided,
/// so the money is undecided, so the day cannot be totalled. Enforcing it here
/// means a batch never reaches M3's settlement in a state M3 has to reject.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late BatchDao batches;
  late OrderDao orders;
  late String ownerId;
  late String companyId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(database, clock, uuid).ensureUser();
    ownerId = user.id;

    companyId = (await CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    ).create(ownerId: ownerId, name: 'Yalidine')).id;

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
  });

  tearDown(() => database.close());

  Future<Batch> openBatch({String date = '2026-09-03'}) =>
      batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: companyId,
        serviceDate: date,
      );

  Future<Order> addOrder(Batch batch, {String tracking = 'YAL-0001'}) =>
      orders.create(
        ownerId: ownerId,
        batchId: batch.id,
        companyId: companyId,
        trackingNumber: tracking,
      );

  /// Drives a status the M2 delivery flow will produce but which nothing
  /// writes yet. Raw SQL for the same reason the closed-batch guard used it:
  /// the check has to exist before the thing it guards against does.
  Future<void> setStatus(Order order, OrderStatus status) =>
      database.customStatement(
        'UPDATE orders SET status = ? WHERE id = ?',
        <Object?>[status.name, order.id],
      );

  Future<int> outboxCount() async =>
      (await database.customSelect('SELECT count(*) c FROM outbox').getSingle())
          .read<int>('c');

  group('an empty batch', () {
    test('closes, and records when', () async {
      final Batch batch = await openBatch();
      clock.advance(const Duration(hours: 9));

      final Batch closed = await batches.close(batch);

      expect(closed.status, BatchStatus.closed);
      expect(closed.closedAt, DateTime.utc(2026, 9, 3, 16));
      expect(closed.version, batch.version + 1);
    });

    test('and queues exactly one command', () async {
      final Batch batch = await openBatch();
      final int before = await outboxCount();

      await batches.close(batch);

      expect(await outboxCount(), before + 1);
    });
  });

  group('the close precondition', () {
    test('a pending parcel holds the batch open', () async {
      final Batch batch = await openBatch();
      await addOrder(batch);

      await expectLater(
        batches.close(batch),
        throwsA(isA<BatchHasOpenOrdersException>()),
      );
    });

    test('and so does a failed one — that is the whole point', () async {
      // `failed` is not terminal: the disposition is undecided, so the money
      // is undecided. A batch that closed over one would reach settlement with
      // a number nobody can compute.
      final Batch batch = await openBatch();
      final Order order = await addOrder(batch);
      await setStatus(order, OrderStatus.failed);

      await expectLater(
        batches.close(batch),
        throwsA(isA<BatchHasOpenOrdersException>()),
      );
    });

    test('every open status holds it, and no closed one does', () async {
      // Walked over the enum rather than sampled, so a ninth status added
      // without a decision about which side it falls on fails here.
      for (final OrderStatus status in OrderStatus.values) {
        final Batch batch = await batches.ensureOpenBatch(
          ownerId: ownerId,
          companyId: companyId,
          serviceDate: '2026-10-${status.index + 1}'.padLeft(10, '0'),
        );
        final Order order = await addOrder(
          batch,
          tracking: 'YAL-${status.name}',
        );
        await setStatus(order, status);

        if (status.isOpen) {
          await expectLater(
            batches.close(batch),
            throwsA(isA<BatchHasOpenOrdersException>()),
            reason: '${status.name} is open but did not hold the batch',
          );
        } else {
          expect(
            (await batches.close(batch)).status,
            BatchStatus.closed,
            reason: '${status.name} closes the batch but blocked it',
          );
        }
      }
    });

    test('the refusal says how many are left', () async {
      // So a screen can name what is outstanding rather than only that it
      // refused.
      final Batch batch = await openBatch();
      await addOrder(batch, tracking: 'YAL-0001');
      await addOrder(batch, tracking: 'YAL-0002');
      final Order done = await addOrder(batch, tracking: 'YAL-0003');
      await setStatus(done, OrderStatus.delivered);

      await expectLater(
        batches.close(batch),
        throwsA(
          isA<BatchHasOpenOrdersException>().having(
            (BatchHasOpenOrdersException e) => e.openOrders,
            'openOrders',
            2,
          ),
        ),
      );
    });

    test('a soft-deleted parcel does not hold it open', () async {
      // A mistyped parcel the driver removed is not unfinished work.
      final Batch batch = await openBatch();
      final Order gone = await addOrder(batch);
      await orders.softDelete(gone);

      expect((await batches.close(batch)).status, BatchStatus.closed);
    });

    test('and nothing was written when it refused', () async {
      final Batch batch = await openBatch();
      await addOrder(batch);
      final int before = await outboxCount();

      await expectLater(
        batches.close(batch),
        throwsA(isA<BatchHasOpenOrdersException>()),
      );

      expect(await outboxCount(), before);
      expect((await batches.byId(batch.id))!.status, BatchStatus.open);
    });
  });

  group('closing something that is not open', () {
    test('a closed batch cannot be closed twice', () async {
      final Batch batch = await openBatch();
      await batches.close(batch);

      await expectLater(
        batches.close(batch),
        throwsA(isA<BatchNotOpenException>()),
      );
    });

    test('and a settled one is refused — invariant 7', () async {
      final Batch batch = await openBatch();
      await database.customStatement(
        'UPDATE batches SET status = ? WHERE id = ?',
        <Object?>['settled', batch.id],
      );

      await expectLater(
        batches.close(batch),
        throwsA(isA<BatchNotOpenException>()),
      );
    });
  });

  group('reopening', () {
    test('a closed batch takes parcels again', () async {
      // The forgotten-parcel case: closing is a pause, not a fact.
      final Batch batch = await openBatch();
      final Batch closed = await batches.close(batch);

      final Batch reopened = await batches.reopen(closed);

      expect(reopened.status, BatchStatus.open);
      expect(
        reopened.closedAt,
        isNull,
        reason: 'closed_at records when the day finished, and it has not',
      );
      expect(reopened.version, closed.version + 1);
    });

    test('and ensureOpenBatch finds it again afterwards', () async {
      // The real proof it is usable: entry has to be able to reach it.
      final Batch batch = await openBatch();
      await batches.reopen(await batches.close(batch));

      expect((await openBatch()).id, batch.id);
    });

    test('an open batch is not reopened', () async {
      final Batch batch = await openBatch();

      await expectLater(
        batches.reopen(batch),
        throwsA(isA<BatchNotClosedException>()),
      );
    });

    test('and a settled one never is — invariant 7', () async {
      // Once the money is confirmed, corrections are adjustments rather than
      // edits. Reopening would let an edit contradict a settlement computed
      // from it.
      final Batch batch = await openBatch();
      await database.customStatement(
        'UPDATE batches SET status = ? WHERE id = ?',
        <Object?>['settled', batch.id],
      );

      await expectLater(
        batches.reopen(batch),
        throwsA(
          isA<BatchNotClosedException>().having(
            (BatchNotClosedException e) => e.status,
            'status',
            BatchStatus.settled,
          ),
        ),
      );
    });
  });

  group('the batch list', () {
    test('shows every batch for a day, closed ones included', () async {
      // A finished day has to render as finished.
      final Batch first = await openBatch();
      final String other = (await CompanyDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ).create(ownerId: ownerId, name: 'ZR Express')).id;
      final Batch second = await batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: other,
        serviceDate: '2026-09-03',
      );
      await batches.close(first);

      final List<Batch> listed = await batches.forDate(
        ownerId: ownerId,
        serviceDate: '2026-09-03',
      );

      expect(listed.map((Batch b) => b.id).toSet(), <String>{
        first.id,
        second.id,
      });
      expect(
        listed.firstWhere((Batch b) => b.id == first.id).status,
        BatchStatus.closed,
      );
    });

    test('and is scoped to the day', () async {
      await openBatch();
      await openBatch(date: '2026-09-04');

      expect(
        await batches.forDate(ownerId: ownerId, serviceDate: '2026-09-03'),
        hasLength(1),
      );
      expect(
        await batches.forDate(ownerId: ownerId, serviceDate: '2026-09-05'),
        isEmpty,
      );
    });
  });

  test('the outbox command names the batch and the new status', () async {
    final Batch batch = await openBatch();

    await batches.close(batch);

    final QueryRow row = await database
        .customSelect(
          'SELECT entity_type, entity_id, operation, payload FROM outbox '
          'ORDER BY id DESC LIMIT 1',
        )
        .getSingle();

    expect(row.read<String>('entity_type'), 'batch');
    expect(row.read<String>('entity_id'), batch.id);
    expect(row.read<String>('operation'), 'update');
    expect(row.read<String>('payload'), contains('closed'));
  });
}

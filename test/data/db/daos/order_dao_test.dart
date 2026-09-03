import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/state/order_state_machine.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late OrderDao dao;
  late String ownerId;
  late String companyId;
  late String batchId;

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

    batchId =
        (await BatchDao(
              database: database,
              clock: clock,
              uuid: uuid,
              deviceId: 'device-under-test',
            ).ensureOpenBatch(
              ownerId: ownerId,
              companyId: companyId,
              serviceDate: '2026-09-03',
            ))
            .id;

    dao = OrderDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => database.close());

  Future<Order> add({
    String tracking = 'YAL-0001',
    String? customerId,
    Centimes cod = Centimes.zero,
    DeliveryType type = DeliveryType.home,
    String? notes,
  }) => dao.create(
    ownerId: ownerId,
    batchId: batchId,
    companyId: companyId,
    trackingNumber: tracking,
    customerId: customerId,
    codAmount: cod,
    deliveryType: type,
    notes: notes,
  );

  group('a new order', () {
    test('starts wherever the state machine says, not at a literal', () async {
      // Invariant 6. The column has its own default; nothing here relies on it,
      // so there is exactly one place the answer lives. This test fails if the
      // state machine's initial state moves and the DAO does not.
      expect((await add()).status, OrderStateMachine.initial);
    });

    test('and that state is pending', () async {
      // Pinned separately from the line above. Together they say both "the DAO
      // asks the state machine" and "the state machine currently answers
      // pending" — either could change alone and it should be visible.
      expect((await add()).status, OrderStatus.pending);
    });

    test('is version 1, live, in the batch and the company', () async {
      final Order o = await add();

      expect(o.version, 1);
      expect(o.createdAt, DateTime.utc(2026, 9, 3, 7));
      expect(o.deletedAt, isNull);
      expect(o.batchId, batchId);
      expect(o.companyId, companyId);
    });

    test('can be entered with no customer at all', () async {
      // A parcel can arrive before its person does, and the entry flow must not
      // block on that. `orders.customer_id` is nullable for this reason.
      final Order o = await add();

      expect(o.customerId, isNull);
      expect(o.addressId, isNull);
    });

    test('or with one', () async {
      final String customerId =
          (await CustomerDao(
                database: database,
                clock: clock,
                uuid: uuid,
                deviceId: 'device-under-test',
              ).create(
                ownerId: ownerId,
                phone: PhoneE164.parse('0550123456'),
                displayName: 'Amine',
              ))
              .id;

      expect((await add(customerId: customerId)).customerId, customerId);
    });

    test('carries the amount to collect as centimes', () async {
      // Invariant 1. 4500.00 DA is 450000 centimes: 4500 × 100, by the
      // definition of the unit, with no rounding anywhere on the path.
      final Order o = await add(cod: Centimes.fromDinars(4500));

      expect(o.codAmount, const Centimes(450000));
      expect(o.codAmount.value, 450000);
    });

    test('and defaults to a home delivery', () async {
      expect((await add()).deliveryType, DeliveryType.home);
      expect(
        (await add(
          tracking: 'YAL-0002',
          type: DeliveryType.stopdesk,
        )).deliveryType,
        DeliveryType.stopdesk,
      );
    });
  });

  group('what is deliberately not written yet', () {
    test('payment_rule_version is null, not a guessed number', () async {
      // Invariant 8 pins it at creation, but there is no rule to pin before M3.
      // A version written for a rule that does not exist would be inventing the
      // business data a settlement is later reproduced from.
      expect((await add()).paymentRuleVersion, isNull);
    });

    test('and the computed money columns are zero, not estimates', () async {
      // Not unknown — not yet computed. The money engine fills these at M3.
      final Order o = await add(cod: Centimes.fromDinars(4500));

      expect(o.driverCommission, Centimes.zero);
      expect(o.companyAmount, Centimes.zero);
      expect(o.otherFees, Centimes.zero);
      expect(o.collectedAmount, Centimes.zero);
      expect(o.deliveryFee, Centimes.zero);
      expect(o.productValue, Centimes.zero);
    });

    test('and nothing has been attempted', () async {
      final Order o = await add();

      expect(o.attemptCount, 0);
      expect(o.deliveredAt, isNull);
      expect(o.lastAttemptOutcome, isNull);
    });
  });

  group('tracking numbers', () {
    test('are unique within a company', () async {
      await add(tracking: 'YAL-0001');

      await expectLater(add(tracking: 'YAL-0001'), throwsA(anything));
    });

    test('but two companies may use the same one', () async {
      // The unique key is (owner, company, tracking) and not tracking alone.
      // A global rule would reject a real parcel.
      final String otherCompany = (await CompanyDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ).create(ownerId: ownerId, name: 'ZR Express')).id;
      final String otherBatch =
          (await BatchDao(
                database: database,
                clock: clock,
                uuid: uuid,
                deviceId: 'device-under-test',
              ).ensureOpenBatch(
                ownerId: ownerId,
                companyId: otherCompany,
                serviceDate: '2026-09-03',
              ))
              .id;

      await add(tracking: 'SAME-1');
      final Order second = await dao.create(
        ownerId: ownerId,
        batchId: otherBatch,
        companyId: otherCompany,
        trackingNumber: 'SAME-1',
      );

      expect(second.trackingNumber, 'SAME-1');
    });

    test('and findByTracking is scoped to the company', () async {
      final Order mine = await add(tracking: 'YAL-0001');

      expect(
        (await dao.findByTracking(
          ownerId: ownerId,
          companyId: companyId,
          trackingNumber: 'YAL-0001',
        ))!.id,
        mine.id,
      );
      expect(
        await dao.findByTracking(
          ownerId: ownerId,
          companyId: uuid.next(),
          trackingNumber: 'YAL-0001',
        ),
        isNull,
      );
    });

    test('a deleted order stops answering the lookup', () async {
      // Which is what makes re-entering a mistyped number possible.
      final Order o = await add(tracking: 'YAL-0001');

      await dao.softDelete(o);

      expect(
        await dao.findByTracking(
          ownerId: ownerId,
          companyId: companyId,
          trackingNumber: 'YAL-0001',
        ),
        isNull,
      );
    });
  });

  group('the batch list', () {
    test('is newest first, so the last entry is at the top', () async {
      // The list is read to confirm what was just entered.
      final Order first = await add(tracking: 'YAL-0001');
      final Order second = await add(tracking: 'YAL-0002');
      final Order third = await add(tracking: 'YAL-0003');

      expect((await dao.forBatch(batchId)).map((Order o) => o.id), <String>[
        third.id,
        second.id,
        first.id,
      ]);
    });

    test('and it holds even when the clock does not move', () async {
      // Ordered by id rather than created_at: fifteen orders entered inside one
      // millisecond would tie on a timestamp, and a tie means the list reorders
      // itself between two reads. UUIDv7 ids sort by creation and cannot tie.
      final List<Order> entered = <Order>[
        for (int i = 0; i < 15; i++) await add(tracking: 'YAL-${i + 1}'),
      ];

      expect(
        (await dao.forBatch(batchId)).map((Order o) => o.trackingNumber),
        entered.reversed.map((Order o) => o.trackingNumber),
      );
    });

    test('skips the deleted', () async {
      final Order gone = await add(tracking: 'YAL-0001');
      await add(tracking: 'YAL-0002');

      await dao.softDelete(gone);

      expect(await dao.forBatch(batchId), hasLength(1));
    });

    test('and another batch is another list', () async {
      final String otherBatch =
          (await BatchDao(
                database: database,
                clock: clock,
                uuid: uuid,
                deviceId: 'device-under-test',
              ).ensureOpenBatch(
                ownerId: ownerId,
                companyId: companyId,
                serviceDate: '2026-09-04',
              ))
              .id;

      await add(tracking: 'YAL-0001');

      expect(await dao.forBatch(otherBatch), isEmpty);
    });
  });

  test('an order must point at a batch that exists', () async {
    // Foreign keys are on.
    await expectLater(
      dao.create(
        ownerId: ownerId,
        batchId: '00000000-0000-7000-8000-000000000000',
        companyId: companyId,
        trackingNumber: 'YAL-9999',
      ),
      throwsA(anything),
    );
  });
}

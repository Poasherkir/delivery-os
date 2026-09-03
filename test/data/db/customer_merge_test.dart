import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/customer_merge.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// `CustomerMerge`: every live order and address on a loser moves onto a
/// survivor, addresses at the same door collapse to the higher-confidence
/// one, and the whole operation queues exactly one outbox row.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late CustomerMerge merge;
  late CustomerDao customers;
  late AddressDao addresses;
  late OrderDao orders;
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

    await database.customStatement(
      "INSERT INTO wilayas (code, name_fr, name_ar) VALUES (16, 'Alger', 'x')",
    );
    await database.customStatement(
      'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
      "VALUES (1601, 16, 'Bab Ezzouar', 'x')",
    );
    await database.customStatement(
      'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
      "VALUES (1602, 16, 'Dar El Beida', 'x')",
    );

    customers = CustomerDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    addresses = AddressDao(
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

    merge = CustomerMerge(database, clock, uuid, 'device-under-test');
  });

  tearDown(() => database.close());

  Future<Customer> aCustomer(String phone) => customers.create(
    ownerId: ownerId,
    phone: PhoneE164.parse(phone),
    displayName: 'Person $phone',
  );

  Future<CustomerAddress> anAddress(
    String customerId, {
    int communeId = 1601,
    String? detail,
    bool? primary,
  }) => addresses.create(
    ownerId: ownerId,
    customerId: customerId,
    wilayaCode: 16,
    communeId: communeId,
    detail: detail,
    isPrimary: primary,
  );

  Future<Order> anOrder(
    String customerId, {
    String tracking = 'YAL-0001',
    String? addressId,
  }) => orders.create(
    ownerId: ownerId,
    batchId: batchId,
    companyId: companyId,
    trackingNumber: tracking,
    customerId: customerId,
    addressId: addressId,
  );

  Future<void> setConfidence(String addressId, int tier) =>
      database.customStatement(
        'UPDATE customer_addresses SET geo_confidence = ? WHERE id = ?',
        <Object?>[tier, addressId],
      );

  Future<int> outboxCount() async =>
      (await database.customSelect('SELECT count(*) c FROM outbox').getSingle())
          .read<int>('c');

  group('preconditions', () {
    test('a customer cannot be merged into itself', () async {
      final Customer c = await aCustomer('0550111111');

      await expectLater(
        merge.run(survivorId: c.id, loserId: c.id),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('the survivor must exist', () async {
      final Customer loser = await aCustomer('0550111111');

      await expectLater(
        merge.run(survivorId: 'no-such-customer', loserId: loser.id),
        throwsA(isA<StateError>()),
      );
    });

    test('the loser must exist', () async {
      final Customer survivor = await aCustomer('0550111111');

      await expectLater(
        merge.run(survivorId: survivor.id, loserId: 'no-such-customer'),
        throwsA(isA<StateError>()),
      );
    });

    test('an already-deleted loser cannot be merged again', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final Customer other = await aCustomer('0550333333');

      await expectLater(
        merge.run(survivorId: other.id, loserId: loser.id),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('the plain case, nothing attached to either', () {
    test('the loser is soft-deleted, the survivor is untouched', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');

      final Customer result = await merge.run(
        survivorId: survivor.id,
        loserId: loser.id,
      );

      expect(result.id, survivor.id);
      expect(
        result.version,
        survivor.version,
        reason: 'the survivor row itself was not written',
      );

      final Customer? loserRow = await customers.byId(loser.id);
      expect(loserRow!.deletedAt, isNotNull);
    });

    test('and queues exactly one outbox row', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final int before = await outboxCount();

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      expect(await outboxCount(), before + 1);
    });

    test('and the command names both customers', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final QueryRow row = await database
          .customSelect(
            'SELECT entity_type, entity_id, operation, payload '
            'FROM outbox ORDER BY id DESC LIMIT 1',
          )
          .getSingle();

      expect(row.read<String>('entity_type'), 'customer');
      expect(row.read<String>('entity_id'), survivor.id);
      expect(row.read<String>('operation'), 'command');
      expect(row.read<String>('payload'), contains(loser.id));
    });
  });

  group('orders move onto the survivor', () {
    test('every live order the loser had', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final Order first = await anOrder(loser.id, tracking: 'YAL-0001');
      final Order second = await anOrder(loser.id, tracking: 'YAL-0002');

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final List<Order> survivorOrders = await orders.forBatch(batchId);
      expect(
        survivorOrders.map((Order o) => o.customerId),
        everyElement(survivor.id),
      );
      expect(survivorOrders.map((Order o) => o.id).toSet(), <String>{
        first.id,
        second.id,
      });
    });

    test('and the row is stamped, not silently touched', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final Order order = await anOrder(loser.id);
      clock.advance(const Duration(hours: 1));

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final Order? after = await orders.byId(order.id);
      expect(after!.version, order.version + 1);
      expect(after.updatedAt, isNot(order.updatedAt));
    });

    test('a soft-deleted order is left where it is', () async {
      // Nothing surfaces a deleted order, and the loser row it points at still
      // resolves — soft-deleted or not, an order's customer_id is never a
      // dangling reference. There is nothing here that needs reconciling.
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final Order gone = await anOrder(loser.id, tracking: 'YAL-0001');
      await orders.softDelete(gone);

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final Order? after = await orders.byId(gone.id);
      expect(after!.customerId, loser.id);
    });
  });

  group('an address with nothing to collide with', () {
    test('moves onto the survivor, demoted from primary', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final CustomerAddress addr = await anAddress(loser.id, detail: 'Bt 12');
      expect(addr.isPrimary, isTrue, reason: 'the first address is primary');

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final List<CustomerAddress> survivorAddresses = await addresses
          .forCustomer(survivor.id);
      expect(survivorAddresses, hasLength(1));
      expect(survivorAddresses.single.id, addr.id);
      // Demoted on the way in, then promoted back by the end-of-merge rule
      // because it is the only live address the survivor has.
      expect(survivorAddresses.single.isPrimary, isTrue);
    });

    test('a soft-deleted loser address is left alone', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final CustomerAddress gone = await anAddress(loser.id, detail: 'Bt 12');
      await addresses.softDelete(gone);

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final CustomerAddress? after = await addresses.byId(gone.id);
      expect(after!.customerId, loser.id);
    });
  });

  group('two addresses at the same door', () {
    test('the higher-confidence one wins and the other is retired', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final CustomerAddress survivorAddr = await anAddress(
        survivor.id,
        detail: 'Bt 12',
      );
      final CustomerAddress loserAddr = await anAddress(
        loser.id,
        detail: 'Bt 12',
      );
      await setConfidence(loserAddr.id, 4);

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final List<CustomerAddress> live = await addresses.forCustomer(
        survivor.id,
      );
      expect(live, hasLength(1));
      expect(live.single.id, loserAddr.id);
      expect(
        (await addresses.byId(survivorAddr.id))!.deletedAt,
        isNotNull,
        reason: 'the weaker duplicate is retired, not left beside the winner',
      );
    });

    test(
      'and orders that pointed at the retired one are repointed to the winner',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');
        final CustomerAddress survivorAddr = await anAddress(
          survivor.id,
          detail: 'Bt 12',
        );
        final Order preexisting = await orders.create(
          ownerId: ownerId,
          batchId: batchId,
          companyId: companyId,
          trackingNumber: 'YAL-PRE',
          customerId: survivor.id,
          addressId: survivorAddr.id,
        );
        final CustomerAddress loserAddr = await anAddress(
          loser.id,
          detail: 'Bt 12',
        );
        await setConfidence(loserAddr.id, 4);
        final Order fromLoser = await anOrder(
          loser.id,
          tracking: 'YAL-LOSER',
          addressId: loserAddr.id,
        );

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        expect((await orders.byId(preexisting.id))!.addressId, loserAddr.id);
        expect((await orders.byId(fromLoser.id))!.addressId, loserAddr.id);
      },
    );

    test('a tie keeps the survivor\'s own row', () async {
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final CustomerAddress survivorAddr = await anAddress(
        survivor.id,
        detail: 'Bt 12',
      );
      final CustomerAddress loserAddr = await anAddress(
        loser.id,
        detail: 'Bt 12',
      );
      // Both at the schema default confidence: tier 0.

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final List<CustomerAddress> live = await addresses.forCustomer(
        survivor.id,
      );
      expect(live, hasLength(1));
      expect(live.single.id, survivorAddr.id);
      expect((await addresses.byId(loserAddr.id))!.deletedAt, isNotNull);
    });

    test(
      'and orders that pointed at the retired loser address follow it',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');
        final CustomerAddress survivorAddr = await anAddress(
          survivor.id,
          detail: 'Bt 12',
        );
        final CustomerAddress loserAddr = await anAddress(
          loser.id,
          detail: 'Bt 12',
        );
        final Order fromLoser = await anOrder(
          loser.id,
          addressId: loserAddr.id,
        );

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        expect((await orders.byId(fromLoser.id))!.addressId, survivorAddr.id);
      },
    );

    test('a different detail at the same commune is not a collision', () async {
      // "Bt 12" and "Bt 14" in the same commune are two different doors.
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      await anAddress(survivor.id, detail: 'Bt 12');
      await anAddress(loser.id, detail: 'Bt 14');

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      expect(await addresses.forCustomer(survivor.id), hasLength(2));
    });

    test('the winning pin\'s own data is untouched, only reassigned', () async {
      // Invariant 9: never silently downgrade a pin. Winning must not mean
      // "rewritten" — its coordinates, confidence and evidence count are the
      // reason it won, and they must survive the move exactly as they were.
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      await anAddress(survivor.id, detail: 'Bt 12');
      final CustomerAddress loserAddr = await anAddress(
        loser.id,
        detail: 'Bt 12',
      );
      await database.customStatement(
        'UPDATE customer_addresses SET geo_confidence = 4, latitude = ?, '
        'longitude = ?, confirmed_deliveries = 3 WHERE id = ?',
        <Object?>[36.72, 3.18, loserAddr.id],
      );

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      final CustomerAddress winner = (await addresses.forCustomer(
        survivor.id,
      )).single;
      expect(winner.id, loserAddr.id);
      expect(winner.latitude, 36.72);
      expect(winner.longitude, 3.18);
      expect(winner.confirmedDeliveries, 3);
    });
  });

  group('exactly one primary survives, whatever the inputs', () {
    test(
      'the survivor\'s existing primary is left alone when nothing touches it',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');
        final CustomerAddress primary = await anAddress(
          survivor.id,
          detail: 'Bt 12',
        );
        await anAddress(loser.id, detail: 'Bt 99');

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        expect((await addresses.byId(primary.id))!.isPrimary, isTrue);
        final List<CustomerAddress> live = await addresses.forCustomer(
          survivor.id,
        );
        expect(live.where((CustomerAddress a) => a.isPrimary), hasLength(1));
      },
    );

    test(
      'a primary lost to a stronger incoming pin is replaced, not left absent',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');
        final CustomerAddress survivorPrimary = await anAddress(
          survivor.id,
          detail: 'Bt 12',
        );
        expect(survivorPrimary.isPrimary, isTrue);
        final CustomerAddress loserAddr = await anAddress(
          loser.id,
          detail: 'Bt 12',
        );
        await setConfidence(loserAddr.id, 4);

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        final List<CustomerAddress> live = await addresses.forCustomer(
          survivor.id,
        );
        expect(live, hasLength(1));
        expect(
          live.single.isPrimary,
          isTrue,
          reason: 'the sole survivor of the merge must end up primary',
        );
      },
    );

    test(
      'a survivor with no addresses inherits the loser\'s as primary',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');
        await anAddress(loser.id, detail: 'Bt 12', primary: true);

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        final List<CustomerAddress> live = await addresses.forCustomer(
          survivor.id,
        );
        expect(live, hasLength(1));
        expect(live.single.isPrimary, isTrue);
      },
    );

    test(
      'two customers with no addresses at all merge without error',
      () async {
        final Customer survivor = await aCustomer('0550111111');
        final Customer loser = await aCustomer('0550222222');

        await merge.run(survivorId: survivor.id, loserId: loser.id);

        expect(await addresses.forCustomer(survivor.id), isEmpty);
      },
    );
  });

  test(
    'a realistic merge touches many rows behind exactly one outbox row',
    () async {
      // The point of OutboxOperation.command: proves the design, not merely one
      // simple case of it. Two addresses collide, one moves free, four orders
      // move — at least seven row writes behind one outbox entry.
      final Customer survivor = await aCustomer('0550111111');
      final Customer loser = await aCustomer('0550222222');
      final CustomerAddress survivorHome = await anAddress(
        survivor.id,
        detail: 'Bt 12',
      );
      final CustomerAddress loserHome = await anAddress(
        loser.id,
        detail: 'Bt 12',
      );
      await setConfidence(loserHome.id, 4);
      final CustomerAddress loserWork = await anAddress(
        loser.id,
        communeId: 1602,
        detail: 'Zone industrielle',
      );
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-PRE',
        customerId: survivor.id,
        addressId: survivorHome.id,
      );
      await anOrder(loser.id, tracking: 'YAL-0001', addressId: loserHome.id);
      await anOrder(loser.id, tracking: 'YAL-0002', addressId: loserWork.id);
      await anOrder(loser.id, tracking: 'YAL-0003');
      final int before = await outboxCount();

      await merge.run(survivorId: survivor.id, loserId: loser.id);

      expect(await outboxCount(), before + 1);
      expect(await addresses.forCustomer(survivor.id), hasLength(2));
      expect(
        (await orders.forBatch(
          batchId,
        )).where((Order o) => o.customerId == survivor.id),
        hasLength(4),
      );
    },
  );
}

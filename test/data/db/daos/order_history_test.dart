import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// `OrderDao.historyForCustomer` and its count.
///
/// The window is the point: this screen is a detail view a driver taps into
/// mid-round, and a customer with a year of parcels must not make it fetch all
/// of them. What is worth testing is that the bound is real, that the count
/// still tells the truth about what was left out, and that the window takes the
/// *recent* end rather than an arbitrary one.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late OrderDao orders;
  late CustomerDao customers;
  late AddressDao addresses;
  late BatchDao batches;
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
      "VALUES (1601, 16, 'Bab Ezzouar', 'باب الزوار')",
    );

    orders = OrderDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
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
    batches = BatchDao(
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
    batchId = (await batches.ensureOpenBatch(
      ownerId: ownerId,
      companyId: companyId,
      serviceDate: '2026-09-03',
    )).id;
  });

  tearDown(() => database.close());

  Future<Customer> aCustomer([String phone = '0550123456']) => customers.create(
    ownerId: ownerId,
    phone: PhoneE164.parse(phone),
    displayName: 'Amine',
  );

  Future<Order> anOrder(
    String customerId, {
    required String tracking,
    String? batch,
    String? addressId,
    Centimes cod = Centimes.zero,
  }) => orders.create(
    ownerId: ownerId,
    batchId: batch ?? batchId,
    companyId: companyId,
    trackingNumber: tracking,
    customerId: customerId,
    addressId: addressId,
    codAmount: cod,
  );

  Future<List<OrderSummaryRow>> history(String customerId, {int? limit}) =>
      orders.historyForCustomer(
        ownerId: ownerId,
        customerId: customerId,
        limit: limit,
      );

  Future<int> count(String customerId) =>
      orders.historyCountForCustomer(ownerId: ownerId, customerId: customerId);

  group('scope', () {
    test('is one customer', () async {
      final Customer mine = await aCustomer('0550111111');
      final Customer other = await aCustomer('0550222222');
      await anOrder(mine.id, tracking: 'YAL-0001');
      await anOrder(other.id, tracking: 'YAL-0002');

      final List<OrderSummaryRow> rows = await history(mine.id);

      expect(rows, hasLength(1));
      expect(rows.single.trackingNumber, 'YAL-0001');
      expect(await count(mine.id), 1);
    });

    test('and spans every day, not just today', () async {
      // The whole difference from the orders list: history is not one batch.
      final Customer c = await aCustomer();
      final String yesterday = (await batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: companyId,
        serviceDate: '2026-09-02',
      )).id;
      await anOrder(c.id, tracking: 'YAL-TODAY');
      await anOrder(c.id, tracking: 'YAL-YESTERDAY', batch: yesterday);

      expect(await history(c.id), hasLength(2));
      expect(await count(c.id), 2);
    });

    test('skips soft-deleted parcels, in the list and in the count', () async {
      // Both have to agree. A count that included a deleted row would make the
      // screen offer to load rows that are not there.
      final Customer c = await aCustomer();
      final Order gone = await anOrder(c.id, tracking: 'YAL-0001');
      await anOrder(c.id, tracking: 'YAL-0002');
      await orders.softDelete(gone);

      expect(await history(c.id), hasLength(1));
      expect(await count(c.id), 1);
    });

    test('a customer with nothing has nothing, not an error', () async {
      final Customer c = await aCustomer();

      expect(await history(c.id), isEmpty);
      expect(await count(c.id), 0);
    });
  });

  group('the window', () {
    /// More parcels than the default window, so the bound is exercised rather
    /// than merely present. Each in its own batch is unnecessary — the join
    /// does not care — so they share one, which is also the realistic case.
    Future<Customer> withOrders(int howMany) async {
      final Customer c = await aCustomer();
      for (int i = 0; i < howMany; i++) {
        await anOrder(c.id, tracking: 'YAL-${1000 + i}');
      }
      return c;
    }

    test('bounds the rows returned', () async {
      final Customer c = await withOrders(60);

      expect(await history(c.id, limit: 50), hasLength(50));
    });

    test('but the count still reports every one of them', () async {
      // The reason the count is a separate query. Deriving the total from the
      // window's length would make a full window indistinguishable from a
      // complete history, and the screen would stop offering the rest.
      final Customer c = await withOrders(60);

      expect(await count(c.id), 60);
    });

    test('and it takes the most recent, not an arbitrary fifty', () async {
      final Customer c = await aCustomer();
      final List<Order> entered = <Order>[
        for (int i = 0; i < 10; i++)
          await anOrder(c.id, tracking: 'YAL-${1000 + i}'),
      ];

      final List<OrderSummaryRow> rows = await history(c.id, limit: 3);

      expect(
        rows.map((OrderSummaryRow r) => r.id),
        entered.reversed.take(3).map((Order o) => o.id),
      );
    });

    test('a null limit loads all of them', () async {
      // What "see all" reaches. Explicit, and never the default.
      final Customer c = await withOrders(60);

      expect(await history(c.id, limit: null), hasLength(60));
    });

    test('a limit larger than the history is not an error', () async {
      final Customer c = await withOrders(3);

      expect(await history(c.id, limit: 50), hasLength(3));
    });
  });

  group('the row carries what the profile renders', () {
    test('the service date, which is what makes it a history', () async {
      final Customer c = await aCustomer();
      await anOrder(c.id, tracking: 'YAL-0001');

      expect((await history(c.id)).single.serviceDate, '2026-09-03');
    });

    test('the money, through its converter', () async {
      // 4500 DA is 450000 centimes: 4500 × 100 by the definition of the unit.
      final Customer c = await aCustomer();
      await anOrder(c.id, tracking: 'YAL-0001', cod: Centimes.fromDinars(4500));

      expect((await history(c.id)).single.codAmount, const Centimes(450000));
    });

    test('and the commune, when there is an address', () async {
      final Customer c = await aCustomer();
      final CustomerAddress addr = await addresses.create(
        ownerId: ownerId,
        customerId: c.id,
        wilayaCode: 16,
        communeId: 1601,
        detail: 'Bt 12',
      );
      await anOrder(c.id, tracking: 'YAL-0001', addressId: addr.id);

      final OrderSummaryRow row = (await history(c.id)).single;
      expect(row.communeNameFr, 'Bab Ezzouar');
      expect(row.communeNameAr, 'باب الزوار');
    });

    test('and renders without one', () async {
      // A parcel entered before an address was attached still belongs in the
      // history — the left joins are what make that true.
      final Customer c = await aCustomer();
      await anOrder(c.id, tracking: 'YAL-0001');

      final OrderSummaryRow row = (await history(c.id)).single;
      expect(row.communeNameFr, isNull);
      expect(row.customerName, 'Amine');
    });
  });
}

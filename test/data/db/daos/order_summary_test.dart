import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// `OrderDao.summariesForDate`: one query across five tables.
///
/// The join is the thing worth testing, not the DAO shape — a left join wired
/// to the wrong column silently drops rows or silently renders every commune
/// as null, and neither throws.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late UuidV7Generator uuid;
  late OrderDao orders;
  late CompanyDao companies;
  late BatchDao batches;
  late CustomerDao customers;
  late AddressDao addresses;
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

    companyId = (await companies.create(ownerId: ownerId, name: 'Yalidine')).id;
    batchId = (await batches.ensureOpenBatch(
      ownerId: ownerId,
      companyId: companyId,
      serviceDate: '2026-09-03',
    )).id;
  });

  tearDown(() => database.close());

  Future<List<OrderSummaryRow>> summaries({String date = '2026-09-03'}) =>
      orders.summariesForDate(ownerId: ownerId, serviceDate: date);

  group('a parcel with nobody and nowhere attached', () {
    test(
      'still appears, with the joins reading null rather than blank',
      () async {
        // Enterable before deliverable. A row that vanished here would be a
        // parcel the driver entered that the list silently dropped.
        await orders.create(
          ownerId: ownerId,
          batchId: batchId,
          companyId: companyId,
          trackingNumber: 'YAL-0001',
        );

        final List<OrderSummaryRow> rows = await summaries();

        expect(rows, hasLength(1));
        expect(rows.single.trackingNumber, 'YAL-0001');
        expect(rows.single.customerName, isNull);
        expect(rows.single.communeNameFr, isNull);
        expect(rows.single.communeNameAr, isNull);
        expect(rows.single.addressDetail, isNull);
      },
    );
  });

  group('a parcel with a customer but no address', () {
    test('carries the name and no commune', () async {
      final String customerId = (await customers.create(
        ownerId: ownerId,
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine Bensalem',
      )).id;
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0002',
        customerId: customerId,
      );

      final OrderSummaryRow row = (await summaries()).single;

      expect(row.customerName, 'Amine Bensalem');
      expect(row.communeNameFr, isNull);
    });
  });

  group('a parcel with a full address', () {
    test('carries both commune names and the detail', () async {
      final String customerId = (await customers.create(
        ownerId: ownerId,
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine Bensalem',
      )).id;
      final String addressId = (await addresses.create(
        ownerId: ownerId,
        customerId: customerId,
        wilayaCode: 16,
        communeId: 1601,
        detail: 'Bt 12, 3e étage',
      )).id;
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0003',
        customerId: customerId,
        addressId: addressId,
      );

      final OrderSummaryRow row = (await summaries()).single;

      expect(row.communeNameFr, 'Bab Ezzouar');
      expect(row.communeNameAr, 'باب الزوار');
      expect(row.addressDetail, 'Bt 12, 3e étage');
    });
  });

  test(
    'the company name travels, for a driver working two in one day',
    () async {
      final String otherCompany = (await companies.create(
        ownerId: ownerId,
        name: 'ZR Express',
      )).id;
      final String otherBatch = (await batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: otherCompany,
        serviceDate: '2026-09-03',
      )).id;
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0004',
      );
      await orders.create(
        ownerId: ownerId,
        batchId: otherBatch,
        companyId: otherCompany,
        trackingNumber: 'ZR-0001',
      );

      final List<OrderSummaryRow> rows = await summaries();

      expect(rows.map((OrderSummaryRow r) => r.companyName).toSet(), <String>{
        'Yalidine',
        'ZR Express',
      });
    },
  );

  test(
    'money, status and delivery type round-trip through their converters',
    () async {
      // Read back through the same converter the column is written with,
      // not a raw string comparison — a status spelled two ways would agree
      // here and disagree everywhere else.
      final Order created = await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0005',
        codAmount: Centimes.fromDinars(4500),
        deliveryType: DeliveryType.stopdesk,
      );

      final OrderSummaryRow row = (await summaries()).single;

      expect(row.id, created.id);
      expect(row.codAmount, const Centimes(450000));
      expect(row.status, OrderStatus.pending);
      expect(row.deliveryType, DeliveryType.stopdesk);
    },
  );

  group('scope', () {
    test('is one owner, one service date', () async {
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0006',
      );
      final String tomorrow = (await batches.ensureOpenBatch(
        ownerId: ownerId,
        companyId: companyId,
        serviceDate: '2026-09-04',
      )).id;
      await orders.create(
        ownerId: ownerId,
        batchId: tomorrow,
        companyId: companyId,
        trackingNumber: 'YAL-0007',
      );

      expect(await summaries(date: '2026-09-03'), hasLength(1));
      expect(await summaries(date: '2026-09-04'), hasLength(1));
      expect(await summaries(date: '2026-09-05'), isEmpty);
    });

    test('skips a soft-deleted order', () async {
      final Order gone = await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0008',
      );
      await orders.create(
        ownerId: ownerId,
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-0009',
      );
      await orders.softDelete(gone);

      final List<OrderSummaryRow> rows = await summaries();

      expect(rows, hasLength(1));
      expect(rows.single.trackingNumber, 'YAL-0009');
    });
  });

  group('ordering', () {
    test(
      'is newest first, by id, so a same-millisecond tie cannot happen',
      () async {
        final List<Order> entered = <Order>[
          for (int i = 0; i < 5; i++)
            await orders.create(
              ownerId: ownerId,
              batchId: batchId,
              companyId: companyId,
              trackingNumber: 'YAL-0${10 + i}',
            ),
        ];

        final List<String> ids = (await summaries())
            .map((OrderSummaryRow r) => r.id)
            .toList();

        expect(ids, entered.reversed.map((Order o) => o.id).toList());
      },
    );
  });

  test('a day with nothing entered returns nothing, not an error', () async {
    expect(await summaries(date: '2026-09-03'), isEmpty);
  });
}

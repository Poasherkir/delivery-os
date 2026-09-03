import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/data/repositories/drift_address_repository.dart';
import 'package:delivery_os/data/repositories/drift_batch_repository.dart';
import 'package:delivery_os/data/repositories/drift_customer_repository.dart';
import 'package:delivery_os/data/repositories/drift_order_repository.dart';
import 'package:delivery_os/domain/entities/address.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/address_repository.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/orders/controllers/order_entry_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Against a real in-memory database rather than fakes.
///
/// The thing under test is an *ordering* across four repositories — duplicate
/// check, batch, customer, address — and fakes would let that ordering pass
/// while the real constraints it exists to respect were violated. The unique
/// key on tracking numbers and the foreign keys are the point.
void main() {
  late db.AppDatabase database;
  late ProviderContainer container;
  late OrderEntryController controller;
  late CustomerRepository customers;
  late AddressRepository addresses;
  late OrderRepository orders;
  late String companyId;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();

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

    companyId = (await CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    ).create(ownerId: user.id, name: 'Yalidine')).id;

    customers = DriftCustomerRepository(
      dao: CustomerDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
    addresses = DriftAddressRepository(
      dao: AddressDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
    orders = DriftOrderRepository(
      dao: OrderDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    );
    final BatchRepository batches = DriftBatchRepository(
      dao: BatchDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    );

    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(customers),
        addressRepositoryProvider.overrideWithValue(addresses),
        orderRepositoryProvider.overrideWithValue(orders),
        batchRepositoryProvider.overrideWithValue(batches),
      ],
    );
    controller = container.read(orderEntryControllerProvider);
  });

  tearDown(() {
    container.dispose();
    return database.close();
  });

  OrderDraft draft({
    String tracking = 'YAL-0001',
    String phone = '',
    String name = '',
    int? commune,
    String? detail,
    Centimes cod = Centimes.zero,
    DeliveryType type = DeliveryType.home,
    String? notes,
  }) => OrderDraft(
    companyId: companyId,
    trackingNumber: tracking,
    phone: phone,
    customerName: name,
    wilayaCode: commune == null ? null : 16,
    communeId: commune,
    addressDetail: detail,
    codAmount: cod,
    deliveryType: type,
    notes: notes,
  );

  Future<Order> save(OrderDraft d) async {
    final OrderEntryResult result = await controller.submit(d);
    return (result as OrderEntrySaved).order;
  }

  group('the smallest possible parcel', () {
    test('a tracking number alone is enough', () async {
      // Only the tracking number is required. A driver standing in an agency
      // at 07:00 must not be stopped by a field, and a parcel with no customer
      // is enterable even though it is not deliverable.
      final Order order = await save(draft());

      expect(order.trackingNumber, 'YAL-0001');
      expect(order.needsCustomer, isTrue);
      expect(order.addressId, isNull);
      expect(order.status, OrderStatus.pending);
    });

    test('and it opens the day if the day is not open yet', () async {
      final Order order = await save(draft());

      expect(order.batchId, isNotEmpty);
      expect(order.companyId, companyId);
    });

    test('a second parcel joins the same batch', () async {
      // One batch per company per day. Fifteen parcels are fifteen orders and
      // one batch, not fifteen.
      final Order first = await save(draft(tracking: 'YAL-0001'));
      final Order second = await save(draft(tracking: 'YAL-0002'));

      expect(second.batchId, first.batchId);
    });
  });

  group('the customer', () {
    test('is created when the number is new', () async {
      await save(draft(phone: '0550123456', name: 'Amine'));

      final Customer? found = await customers.findByPhone(
        PhoneE164.parse('0550123456'),
      );
      expect(found, isNotNull);
      expect(found!.displayName, 'Amine');
    });

    test('and reused when it is not', () async {
      // The payoff for looking a number up while it is being typed: the second
      // parcel for the same person creates nobody.
      final Order first = await save(
        draft(tracking: 'YAL-0001', phone: '0550123456', name: 'Amine'),
      );
      final Order second = await save(
        draft(tracking: 'YAL-0002', phone: '0550123456'),
      );

      expect(second.customerId, first.customerId);
      expect(await customers.all(), hasLength(1));
    });

    test('a number that will not parse is kept verbatim', () async {
      // Algeria closed its numbering plan in 2008 and older landline formats
      // are shorter than nine digits, so this is as likely to be our gap as
      // the driver's typo. It must not stop the parcel being entered.
      final Order order = await save(
        draft(phone: '021 44 55 66', name: 'Atelier Centre'),
      );

      expect(order.customerId, isNotNull);
      final List<Customer> review = await customers.needingPhoneReview();
      expect(review, hasLength(1));
      expect(review.single.phoneRaw, '021 44 55 66');
    });

    test('and with no name typed, the number becomes the name', () async {
      // Not a localized placeholder and not an invented name. The number is a
      // true fact about this customer and is what the driver will recognise
      // them by — and `customers.display_name` is NOT NULL, so something has
      // to go there.
      await save(draft(phone: '0550123456'));

      final Customer? found = await customers.findByPhone(
        PhoneE164.parse('0550123456'),
      );
      expect(found!.displayName, '0550123456');
    });
  });

  group('the address', () {
    test('is created from the commune and the detail', () async {
      final Order order = await save(
        draft(phone: '0550123456', commune: 1601, detail: 'Bt 12, 3e étage'),
      );

      expect(order.addressId, isNotNull);
      final List<Address> stored = await addresses.forCustomer(
        order.customerId!,
      );
      expect(stored, hasLength(1));
      expect(stored.single.communeId, 1601);
      expect(stored.single.detail, 'Bt 12, 3e étage');
    });

    test('is reused when the same door comes back', () async {
      // A repeat customer at one address must not collect a row per parcel.
      final Order first = await save(
        draft(
          tracking: 'YAL-0001',
          phone: '0550123456',
          commune: 1601,
          detail: 'Bt 12',
        ),
      );
      final Order second = await save(
        draft(
          tracking: 'YAL-0002',
          phone: '0550123456',
          commune: 1601,
          detail: 'Bt 12',
        ),
      );

      expect(second.addressId, first.addressId);
      expect(await addresses.forCustomer(first.customerId!), hasLength(1));
    });

    test('but a different door is a different address', () async {
      final Order home = await save(
        draft(
          tracking: 'YAL-0001',
          phone: '0550123456',
          commune: 1601,
          detail: 'Bt 12',
        ),
      );
      final Order work = await save(
        draft(
          tracking: 'YAL-0002',
          phone: '0550123456',
          commune: 1602,
          detail: 'Zone industrielle',
        ),
      );

      expect(work.addressId, isNot(home.addressId));
      expect(await addresses.forCustomer(home.customerId!), hasLength(2));
    });

    test('and leaving it blank reuses what the customer already has', () async {
      // The other half of the lookup payoff. A known customer's parcel needs
      // no address typed at all, which is the tap this screen is built to save.
      final Order first = await save(
        draft(
          tracking: 'YAL-0001',
          phone: '0550123456',
          commune: 1601,
          detail: 'Bt 12',
        ),
      );
      final Order second = await save(
        draft(tracking: 'YAL-0002', phone: '0550123456'),
      );

      expect(second.addressId, first.addressId);
    });

    test(
      'no commune and no history means no address, not an empty one',
      () async {
        final Order order = await save(draft(phone: '0550123456'));

        expect(order.addressId, isNull);
        expect(await addresses.forCustomer(order.customerId!), isEmpty);
      },
    );

    test('and an address needs a customer to belong to', () async {
      // A commune with no phone typed. `customer_addresses.customer_id` is NOT
      // NULL, so there is nowhere to put it.
      final Order order = await save(draft(commune: 1601, detail: 'Bt 12'));

      expect(order.customerId, isNull);
      expect(order.addressId, isNull);
    });
  });

  group('scanning the same parcel twice', () {
    test('comes back as the parcel already entered', () async {
      final Order first = await save(draft(tracking: 'YAL-0001'));

      final OrderEntryResult again = await controller.submit(
        draft(tracking: 'YAL-0001'),
      );

      expect(again, isA<OrderEntryDuplicate>());
      expect((again as OrderEntryDuplicate).existing.id, first.id);
    });

    test('and creates nobody on the way out', () async {
      // The reason the duplicate check runs before anything is written. A
      // customer created for an order that is then refused is a record of
      // somebody nobody asked for, sitting in the customer list forever.
      final Order only = await save(draft(tracking: 'YAL-0001'));

      final OrderEntryResult again = await controller.submit(
        draft(tracking: 'YAL-0001', phone: '0550999888', name: 'Ghost'),
      );

      expect(again, isA<OrderEntryDuplicate>());
      expect(
        await customers.findByPhone(PhoneE164.parse('0550999888')),
        isNull,
        reason: 'a refused order left a customer behind',
      );
      expect(await orders.forBatch(only.batchId), hasLength(1));
    });

    test('a padded rescan is still the same parcel', () async {
      await save(draft(tracking: 'YAL-0001'));

      expect(
        await controller.submit(draft(tracking: '  YAL-0001  ')),
        isA<OrderEntryDuplicate>(),
      );
    });
  });

  group('what the driver stated is what is stored', () {
    test('a stop-desk parcel stays stop desk', () async {
      // It cannot be derived from anything else — it comes off the label — and
      // a stop-desk parcel must never enter the optimized route.
      final Order order = await save(draft(type: DeliveryType.stopdesk));

      expect(order.deliveryType, DeliveryType.stopdesk);
    });

    test('and home is the default', () async {
      expect((await save(draft())).deliveryType, DeliveryType.home);
    });

    test('the amount arrives in centimes', () async {
      // Invariant 1. The form converts whole dinars; 4500 DA is 450000
      // centimes, 4500 × 100 by the definition of the unit.
      final Order order = await save(draft(cod: Centimes.fromDinars(4500)));

      expect(order.codAmount, const Centimes(450000));
    });

    test('and a note survives', () async {
      expect((await save(draft(notes: 'fragile'))).notes, 'fragile');
    });
  });

  test('with no database, nothing is written and nothing pretends', () async {
    final ProviderContainer empty = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(null),
        batchRepositoryProvider.overrideWithValue(null),
        customerRepositoryProvider.overrideWithValue(null),
        addressRepositoryProvider.overrideWithValue(null),
      ],
    );
    addTearDown(empty.dispose);

    expect(
      await empty.read(orderEntryControllerProvider).submit(draft()),
      isA<OrderEntryUnavailable>(),
    );
  });
}

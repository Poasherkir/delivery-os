import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/data/repositories/drift_customer_repository.dart';
import 'package:delivery_os/data/repositories/drift_order_repository.dart';
import 'package:delivery_os/domain/entities/customer_history.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/entities/order_summary.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late FixedClock clock;
  late OrderRepository repo;
  late String ownerId;
  late String companyId;
  late String batchId;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();
    ownerId = user.id;

    companyId = (await CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    ).create(ownerId: user.id, name: 'Yalidine')).id;

    batchId =
        (await BatchDao(
              database: database,
              clock: clock,
              uuid: uuid,
              deviceId: 'device-under-test',
            ).ensureOpenBatch(
              ownerId: user.id,
              companyId: companyId,
              serviceDate: '2026-09-03',
            ))
            .id;

    repo = DriftOrderRepository(
      dao: OrderDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    );
  });

  tearDown(() => database.close());

  Future<Order> add({
    String tracking = 'YAL-0001',
    Centimes cod = Centimes.zero,
  }) => repo.create(
    batchId: batchId,
    companyId: companyId,
    trackingNumber: tracking,
    codAmount: cod,
  );

  test('a created order comes back as a domain order', () async {
    final Order o = await add(cod: Centimes.fromDinars(4500));

    expect(o, isA<Order>());
    expect(o.trackingNumber, 'YAL-0001');
    expect(o.status, OrderStatus.pending);
    expect(o.codAmount, const Centimes(450000));
    expect(o.needsCustomer, isTrue);
  });

  group('scanning the same parcel twice', () {
    test('is refused by name, not by a constraint violation', () async {
      // The ordinary way this happens is a driver scanning a parcel they
      // already scanned. A bare "unique constraint failed" would make the UI go
      // and look for the order before it could say anything useful.
      await add(tracking: 'YAL-0001');

      await expectLater(
        add(tracking: 'YAL-0001'),
        throwsA(isA<DuplicateTrackingException>()),
      );
    });

    test('and the failure carries the order that already has it', () async {
      final Order first = await add(tracking: 'YAL-0001');

      await expectLater(
        add(tracking: 'YAL-0001'),
        throwsA(
          isA<DuplicateTrackingException>().having(
            (DuplicateTrackingException e) => e.existing.id,
            'existing.id',
            first.id,
          ),
        ),
      );
    });

    test('and nothing was written on the way out', () async {
      await add(tracking: 'YAL-0001');

      await expectLater(
        add(tracking: 'YAL-0001'),
        throwsA(isA<DuplicateTrackingException>()),
      );

      expect(await repo.forBatch(batchId), hasLength(1));
    });

    test('but a deleted one does not block re-entry', () async {
      // A mistyped number has to be correctable, and the delete is soft.
      final Order wrong = await add(tracking: 'YAL-0001');
      await repo.softDelete(wrong);

      final Order retyped = await add(tracking: 'YAL-0001');

      expect(retyped.id, isNot(wrong.id));
    });
  });

  group('the tracking number is trimmed', () {
    test('on create', () async {
      // A trailing space from a barcode reader or a soft keyboard would make
      // two spellings of one parcel, and the duplicate check would miss it.
      expect((await add(tracking: '  YAL-0001  ')).trackingNumber, 'YAL-0001');
    });

    test('so a padded rescan is still recognised as the same parcel', () async {
      await add(tracking: 'YAL-0001');

      await expectLater(
        add(tracking: ' YAL-0001 '),
        throwsA(isA<DuplicateTrackingException>()),
      );
    });

    test('and the lookup trims too', () async {
      final Order o = await add(tracking: 'YAL-0001');

      expect(
        (await repo.findByTracking(
          companyId: companyId,
          trackingNumber: ' YAL-0001 ',
        ))!.id,
        o.id,
      );
    });
  });

  test('forBatch returns the day so far, newest first', () async {
    final Order first = await add(tracking: 'YAL-0001');
    final Order second = await add(tracking: 'YAL-0002');

    expect((await repo.forBatch(batchId)).map((Order o) => o.id), <String>[
      second.id,
      first.id,
    ]);
  });

  test('deleting an order that is already gone fails loudly', () async {
    // Not silently ignored. A row that has vanished is a state the screen has
    // to handle rather than one to absorb here.
    final Order o = await add();
    await database.customStatement('DELETE FROM orders WHERE id = ?', <Object?>[
      o.id,
    ]);

    await expectLater(repo.softDelete(o), throwsA(isA<StateError>()));
  });
  group('summariesForDate', () {
    test('defaults to the current service day', () async {
      await add(tracking: 'YAL-0001');

      final List<OrderSummary> today = await repo.summariesForDate();

      expect(today, hasLength(1));
      expect(today.single.trackingNumber, 'YAL-0001');
    });

    test('and after midnight is still the day that just ended', () async {
      // 23:30 UTC on the 3rd is 00:30 in Algiers on the 4th. A parcel entered
      // then belongs to the batch already open for the 3rd, and the list
      // default has to agree with `ensureOpenBatch` about which day that is.
      clock.instant = DateTime.utc(2026, 9, 3, 23, 30);
      await add(tracking: 'YAL-0002');

      final List<OrderSummary> rows = await repo.summariesForDate();

      expect(rows, hasLength(1));
      expect(rows.single.trackingNumber, 'YAL-0002');
      expect(await repo.summariesForDate(serviceDate: '2026-09-04'), isEmpty);
    });

    test('an explicit date overrides the default', () async {
      await add(tracking: 'YAL-0003');

      expect(await repo.summariesForDate(serviceDate: '2026-09-04'), isEmpty);
    });

    test('comes back as domain summaries, not Drift rows', () async {
      await add(tracking: 'YAL-0004', cod: Centimes.fromDinars(4500));

      final OrderSummary row = (await repo.summariesForDate()).single;

      expect(row, isA<OrderSummary>());
      expect(row.codAmount, const Centimes(450000));
      expect(row.companyName, 'Yalidine');
      expect(row.needsCustomer, isTrue);
    });
  });
  group('historyForCustomer', () {
    late String customerId;

    setUp(() async {
      customerId = (await DriftCustomerRepository(
        dao: CustomerDao(
          database: database,
          clock: clock,
          uuid: UuidV7Generator(clock: clock),
          deviceId: 'device-under-test',
        ),
        ownerId: ownerId,
      ).create(phone: PhoneE164.parse('0550123456'), displayName: 'Amine')).id;
    });

    Future<void> addOrders(int howMany) async {
      for (int i = 0; i < howMany; i++) {
        await repo.create(
          batchId: batchId,
          companyId: companyId,
          trackingNumber: 'YAL-${1000 + i}',
          customerId: customerId,
        );
      }
    }

    test('reports the window and the true total separately', () async {
      await addOrders(5);

      final CustomerHistory history = await repo.historyForCustomer(
        customerId,
        limit: 3,
      );

      expect(history.recent, hasLength(3));
      expect(history.total, 5);
      expect(history.isWindowed, isTrue);
      expect(history.hidden, 2);
    });

    test('and is not windowed when everything fits', () async {
      await addOrders(3);

      final CustomerHistory history = await repo.historyForCustomer(
        customerId,
        limit: 50,
      );

      expect(history.isWindowed, isFalse);
      expect(history.hidden, 0);
    });

    test('defaults to the bounded window, never the whole history', () async {
      // The default matters more than any other value here: it is what a
      // driver gets for opening the screen, and it is the one that must not
      // be unbounded.
      expect(CustomerHistory.defaultWindow, 50);
      await addOrders(60);

      final CustomerHistory history = await repo.historyForCustomer(customerId);

      expect(history.recent, hasLength(CustomerHistory.defaultWindow));
      expect(history.total, 60);
    });

    test('a null limit is the explicit see-all', () async {
      await addOrders(60);

      final CustomerHistory history = await repo.historyForCustomer(
        customerId,
        limit: null,
      );

      expect(history.recent, hasLength(60));
      expect(history.isWindowed, isFalse);
    });

    test('a customer with no parcels reads as empty', () async {
      final CustomerHistory history = await repo.historyForCustomer(customerId);

      expect(history.isEmpty, isTrue);
      expect(history.recent, isEmpty);
      expect(history.total, 0);
    });
  });
}

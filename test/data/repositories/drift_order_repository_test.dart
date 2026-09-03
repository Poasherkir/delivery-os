import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/data/repositories/drift_order_repository.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late OrderRepository repo;
  late String companyId;
  late String batchId;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();

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
}

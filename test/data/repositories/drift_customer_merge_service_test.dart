import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/customer_merge.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/repositories/drift_customer_merge_service.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/repositories/customer_merge_service.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late CustomerDao dao;
  late CustomerMergeService service;
  late String ownerId;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();
    ownerId = user.id;

    dao = CustomerDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
    service = DriftCustomerMergeService(
      merge: CustomerMerge(database, clock, uuid, 'device-under-test'),
    );
  });

  tearDown(() => database.close());

  test('merging returns the survivor as a domain customer', () async {
    final db.Customer survivor = await dao.create(
      ownerId: ownerId,
      phone: PhoneE164.parse('0550111111'),
      displayName: 'Amine',
    );
    final db.Customer loser = await dao.create(
      ownerId: ownerId,
      phone: PhoneE164.parse('0550222222'),
      displayName: 'Amine (doublon)',
    );

    final Customer result = await service.merge(
      survivorId: survivor.id,
      loserId: loser.id,
    );

    expect(result, isA<Customer>());
    expect(result.id, survivor.id);
    expect(result.displayName, 'Amine');
  });

  test('and the exceptions surface as domain-level failures', () async {
    final db.Customer c = await dao.create(
      ownerId: ownerId,
      phone: PhoneE164.parse('0550111111'),
      displayName: 'Amine',
    );

    await expectLater(
      service.merge(survivorId: c.id, loserId: c.id),
      throwsA(isA<ArgumentError>()),
    );
  });
}

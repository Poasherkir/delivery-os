import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/repositories/drift_address_repository.dart';
import 'package:delivery_os/domain/entities/address.dart';
import 'package:delivery_os/domain/repositories/address_repository.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late AddressRepository repo;
  late String customerId;

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

    customerId =
        (await CustomerDao(
              database: database,
              clock: clock,
              uuid: uuid,
              deviceId: 'device-under-test',
            ).create(
              ownerId: user.id,
              phone: PhoneE164.parse('0550123456'),
              displayName: 'Amine',
            ))
            .id;

    repo = DriftAddressRepository(
      dao: AddressDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
  });

  tearDown(() => database.close());

  Future<Address> add({String? detail, String? label}) => repo.create(
    customerId: customerId,
    wilayaCode: 16,
    communeId: 1601,
    detail: detail,
    label: label,
  );

  test('a typed address lands at tier 0 and is not routable', () async {
    // Invariant 9: a confidence-0 stop is never routed. That is not a defect
    // here — most addresses start this way, and the pin arrives on its own the
    // first time a delivery is confirmed at the door.
    final Address a = await add(detail: 'Bt 12, 3e étage');

    expect(a.confidence, GeoConfidence.none);
    expect(a.isRoutable, isFalse);
    expect(a.detail, 'Bt 12, 3e étage');
    expect(a.communeId, 1601);
    expect(a.isPrimary, isTrue);
  });

  group('an empty detail is null, not an empty string', () {
    test('when the field was left alone', () async {
      expect((await add()).detail, isNull);
    });

    test('and when it holds only whitespace', () async {
      // Two spellings of "nothing here" would each have to be checked
      // everywhere the field is read.
      expect((await add(detail: '   ')).detail, isNull);
    });

    test('but real text is trimmed and kept', () async {
      expect(
        (await add(detail: '  Cité 1000 Logements ')).detail,
        'Cité 1000 Logements',
      );
    });
  });

  test('the primary comes first', () async {
    final Address first = await add(label: 'maison');
    await add(label: 'travail');

    expect((await repo.forCustomer(customerId)).first.id, first.id);
  });

  test('and a customer with no addresses has none, not an error', () async {
    expect(await repo.forCustomer('nobody'), isEmpty);
  });

  test('toString carries neither the detail nor a coordinate', () async {
    // With the phone number, a home address is the most sensitive pair in this
    // system. `Bt 12, 3e étage` in a crash payload is a household's front door.
    final Address a = await add(detail: 'Bt 12, 3e étage');

    expect(a.toString(), isNot(contains('Bt 12')));
    expect(a.toString(), isNot(contains('étage')));
    expect(a.toString(), contains('1601'));
  });
}

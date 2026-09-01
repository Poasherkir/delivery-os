import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/conventions/entity_stamp.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/delivery_attempt_outcome.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

String _id(int n) => '0199a1b2-c3d4-7000-8000-${n.toString().padLeft(12, '0')}';

final String userId = _id(1);
final String companyId = _id(2);
final String batchId = _id(3);
final String customerId = _id(4);
final String addressId = _id(5);
final String orderId = _id(6);

Set<String> _columns(TableInfo<Table, Object?> table) =>
    table.$columns.map((GeneratedColumn<Object?> c) => c.name).toSet();

void main() {
  late AppDatabase db;
  late EntityStamp stamp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    stamp = EntityStamper(
      FixedClock(DateTime.utc(2026, 8, 30, 7, 30)),
    ).forInsert();
    await db.customStatement('PRAGMA foreign_keys = ON');

    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            displayName: const Value('Malik'),
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
          ),
        );
    await db
        .into(db.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: 'Yalidine',
            ownerId: userId,
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
    await db
        .into(db.batches)
        .insert(
          BatchesCompanion.insert(
            id: batchId,
            ownerId: userId,
            companyId: companyId,
            serviceDate: '2026-08-30',
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
    await db
        .into(db.customers)
        .insert(
          CustomersCompanion.insert(
            id: customerId,
            ownerId: userId,
            phoneE164: Value<PhoneE164?>(PhoneE164.parse('0550123456')),
            displayName: 'Amine',
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
    await db
        .into(db.wilayas)
        .insert(
          WilayasCompanion.insert(
            code: const Value<int>(16),
            nameFr: 'Alger',
            nameAr: 'الجزائر',
          ),
        );
    await db
        .into(db.communes)
        .insert(
          CommunesCompanion.insert(
            id: const Value<int>(1601),
            wilayaCode: 16,
            nameFr: 'Bab Ezzouar',
            nameAr: 'باب الزوار',
          ),
        );
    await db
        .into(db.customerAddresses)
        .insert(
          CustomerAddressesCompanion.insert(
            id: addressId,
            ownerId: userId,
            customerId: customerId,
            wilayaCode: 16,
            communeId: 1601,
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
  });

  tearDown(() => db.close());

  Future<void> insertOrder({
    String id = '',
    String tracking = 'YAL-0001',
    OrderStatus status = OrderStatus.pending,
    Centimes cod = const Centimes(400000),
    Centimes commission = const Centimes(30000),
  }) => db
      .into(db.orders)
      .insert(
        OrdersCompanion.insert(
          id: id.isEmpty ? orderId : id,
          ownerId: userId,
          batchId: batchId,
          companyId: companyId,
          trackingNumber: tracking,
          createdAt: stamp.createdAt,
          updatedAt: stamp.updatedAt,
          version: stamp.version,
          customerId: Value<String?>(customerId),
          addressId: Value<String?>(addressId),
          status: Value<OrderStatus>(status),
          codAmount: Value<Centimes>(cod),
          driverCommission: Value<Centimes>(commission),
          companyAmount: Value<Centimes>(cod - commission),
          collectedAmount: Value<Centimes>(cod),
        ),
      );

  group('categories', () {
    test('customers, addresses, batches and orders are owned mutable', () {
      for (final TableInfo<Table, Object?> table in <TableInfo<Table, Object?>>[
        db.customers,
        db.customerAddresses,
        db.batches,
        db.orders,
      ]) {
        expect(
          _columns(table),
          containsAll(<String>[
            'owner_id',
            'created_at',
            'updated_at',
            'deleted_at',
            'version',
          ]),
          reason: table.actualTableName,
        );
      }
    });

    test('attempts and proof are append-only', () {
      for (final TableInfo<Table, Object?> table in <TableInfo<Table, Object?>>[
        db.deliveryAttempts,
        db.proofOfDelivery,
      ]) {
        final Set<String> columns = _columns(table);

        expect(columns, containsAll(<String>['owner_id', 'created_at']));
        // These rows are evidence of what the driver actually did. An
        // updated_at would be a lie and a soft delete would rewrite it.
        expect(columns, isNot(contains('updated_at')));
        expect(columns, isNot(contains('deleted_at')));
        expect(columns, isNot(contains('version')));
      }
    });
  });

  group('geography columns', () {
    test('a recorded fix carries accuracy and a geohash', () {
      // Both tables that record a GPS fix. accuracy_m is gate 3 of the pin
      // promotion ladder and cannot be recovered after the fact.
      for (final TableInfo<Table, Object?> table in <TableInfo<Table, Object?>>[
        db.customerAddresses,
        db.deliveryAttempts,
      ]) {
        expect(
          _columns(table),
          containsAll(<String>[
            'latitude',
            'longitude',
            'geohash',
            'accuracy_m',
          ]),
          reason: table.actualTableName,
        );
      }
    });

    test('proof of delivery has coordinates but no geohash', () {
      // Nothing runs a proximity query on a proof photo.
      final Set<String> columns = _columns(db.proofOfDelivery);

      expect(columns, containsAll(<String>['latitude', 'longitude']));
      expect(columns, isNot(contains('geohash')));
    });

    test('every geo column is nullable, because a pin starts absent', () {
      final Map<String, GeneratedColumn<Object?>> columns =
          <String, GeneratedColumn<Object?>>{
            for (final GeneratedColumn<Object?> c
                in db.customerAddresses.$columns)
              c.name: c,
          };

      for (final String name in <String>[
        'latitude',
        'longitude',
        'geohash',
        'accuracy_m',
      ]) {
        expect(columns[name]!.$nullable, isTrue, reason: name);
      }
    });

    test('confidence defaults to none, which is never routed', () async {
      final CustomerAddress row = await db
          .select(db.customerAddresses)
          .getSingle();

      expect(row.geoConfidence, GeoConfidence.none);
      expect(row.geoConfidence.isRoutable, isFalse);
      expect(row.accuracyM, isNull);
    });
  });

  group('orders', () {
    test('money is seven integer columns, signs intact', () async {
      await insertOrder(
        cod: const Centimes(400000),
        commission: const Centimes(30000),
      );

      final QueryRow raw = await db
          .customSelect(
            'SELECT product_value, cod_amount, delivery_fee, company_amount, '
            'driver_commission, other_fees, collected_amount FROM orders',
          )
          .getSingle();

      expect(raw.read<int>('cod_amount'), 400000);
      expect(raw.read<int>('driver_commission'), 30000);
      // The residual, derived by subtraction rather than rounded separately.
      expect(raw.read<int>('company_amount'), 370000);
      expect(
        raw.read<int>('company_amount') + raw.read<int>('driver_commission'),
        raw.read<int>('collected_amount'),
      );
    });

    test('a negative amount survives, for adjustments', () async {
      await insertOrder(cod: const Centimes(-1250), commission: Centimes.zero);

      final Order row = await db.select(db.orders).getSingle();
      expect(row.codAmount, const Centimes(-1250));
    });

    test('status and delivery type are TEXT by name', () async {
      await insertOrder(status: OrderStatus.returnedToAgency);

      final QueryRow raw = await db
          .customSelect('SELECT status, delivery_type FROM orders')
          .getSingle();

      expect(raw.read<String>('status'), 'returnedToAgency');
      expect(raw.read<String>('delivery_type'), 'home');
    });

    test('defaults are pending and home', () async {
      await insertOrder();
      final Order row = await db.select(db.orders).getSingle();

      expect(row.status, OrderStatus.pending);
      expect(row.deliveryType, DeliveryType.home);
      expect(row.attemptCount, 0);
      expect(row.paymentRuleVersion, isNull);
    });

    test('a tracking number is unique per company, not globally', () async {
      await insertOrder();

      // The same number under the same company is rejected.
      expect(() => insertOrder(id: _id(7)), throwsA(isA<SqliteException>()));
    });

    test('an order can exist before its customer does', () async {
      // M1 imports from a manifest before the customer record exists, and the
      // entry flow must not block on that.
      await db
          .into(db.orders)
          .insert(
            OrdersCompanion.insert(
              id: _id(8),
              ownerId: userId,
              batchId: batchId,
              companyId: companyId,
              trackingNumber: 'YAL-0002',
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          );

      final Order row = await (db.select(
        db.orders,
      )..where((o) => o.id.equals(_id(8)))).getSingle();
      expect(row.customerId, isNull);
      expect(row.addressId, isNull);
    });
  });

  group('batches', () {
    test('one batch per company per day', () async {
      expect(
        () => db
            .into(db.batches)
            .insert(
              BatchesCompanion.insert(
                id: _id(9),
                ownerId: userId,
                companyId: companyId,
                serviceDate: '2026-08-30',
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
                version: stamp.version,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('the service date is stored as a calendar date', () async {
      final QueryRow raw = await db
          .customSelect('SELECT service_date, status FROM batches')
          .getSingle();

      expect(raw.read<String>('service_date'), '2026-08-30');
      expect(raw.read<String>('status'), 'open');
    });
  });

  group('customers', () {
    test('the phone is unique per driver', () async {
      expect(
        () => db
            .into(db.customers)
            .insert(
              CustomersCompanion.insert(
                id: _id(10),
                ownerId: userId,
                // A different spelling of the same number.
                phoneE164: Value<PhoneE164?>(
                  PhoneE164.parse('+213 550 123 456'),
                ),
                displayName: 'Someone else',
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
                version: stamp.version,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('the risk flag is TEXT and defaults to none', () async {
      final QueryRow raw = await db
          .customSelect('SELECT risk_flag FROM customers')
          .getSingle();
      expect(raw.read<String>('risk_flag'), 'none');

      final Customer row = await db.select(db.customers).getSingle();
      expect(row.riskFlag, CustomerRiskFlag.none);
      expect(row.riskFlag.needsAttention, isFalse);
    });
  });

  group('delivery attempts', () {
    Future<void> attempt({
      required int number,
      DeliveryAttemptOutcome outcome = DeliveryAttemptOutcome.noAnswer,
      String id = '',
    }) => db
        .into(db.deliveryAttempts)
        .insert(
          DeliveryAttemptsCompanion.insert(
            id: id.isEmpty ? _id(20 + number) : id,
            ownerId: userId,
            orderId: orderId,
            attemptNo: number,
            outcome: outcome,
            occurredAt: stamp.createdAt,
            createdAt: stamp.createdAt,
          ),
        );

    setUp(insertOrder);

    test('records what happened at the door, as TEXT', () async {
      await attempt(number: 1, outcome: DeliveryAttemptOutcome.wrongAddress);

      final QueryRow raw = await db
          .customSelect('SELECT outcome FROM delivery_attempts')
          .getSingle();
      expect(raw.read<String>('outcome'), 'wrongAddress');
    });

    test('an order accumulates attempts across days', () async {
      // Returns are 15-25% of this business; a parcel is attempted more than
      // once and the history is what explains the money.
      await attempt(number: 1, outcome: DeliveryAttemptOutcome.noAnswer);
      await attempt(number: 2, outcome: DeliveryAttemptOutcome.postponed);
      await attempt(number: 3, outcome: DeliveryAttemptOutcome.delivered);

      expect(await db.select(db.deliveryAttempts).get(), hasLength(3));
    });

    test('an attempt number cannot repeat on one order', () async {
      await attempt(number: 1);

      expect(
        () => attempt(number: 1, id: _id(30)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('occurred_at is distinct from created_at', () async {
      // A driver in a dead zone records the attempt later. created_at is the
      // write time; occurred_at is the truth.
      final Set<String> columns = _columns(db.deliveryAttempts);
      expect(columns, containsAll(<String>['occurred_at', 'created_at']));
    });

    test('deleting the order takes its attempts with it', () async {
      await attempt(number: 1);
      await (db.delete(db.orders)..where((o) => o.id.equals(orderId))).go();

      expect(await db.select(db.deliveryAttempts).get(), isEmpty);
    });
  });

  test('proof of delivery records where the driver was', () async {
    await insertOrder();
    await db
        .into(db.proofOfDelivery)
        .insert(
          ProofOfDeliveryCompanion.insert(
            id: _id(40),
            ownerId: userId,
            orderId: orderId,
            capturedAt: stamp.createdAt,
            createdAt: stamp.createdAt,
            latitude: const Value<double>(36.7538),
            longitude: const Value<double>(3.0588),
          ),
        );

    final DeliveryProof row = await db.select(db.proofOfDelivery).getSingle();
    expect(row.latitude, 36.7538);
    expect(row.uploaded, isFalse);
    expect(row.signaturePath, isNull);
  });
}

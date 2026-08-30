import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/conventions/entity_stamp.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/ledger_enums.dart';
import 'package:delivery_os/domain/value_objects/route_status.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

String _id(int n) => '0199a1b2-c3d4-7000-8000-${n.toString().padLeft(12, '0')}';

final String userId = _id(1);
final String companyId = _id(2);
final String batchId = _id(3);
final String orderId = _id(4);
final String routeId = _id(5);
final String settlementId = _id(6);

Set<String> _columns(TableInfo<Table, Object?> table) =>
    table.$columns.map((GeneratedColumn<Object?> c) => c.name).toSet();

const Set<String> _auditColumns = <String>{
  'owner_id',
  'created_at',
  'updated_at',
  'deleted_at',
  'version',
};

void main() {
  late AppDatabase db;
  late EntityStamp stamp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    stamp = EntityStamper(
      FixedClock(DateTime.utc(2026, 8, 30, 18, 0)),
    ).forInsert();
    await db.customStatement('PRAGMA foreign_keys = ON');

    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            displayName: 'Malik',
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
        .into(db.orders)
        .insert(
          OrdersCompanion.insert(
            id: orderId,
            ownerId: userId,
            batchId: batchId,
            companyId: companyId,
            trackingNumber: 'YAL-0001',
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
    await db
        .into(db.routes)
        .insert(
          RoutesCompanion.insert(
            id: routeId,
            ownerId: userId,
            serviceDate: '2026-08-30',
            createdAt: stamp.createdAt,
            updatedAt: stamp.updatedAt,
            version: stamp.version,
          ),
        );
  });

  tearDown(() => db.close());

  group('invariant 3, the exceptions', () {
    test('route_stops mutates but does not version or tombstone', () {
      final Set<String> columns = _columns(db.routeStops);

      expect(columns, containsAll(<String>['created_at', 'updated_at']));
      // Stops belong to their route, and re-optimization replaces them
      // wholesale — there is nothing to tombstone and no version to reconcile.
      expect(columns, isNot(contains('version')));
      expect(columns, isNot(contains('deleted_at')));
      expect(columns, isNot(contains('owner_id')));
    });

    test('matrix_cache carries no audit column at all', () {
      // The strictest category. Purgeable: droppable at any moment with zero
      // data loss, because everything in it can be refetched.
      final Set<String> columns = _columns(db.matrixCache);

      for (final String audit in _auditColumns) {
        expect(columns, isNot(contains(audit)), reason: audit);
      }
      // fetched_at only looks like one. It is functional state — the age the
      // cache is expired against — not a note about when a row was written.
      expect(columns, contains('fetched_at'));
    });

    test('outbox is local machinery, not append-only', () {
      final Set<String> columns = _columns(db.outbox);

      // It mutates during a sync pass, so it is not append-only...
      expect(
        columns,
        containsAll(<String>['attempts', 'last_error', 'synced_at']),
      );
      // ...but it is not an owned entity either: it never syncs, and
      // tombstoning a queue row is meaningless.
      expect(columns, isNot(contains('version')));
      expect(columns, isNot(contains('deleted_at')));
      expect(columns, isNot(contains('owner_id')));
      expect(columns, contains('created_at'));
    });

    test('a synced outbox row is hard-deleted, not tombstoned', () async {
      await db
          .into(db.outbox)
          .insert(
            OutboxCompanion.insert(
              id: _id(10),
              entityType: 'order',
              entityId: orderId,
              operation: OutboxOperation.command,
              payload: '{"collected":640000}',
              deviceId: 'device-1',
              createdAt: stamp.createdAt,
              syncedAt: Value<DateTime?>(stamp.createdAt),
            ),
          );

      await db.delete(db.outbox).go();
      expect(await db.select(db.outbox).get(), isEmpty);
    });
  });

  group('routes', () {
    test('has exactly three states', () {
      expect(RouteStatus.values, <RouteStatus>[
        RouteStatus.draft,
        RouteStatus.active,
        RouteStatus.completed,
      ]);
      expect(RouteStatus.active.isDriving, isTrue);
      expect(RouteStatus.draft.isDriving, isFalse);
    });

    test('defaults to draft, stored as TEXT', () async {
      final QueryRow raw = await db
          .customSelect('SELECT status FROM routes')
          .getSingle();
      expect(raw.read<String>('status'), 'draft');
    });

    test(
      'one stop per sequence position, and stops die with the route',
      () async {
        Future<void> stop(int sequence, String id) => db
            .into(db.routeStops)
            .insert(
              RouteStopsCompanion.insert(
                id: id,
                routeId: routeId,
                orderId: orderId,
                sequence: sequence,
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
              ),
            );

        await stop(1, _id(20));
        expect(() => stop(1, _id(21)), throwsA(isA<SqliteException>()));

        await stop(2, _id(22));
        await db.delete(db.routes).go();
        expect(await db.select(db.routeStops).get(), isEmpty);
      },
    );
  });

  group('settlements are immutable', () {
    Future<void> settle({String id = '', String batch = ''}) => db
        .into(db.dailySettlements)
        .insert(
          DailySettlementsCompanion.insert(
            id: id.isEmpty ? settlementId : id,
            ownerId: userId,
            batchId: batch.isEmpty ? batchId : batch,
            serviceDate: '2026-08-30',
            ordersTotal: 15,
            ordersDelivered: 13,
            ordersFailed: 2,
            ordersPending: 0,
            expectedCollection: const Centimes(6000000),
            actualCollection: const Centimes(5850000),
            companyAmount: const Centimes(5460000),
            driverGross: const Centimes(390000),
            expensesAllocated: const Centimes(120000),
            driverNet: const Centimes(270000),
            ruleVersion: 3,
            snapshot: '{"version":1,"orders":[]}',
            contentHash: 'a' * 64,
            confirmedAt: stamp.createdAt,
            createdAt: stamp.createdAt,
          ),
        );

    test('append-only: no updated_at, no version, no soft delete', () {
      final Set<String> columns = _columns(db.dailySettlements);

      expect(columns, containsAll(<String>['owner_id', 'created_at']));
      expect(columns, isNot(contains('updated_at')));
      expect(columns, isNot(contains('deleted_at')));
      expect(columns, isNot(contains('version')));
      // rule_version is business data — which payment rule produced these
      // numbers — not the audit column.
      expect(columns, contains('rule_version'));
    });

    test('one settlement per batch', () async {
      await settle();
      expect(() => settle(id: _id(30)), throwsA(isA<SqliteException>()));
    });

    test(
      'the snapshot is raw JSON and survives a shape it never knew',
      () async {
        // The whole point of freezing it. If this deserialized through a live
        // model, a refactor would silently rewrite the history a driver takes to
        // an agency to prove what they are owed.
        const String future =
            '{"version":42,"orders":[{"id":"x","invented_field":true}],'
            '"totals":{"unknown":1}}';

        await db
            .into(db.dailySettlements)
            .insert(
              DailySettlementsCompanion.insert(
                id: _id(31),
                ownerId: userId,
                batchId: batchId,
                serviceDate: '2026-08-30',
                ordersTotal: 0,
                ordersDelivered: 0,
                ordersFailed: 0,
                ordersPending: 0,
                expectedCollection: Centimes.zero,
                actualCollection: Centimes.zero,
                companyAmount: Centimes.zero,
                driverGross: Centimes.zero,
                expensesAllocated: Centimes.zero,
                driverNet: Centimes.zero,
                ruleVersion: 1,
                snapshot: future,
                contentHash: 'b' * 64,
                confirmedAt: stamp.createdAt,
                createdAt: stamp.createdAt,
              ),
            );

        expect(
          (await db.select(db.dailySettlements).getSingle()).snapshot,
          future,
        );
      },
    );

    test('a correction is a new row, and it can be negative', () async {
      await settle();
      await db
          .into(db.settlementAdjustments)
          .insert(
            SettlementAdjustmentsCompanion.insert(
              id: _id(32),
              ownerId: userId,
              settlementId: settlementId,
              amount: const Centimes(-15000),
              reason: 'Agency recounted; 150 DA short.',
              createdAt: stamp.createdAt,
            ),
          );

      final SettlementAdjustment row = await db
          .select(db.settlementAdjustments)
          .getSingle();
      expect(row.amount, const Centimes(-15000));
      // The original settlement is untouched.
      expect(
        (await db.select(db.dailySettlements).getSingle()).driverNet,
        const Centimes(270000),
      );
    });
  });

  group('remittances are mutable, unlike settlements', () {
    test('they carry all five audit columns', () {
      // Hand-entered cash, where typos are certain — a driver must be able to
      // fix 45 000 to 45 500 thirty seconds later. The control is the audit
      // trail, not immutability.
      expect(_columns(db.remittances), containsAll(_auditColumns));
    });

    test(
      'a correction bumps the version rather than being forbidden',
      () async {
        await db
            .into(db.remittances)
            .insert(
              RemittancesCompanion.insert(
                id: _id(40),
                ownerId: userId,
                companyId: companyId,
                amount: const Centimes(4500000),
                method: RemittanceMethod.cash,
                remittedAt: stamp.createdAt,
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
                version: stamp.version,
              ),
            );

        final EntityStamp corrected = EntityStamper(
          FixedClock(DateTime.utc(2026, 8, 30, 18, 1)),
        ).forUpdate(stamp);

        await (db.update(
          db.remittances,
        )..where((t) => t.id.equals(_id(40)))).write(
          RemittancesCompanion(
            amount: const Value<Centimes>(Centimes(4550000)),
            updatedAt: Value<DateTime>(corrected.updatedAt),
            version: Value<int>(corrected.version),
          ),
        );

        final Remittance row = await db.select(db.remittances).getSingle();
        expect(row.amount, const Centimes(4550000));
        expect(row.version, 2);
      },
    );

    test('covers a span of days rather than one batch', () {
      // A driver holds cash for two or three days and then settles several
      // batches at once.
      final Set<String> columns = _columns(db.remittances);
      expect(columns, containsAll(<String>['covers_from', 'covers_to']));
      expect(columns, isNot(contains('batch_id')));
    });
  });

  group('audit_logs', () {
    test('is append-only and stores both sides as raw JSON', () async {
      final Set<String> columns = _columns(db.auditLogs);
      expect(columns, isNot(contains('updated_at')));
      expect(columns, isNot(contains('deleted_at')));

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: _id(50),
              ownerId: userId,
              entityType: 'remittance',
              entityId: _id(40),
              action: 'remittance.amend',
              occurredAt: stamp.createdAt,
              createdAt: stamp.createdAt,
              before: const Value<String?>('{"amount":4500000}'),
              after: const Value<String?>('{"amount":4550000}'),
            ),
          );

      final AuditLog row = await db.select(db.auditLogs).getSingle();
      expect(row.before, '{"amount":4500000}');
      expect(row.after, '{"amount":4550000}');
    });

    test('a creation has no before and a deletion has no after', () async {
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: _id(51),
              ownerId: userId,
              entityType: 'order',
              entityId: orderId,
              action: 'order.create',
              occurredAt: stamp.createdAt,
              createdAt: stamp.createdAt,
              after: const Value<String?>('{"id":"x"}'),
            ),
          );

      expect((await db.select(db.auditLogs).getSingle()).before, isNull);
    });
  });

  group('expenses', () {
    test('belong to a business day, not to a batch', () async {
      // A tank of fuel covers every company the driver worked that day.
      final Set<String> columns = _columns(db.expenses);
      expect(columns, contains('service_date'));
      expect(columns, isNot(contains('batch_id')));

      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: _id(60),
              ownerId: userId,
              serviceDate: '2026-08-30',
              category: ExpenseCategory.fuel,
              amount: const Centimes(120000),
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          );

      final QueryRow raw = await db
          .customSelect('SELECT category, amount FROM expenses')
          .getSingle();
      expect(raw.read<String>('category'), 'fuel');
      expect(raw.read<int>('amount'), 120000);
    });
  });

  test('the matrix cache is keyed by point hash and provider', () async {
    Future<void> cache(String provider, String id) => db
        .into(db.matrixCache)
        .insert(
          MatrixCacheCompanion.insert(
            id: id,
            pointHash: 'c' * 64,
            durations: '[[0,420],[420,0]]',
            distances: '[[0,3200],[3200,0]]',
            provider: provider,
            fetchedAt: stamp.createdAt,
          ),
        );

    await cache('mapbox', _id(70));
    // The same coordinates answered by a different provider are a different
    // result, so both can be cached.
    await cache('haversine', _id(71));
    expect(await db.select(db.matrixCache).get(), hasLength(2));

    expect(() => cache('mapbox', _id(72)), throwsA(isA<SqliteException>()));
  });
}

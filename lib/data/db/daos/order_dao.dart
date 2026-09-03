import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/state/order_state_machine.dart';
import '../../../domain/state/order_status.dart';
import '../../../domain/value_objects/centimes.dart';
import '../../../domain/value_objects/delivery_type.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../app_database.dart';
import '../conventions/entity_stamp.dart';

/// Reads and writes orders.
///
/// **Status is never assigned here.** The initial value comes from
/// `OrderStateMachine.initial`, which is invariant 6 applied to the one write
/// that has no previous state to transition from. The column's own default is
/// left as a backstop for a row this app did not write; nothing in `create`
/// relies on it, so the state machine stays the single place the answer lives.
///
/// **`payment_rule_version` is written null**, deliberately. Invariant 8 pins
/// it at creation — but there is no rule to pin before M3, and writing a
/// version number for a rule that does not exist would be inventing the exact
/// business data a settlement is later reproduced from. Null is the honest
/// record of "entered before rules existed", and the column is nullable for
/// this reason.
///
/// Every money column except `cod_amount` is left at its default of zero. They
/// are not unknown, they are not yet computed: the money engine fills them at
/// M3 from the rule, and a guess written here would be indistinguishable from
/// a computed value the day it matters.
final class OrderDao {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory OrderDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => OrderDao._(database, clock, uuid, deviceId);

  const OrderDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  /// The order carrying this tracking number for this company, or null.
  ///
  /// Scoped to the company because `(owner_id, company_id, tracking_number)` is
  /// the unique key and not `tracking_number` alone: two companies can and do
  /// hand out the same number, so a global check would reject a real parcel.
  Future<Order?> findByTracking({
    required String ownerId,
    required String companyId,
    required String trackingNumber,
  }) {
    return (_db.select(_db.orders)
          ..where(
            ($OrdersTable o) =>
                o.ownerId.equals(ownerId) &
                o.companyId.equals(companyId) &
                o.trackingNumber.equals(trackingNumber) &
                o.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Order?> byId(String id) => (_db.select(
    _db.orders,
  )..where(($OrdersTable o) => o.id.equals(id))).getSingleOrNull();

  /// A batch's live orders, newest first.
  ///
  /// Newest first because the list is read to confirm what was just entered.
  /// The id is a UUIDv7, so `ORDER BY id DESC` is creation order without a
  /// second column — and unlike `created_at` it cannot tie.
  Future<List<Order>> forBatch(String batchId) {
    return (_db.select(_db.orders)
          ..where(
            ($OrdersTable o) =>
                o.batchId.equals(batchId) & o.deletedAt.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$OrdersTable>>[
            ($OrdersTable o) =>
                OrderingTerm(expression: o.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Every live parcel filed under a service date, newest first.
  ///
  /// One query, five tables. The list shows a customer's name and a commune's
  /// name, and fetching those per row would be several queries a parcel on the
  /// screen a driver opens most — a batch of fifteen would be sixty round trips
  /// for one scroll.
  ///
  /// Left joins on customer, address and commune, because all three are
  /// legitimately absent: a parcel can be entered before anyone is attached to
  /// it. Inner joins on batch and company, because neither can be.
  ///
  /// Ordered by order id descending. UUIDv7 sorts by creation and cannot tie,
  /// which `created_at` can when fifteen parcels are entered inside one
  /// millisecond.
  Future<List<OrderSummaryRow>> summariesForDate({
    required String ownerId,
    required String serviceDate,
  }) async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT o.id, o.tracking_number, o.status, o.delivery_type, '
          'o.cod_amount, cmp.name AS company_name, '
          'cus.display_name AS customer_name, '
          'com.name_fr AS commune_fr, com.name_ar AS commune_ar, '
          'addr.detail AS address_detail '
          'FROM orders o '
          'JOIN batches b ON b.id = o.batch_id '
          'JOIN companies cmp ON cmp.id = o.company_id '
          'LEFT JOIN customers cus ON cus.id = o.customer_id '
          'LEFT JOIN customer_addresses addr ON addr.id = o.address_id '
          'LEFT JOIN communes com ON com.id = addr.commune_id '
          'WHERE o.owner_id = ?1 AND b.service_date = ?2 '
          'AND o.deleted_at IS NULL '
          'ORDER BY o.id DESC',
          variables: <Variable<Object>>[
            Variable<String>(ownerId),
            Variable<String>(serviceDate),
          ],
          readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
            _db.orders,
            _db.batches,
            _db.companies,
            _db.customers,
            _db.customerAddresses,
            _db.communes,
          },
        )
        .get();

    return rows
        .map(
          (QueryRow r) => (
            id: r.read<String>('id'),
            trackingNumber: r.read<String>('tracking_number'),
            // Read back through the same converters the columns are written
            // with. A raw string here would be a second place that knows how a
            // status is spelled, and it would not fail when they disagreed.
            status: _db.orders.status.converter.fromSql(
              r.read<String>('status'),
            ),
            deliveryType: _db.orders.deliveryType.converter.fromSql(
              r.read<String>('delivery_type'),
            ),
            codAmount: Centimes(r.read<int>('cod_amount')),
            companyName: r.read<String>('company_name'),
            customerName: r.read<String?>('customer_name'),
            communeNameFr: r.read<String?>('commune_fr'),
            communeNameAr: r.read<String?>('commune_ar'),
            addressDetail: r.read<String?>('address_detail'),
          ),
        )
        .toList();
  }

  /// Adds an order.
  ///
  /// [customerId] and [addressId] are nullable because a manifest can name a
  /// parcel before it names a person, and M1's entry flow must not block on
  /// that. The order is the thing the driver is holding; the customer record
  /// catches up.
  Future<Order> create({
    required String ownerId,
    required String batchId,
    required String companyId,
    required String trackingNumber,
    String? customerId,
    String? addressId,
    Centimes codAmount = Centimes.zero,
    DeliveryType deliveryType = DeliveryType.home,
    String? notes,
  }) {
    final String id = _uuid.next();
    final EntityStamp stamp = EntityStamper(_clock).forInsert();

    return _mutate<Order>(
      entityId: id,
      operation: OutboxOperation.create,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'batch_id': batchId,
        'company_id': companyId,
        'tracking_number': trackingNumber,
        'customer_id': ?customerId,
        'address_id': ?addressId,
        'cod_amount': codAmount.value,
        'delivery_type': deliveryType.name,
        'status': OrderStateMachine.initial.name,
        'notes': ?notes,
      },
      write: () => _db
          .into(_db.orders)
          .insertReturning(
            OrdersCompanion.insert(
              id: id,
              ownerId: ownerId,
              batchId: batchId,
              companyId: companyId,
              trackingNumber: trackingNumber,
              customerId: Value<String?>(customerId),
              addressId: Value<String?>(addressId),
              codAmount: Value<Centimes>(codAmount),
              deliveryType: Value<DeliveryType>(deliveryType),
              // Invariant 6: the initial state comes from the state machine,
              // not from a literal and not from the column default.
              status: Value<OrderStatus>(OrderStateMachine.initial),
              notes: Value<String?>(notes),
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          ),
    );
  }

  /// Soft-deletes an order.
  ///
  /// The driver mistyped a tracking number and wants the row gone. Soft,
  /// because the unique key is on live rows only once `deleted_at` is checked —
  /// and because an order is the thing a settlement is built from, so it is
  /// never actually destroyed.
  Future<void> softDelete(Order current) {
    final EntityStamp stamp = EntityStamper(
      _clock,
    ).forSoftDelete(current.stamp);

    return _mutate<void>(
      entityId: current.id,
      operation: OutboxOperation.delete,
      at: stamp.updatedAt,
      payload: const <String, Object?>{},
      write: () async {
        await (_db.update(
          _db.orders,
        )..where(($OrdersTable o) => o.id.equals(current.id))).write(
          OrdersCompanion(
            deletedAt: Value<DateTime?>(stamp.deletedAt),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
      },
    );
  }

  /// Invariant 5, in one place. See `CustomerDao._mutate`.
  Future<T> _mutate<T>({
    required String entityId,
    required OutboxOperation operation,
    required DateTime at,
    required Map<String, Object?> payload,
    required Future<T> Function() write,
  }) {
    return _db.transaction(() async {
      final T result = await write();

      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              id: _uuid.next(),
              entityType: 'order',
              entityId: entityId,
              operation: operation,
              payload: jsonEncode(payload),
              deviceId: _deviceId,
              createdAt: at,
            ),
          );

      return result;
    });
  }
}

/// One joined row, before it crosses into `domain/`.
///
/// A record rather than a class: it exists for the length of one mapping and
/// naming it as a type would suggest it is a thing the app has.
typedef OrderSummaryRow = ({
  String id,
  String trackingNumber,
  OrderStatus status,
  DeliveryType deliveryType,
  Centimes codAmount,
  String companyName,
  String? customerName,
  String? communeNameFr,
  String? communeNameAr,
  String? addressDetail,
});

/// The audit columns as an [EntityStamp], so a DAO never assembles one by hand.
extension OrderStamp on Order {
  EntityStamp get stamp => EntityStamp(
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
  );
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../core/utils/uuid_v7.dart';
import '../../domain/value_objects/ledger_enums.dart';
import 'app_database.dart';
import 'conventions/entity_stamp.dart';
import 'daos/address_dao.dart' show AddressStamp;
import 'daos/customer_dao.dart' show CustomerStamp;
import 'daos/order_dao.dart' show OrderStamp;

/// Merges one customer into another.
///
/// Lives outside `daos/`, deliberately, the same way `AppBootstrap` and
/// `GeoLoader` do: those DAOs are shaped one entity at a time, and this
/// touches three — `customers`, `customer_addresses`, `orders` — inside a
/// single transaction that has to see all of them consistently. A method
/// bolted onto `CustomerDao` reaching into two other tables would blur the
/// exact boundary the DAO split exists to keep.
///
/// **Every live order and address on the loser moves onto the survivor.**
/// Where the two hold an address at the same door — same commune, same
/// detail, the identical key `OrderEntryController._resolveAddress` already
/// uses to avoid double-entering one — only the higher-confidence pin
/// survives, and any order that pointed at the one retired is repointed to
/// the one kept. A tie keeps the survivor's own row: nothing distinguishes
/// them, and the survivor's is already where its own orders point.
///
/// **Writes exactly one outbox row for the whole operation**, not one per row
/// touched. This is `OutboxOperation.command` for the reason it exists: a
/// merge is one intent, and replaying it at V2 means re-running the merge
/// server-side against the same two ids, not replaying a pile of individual
/// row patches that could partially apply. The outbox guard's scan is scoped
/// to `daos/` and does not see this file, the same way it does not see
/// bootstrap or the geo loader — and like both of those, the reason is
/// written down here rather than left for someone to rediscover.
final class CustomerMerge {
  const CustomerMerge(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  /// Merges [loserId] into [survivorId] and returns the (unchanged) survivor
  /// row, re-read after the merge so a caller sees the same value whichever
  /// way it asks for it.
  Future<Customer> run({
    required String survivorId,
    required String loserId,
  }) async {
    // Deliberately outside `_db.transaction()`, and the method is `async` so
    // it still throws through the Future rather than synchronously — a bare
    // `throw` in a non-`async` function that returns a Future escapes before
    // any `await` or `expectLater` can catch it, which is not the contract a
    // `Future<Customer> run(...)` signature promises its callers.
    if (survivorId == loserId) {
      throw ArgumentError.value(
        loserId,
        'loserId',
        'cannot merge a customer into itself',
      );
    }

    return _db.transaction(() async {
      final Customer survivor = await _requireLive(survivorId, 'survivorId');
      final Customer loser = await _requireLive(loserId, 'loserId');

      final Map<String, String> redirectAddress = await _reconcileAddresses(
        survivorId: survivorId,
        loserId: loserId,
      );
      await _moveOrders(
        survivorId: survivorId,
        loserId: loserId,
        redirectAddress: redirectAddress,
      );
      await _ensureOnePrimary(survivorId);
      await _softDeleteLoser(loser);
      await _queueCommand(survivorId: survivorId, loserId: loserId);

      return survivor;
    });
  }

  Future<Customer> _requireLive(String id, String argumentName) async {
    final Customer? row = await (_db.select(
      _db.customers,
    )..where(($CustomersTable c) => c.id.equals(id))).getSingleOrNull();

    if (row == null || row.deletedAt != null) {
      throw StateError('customer $id ($argumentName) no longer exists');
    }
    return row;
  }

  Future<List<CustomerAddress>> _liveAddresses(String customerId) {
    return (_db.select(_db.customerAddresses)..where(
          ($CustomerAddressesTable a) =>
              a.customerId.equals(customerId) & a.deletedAt.isNull(),
        ))
        .get();
  }

  /// Reassigns and collapses addresses. Returns a map from every retired
  /// address id to the address id that replaced it, so [_moveOrders] can
  /// repoint anything that pointed at one.
  Future<Map<String, String>> _reconcileAddresses({
    required String survivorId,
    required String loserId,
  }) async {
    final List<CustomerAddress> loserAddresses = await _liveAddresses(loserId);
    final List<CustomerAddress> survivorAddresses = await _liveAddresses(
      survivorId,
    );

    // Same key `OrderEntryController._resolveAddress` uses: commune and
    // detail. Not label, which is a nickname rather than part of where the
    // door is; not wilaya, which a commune id already implies.
    final Map<(int, String?), CustomerAddress> byDoor =
        <(int, String?), CustomerAddress>{
          for (final CustomerAddress a in survivorAddresses)
            (a.communeId, a.detail): a,
        };

    final Map<String, String> redirect = <String, String>{};
    final Set<String> retire = <String>{};

    for (final CustomerAddress incoming in loserAddresses) {
      final (int, String?) key = (incoming.communeId, incoming.detail);
      final CustomerAddress? atThatDoor = byDoor[key];

      if (atThatDoor == null) {
        await _reassignAddress(incoming, newCustomerId: survivorId);
        byDoor[key] = incoming;
        continue;
      }

      if (incoming.geoConfidence.tier > atThatDoor.geoConfidence.tier) {
        // The incoming pin is the better evidence for this door. It becomes
        // the record; the survivor's weaker duplicate is retired.
        await _reassignAddress(incoming, newCustomerId: survivorId);
        redirect[atThatDoor.id] = incoming.id;
        retire.add(atThatDoor.id);
        byDoor[key] = incoming;
      } else {
        // Equal or better already on the survivor, or a tie. The survivor's
        // row is not the evidence being lost, so it is what stays.
        redirect[incoming.id] = atThatDoor.id;
        retire.add(incoming.id);
      }
    }

    for (final String id in retire) {
      await _retireAddress(id);
    }

    return redirect;
  }

  /// Moves an address onto [newCustomerId], demoted from primary. Every
  /// address a merge brings in loses its primary flag unconditionally —
  /// [_ensureOnePrimary] derives the single survivor at the end, which is
  /// simpler and safer than trying to prefer one incoming primary over
  /// another when both records could have had one.
  Future<void> _reassignAddress(
    CustomerAddress address, {
    required String newCustomerId,
  }) {
    final EntityStamp stamp = EntityStamper(_clock).forUpdate(address.stamp);
    return (_db.update(
      _db.customerAddresses,
    )..where(($CustomerAddressesTable a) => a.id.equals(address.id))).write(
      CustomerAddressesCompanion(
        customerId: Value<String>(newCustomerId),
        isPrimary: const Value<bool>(false),
        updatedAt: Value<DateTime>(stamp.updatedAt),
        version: Value<int>(stamp.version),
      ),
    );
  }

  Future<void> _retireAddress(String id) async {
    final CustomerAddress row = await (_db.select(
      _db.customerAddresses,
    )..where(($CustomerAddressesTable a) => a.id.equals(id))).getSingle();
    final EntityStamp stamp = EntityStamper(_clock).forSoftDelete(row.stamp);

    await (_db.update(
      _db.customerAddresses,
    )..where(($CustomerAddressesTable a) => a.id.equals(id))).write(
      CustomerAddressesCompanion(
        deletedAt: Value<DateTime?>(stamp.deletedAt),
        isPrimary: const Value<bool>(false),
        updatedAt: Value<DateTime>(stamp.updatedAt),
        version: Value<int>(stamp.version),
      ),
    );
  }

  /// If the reconciliation above left the survivor with live addresses and
  /// none of them primary — every incoming address arrives demoted, and the
  /// survivor's own primary can itself have been the one retired — promotes
  /// the oldest. The exact rule `AddressDao.softDelete` already uses when a
  /// deleted primary needs a successor.
  Future<void> _ensureOnePrimary(String survivorId) async {
    final List<CustomerAddress> live = await _liveAddresses(survivorId);
    if (live.isEmpty || live.any((CustomerAddress a) => a.isPrimary)) {
      return;
    }

    final CustomerAddress oldest = live.reduce(
      (CustomerAddress a, CustomerAddress b) =>
          a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    final EntityStamp stamp = EntityStamper(_clock).forUpdate(oldest.stamp);
    await (_db.update(
      _db.customerAddresses,
    )..where(($CustomerAddressesTable a) => a.id.equals(oldest.id))).write(
      CustomerAddressesCompanion(
        isPrimary: const Value<bool>(true),
        updatedAt: Value<DateTime>(stamp.updatedAt),
        version: Value<int>(stamp.version),
      ),
    );
  }

  /// Moves every live order off the loser, repointing `address_id` through
  /// [redirectAddress] where the address it pointed at was retired — and
  /// repoints the survivor's *own* existing orders the same way, for the
  /// case where the loser's pin displaced an address the survivor's orders
  /// already pointed at.
  Future<void> _moveOrders({
    required String survivorId,
    required String loserId,
    required Map<String, String> redirectAddress,
  }) async {
    final List<Order> loserOrders =
        await (_db.select(_db.orders)..where(
              ($OrdersTable o) =>
                  o.customerId.equals(loserId) & o.deletedAt.isNull(),
            ))
            .get();

    for (final Order order in loserOrders) {
      final EntityStamp stamp = EntityStamper(_clock).forUpdate(order.stamp);
      final String? newAddressId = order.addressId == null
          ? null
          : (redirectAddress[order.addressId] ?? order.addressId);

      await (_db.update(
        _db.orders,
      )..where(($OrdersTable o) => o.id.equals(order.id))).write(
        OrdersCompanion(
          customerId: Value<String>(survivorId),
          addressId: Value<String?>(newAddressId),
          updatedAt: Value<DateTime>(stamp.updatedAt),
          version: Value<int>(stamp.version),
        ),
      );
    }

    if (redirectAddress.isEmpty) {
      return;
    }
    for (final MapEntry<String, String> entry in redirectAddress.entries) {
      final List<Order> affected =
          await (_db.select(_db.orders)..where(
                ($OrdersTable o) =>
                    o.customerId.equals(survivorId) &
                    o.addressId.equals(entry.key) &
                    o.deletedAt.isNull(),
              ))
              .get();

      for (final Order order in affected) {
        final EntityStamp stamp = EntityStamper(_clock).forUpdate(order.stamp);
        await (_db.update(
          _db.orders,
        )..where(($OrdersTable o) => o.id.equals(order.id))).write(
          OrdersCompanion(
            addressId: Value<String?>(entry.value),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
      }
    }
  }

  Future<void> _softDeleteLoser(Customer loser) async {
    final EntityStamp stamp = EntityStamper(_clock).forSoftDelete(loser.stamp);

    await (_db.update(
      _db.customers,
    )..where(($CustomersTable c) => c.id.equals(loser.id))).write(
      CustomersCompanion(
        deletedAt: Value<DateTime?>(stamp.deletedAt),
        updatedAt: Value<DateTime>(stamp.updatedAt),
        version: Value<int>(stamp.version),
      ),
    );
  }

  Future<void> _queueCommand({
    required String survivorId,
    required String loserId,
  }) {
    return _db
        .into(_db.outbox)
        .insert(
          OutboxCompanion.insert(
            id: _uuid.next(),
            entityType: 'customer',
            entityId: survivorId,
            operation: OutboxOperation.command,
            payload: jsonEncode(<String, Object?>{
              'command': 'merge_customer',
              'loser_id': loserId,
            }),
            deviceId: _deviceId,
            createdAt: _clock.nowUtc(),
          ),
        );
  }
}

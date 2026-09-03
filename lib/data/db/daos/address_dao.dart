import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../app_database.dart';
import '../conventions/entity_stamp.dart';

/// Reads and writes customer addresses.
///
/// An address created by typing has no coordinates and therefore
/// `GeoConfidence.none` — tier 0, which invariant 9 says is never routed. It is
/// still a perfectly good address: a driver who knows the building does not
/// need a pin, and the pin arrives on its own the first time a delivery is
/// confirmed there (§10.5). Refusing to store an address without coordinates
/// would refuse most of them.
///
/// Same shape as `CustomerDao`: every mutation goes through [_mutate], which
/// opens the transaction, stamps the row and queues the outbox command in one
/// place, so invariant 5 is a property of the class rather than of each method.
final class AddressDao {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory AddressDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => AddressDao._(database, clock, uuid, deviceId);

  const AddressDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  EntityStamper get _stamper => EntityStamper(_clock);

  /// A customer's live addresses, the primary one first.
  ///
  /// Primary first rather than newest first: the entry flow offers the top one
  /// by default, and the address a driver has been to five times should be that
  /// default rather than whichever was typed most recently.
  Future<List<CustomerAddress>> forCustomer(String customerId) {
    return (_db.select(_db.customerAddresses)
          ..where(
            ($CustomerAddressesTable a) =>
                a.customerId.equals(customerId) & a.deletedAt.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$CustomerAddressesTable>>[
            ($CustomerAddressesTable a) =>
                OrderingTerm(expression: a.isPrimary, mode: OrderingMode.desc),
            ($CustomerAddressesTable a) =>
                OrderingTerm(expression: a.createdAt),
            ($CustomerAddressesTable a) => OrderingTerm(expression: a.id),
          ]))
        .get();
  }

  Future<CustomerAddress?> byId(String id) => (_db.select(
    _db.customerAddresses,
  )..where(($CustomerAddressesTable a) => a.id.equals(id))).getSingleOrNull();

  /// Adds an address.
  ///
  /// The first address a customer gets is primary automatically. Making the
  /// driver choose when there is nothing to choose between is a tap that
  /// answers a question they were not asked.
  Future<CustomerAddress> create({
    required String ownerId,
    required String customerId,
    required int wilayaCode,
    required int communeId,
    String? detail,
    String? label,
    bool? isPrimary,
  }) async {
    final bool first = (await forCustomer(customerId)).isEmpty;
    final bool primary = isPrimary ?? first;
    final String id = _uuid.next();
    final EntityStamp stamp = _stamper.forInsert();

    return _mutate<CustomerAddress>(
      entityId: id,
      operation: OutboxOperation.create,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'customer_id': customerId,
        'wilaya_code': wilayaCode,
        'commune_id': communeId,
        'detail': ?detail,
        'label': ?label,
        'is_primary': primary,
      },
      write: () async {
        if (primary) {
          await _demoteOthers(customerId, exceptId: id);
        }
        return _db
            .into(_db.customerAddresses)
            .insertReturning(
              CustomerAddressesCompanion.insert(
                id: id,
                ownerId: ownerId,
                customerId: customerId,
                wilayaCode: wilayaCode,
                communeId: communeId,
                detail: Value<String?>(detail),
                label: Value<String?>(label),
                isPrimary: Value<bool>(primary),
                createdAt: stamp.createdAt,
                updatedAt: stamp.updatedAt,
                version: stamp.version,
              ),
            );
      },
    );
  }

  /// Makes [current] the customer's primary address.
  ///
  /// Demotes whatever held it, inside the same transaction, because "exactly
  /// one primary" is the invariant and two of them is a state no screen knows
  /// how to render.
  Future<CustomerAddress> makePrimary(CustomerAddress current) {
    final EntityStamp stamp = _stamper.forUpdate(current.stamp);

    return _mutate<CustomerAddress>(
      entityId: current.id,
      operation: OutboxOperation.update,
      at: stamp.updatedAt,
      payload: const <String, Object?>{'is_primary': true},
      write: () async {
        await _demoteOthers(current.customerId, exceptId: current.id);
        await (_db.update(
          _db.customerAddresses,
        )..where(($CustomerAddressesTable a) => a.id.equals(current.id))).write(
          CustomerAddressesCompanion(
            isPrimary: const Value<bool>(true),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
        return (_db.select(_db.customerAddresses)
              ..where(($CustomerAddressesTable a) => a.id.equals(current.id)))
            .getSingle();
      },
    );
  }

  /// Edits an address. Only the named fields move.
  Future<CustomerAddress> edit({
    required CustomerAddress current,
    int? wilayaCode,
    int? communeId,
    String? detail,
    String? label,
  }) {
    final EntityStamp stamp = _stamper.forUpdate(current.stamp);

    return _mutate<CustomerAddress>(
      entityId: current.id,
      operation: OutboxOperation.update,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'wilaya_code': ?wilayaCode,
        'commune_id': ?communeId,
        'detail': ?detail,
        'label': ?label,
      },
      write: () async {
        await (_db.update(
          _db.customerAddresses,
        )..where(($CustomerAddressesTable a) => a.id.equals(current.id))).write(
          CustomerAddressesCompanion(
            wilayaCode: Value<int>.absentIfNull(wilayaCode),
            communeId: Value<int>.absentIfNull(communeId),
            detail: Value<String?>.absentIfNull(detail),
            label: Value<String?>.absentIfNull(label),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
        return (_db.select(_db.customerAddresses)
              ..where(($CustomerAddressesTable a) => a.id.equals(current.id)))
            .getSingle();
      },
    );
  }

  /// Soft-deletes an address. Orders pointing at it still resolve.
  ///
  /// Deleting the primary promotes the oldest survivor rather than leaving the
  /// customer with none: a customer with addresses but no primary is a state
  /// the entry flow would have to invent an answer for every time it ran.
  Future<void> softDelete(CustomerAddress current) {
    final EntityStamp stamp = _stamper.forSoftDelete(current.stamp);

    return _mutate<void>(
      entityId: current.id,
      operation: OutboxOperation.delete,
      at: stamp.updatedAt,
      payload: const <String, Object?>{},
      write: () async {
        await (_db.update(
          _db.customerAddresses,
        )..where(($CustomerAddressesTable a) => a.id.equals(current.id))).write(
          CustomerAddressesCompanion(
            deletedAt: Value<DateTime?>(stamp.deletedAt),
            isPrimary: const Value<bool>(false),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );

        if (!current.isPrimary) {
          return;
        }
        final List<CustomerAddress> left = await forCustomer(
          current.customerId,
        );
        if (left.isEmpty) {
          return;
        }
        // Promoted without its own outbox row: this is part of the delete, not
        // a separate thing the driver did, and a queued `update` here would
        // replay as an edit nobody made.
        await (_db.update(
              _db.customerAddresses,
            )..where(($CustomerAddressesTable a) => a.id.equals(left.first.id)))
            .write(
              const CustomerAddressesCompanion(isPrimary: Value<bool>(true)),
            );
      },
    );
  }

  Future<void> _demoteOthers(String customerId, {required String exceptId}) {
    return (_db.update(_db.customerAddresses)..where(
          ($CustomerAddressesTable a) =>
              a.customerId.equals(customerId) &
              a.id.equals(exceptId).not() &
              a.deletedAt.isNull(),
        ))
        .write(const CustomerAddressesCompanion(isPrimary: Value<bool>(false)));
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
              entityType: 'customer_address',
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

/// The audit columns as an [EntityStamp], so a DAO never assembles one by hand.
extension AddressStamp on CustomerAddress {
  EntityStamp get stamp => EntityStamp(
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
  );
}

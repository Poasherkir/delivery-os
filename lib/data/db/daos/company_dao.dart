import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../app_database.dart';
import '../conventions/entity_stamp.dart';

/// Reads and writes delivery companies.
///
/// Deliberately small. A company is selected once per batch, never per order,
/// so nothing on the order-entry path touches this after the first tap of the
/// day — which is why it gets name, phone and notes and not a management
/// screen's worth of fields. `logo_path` and the settlement side of a company
/// (payment rules) belong to later milestones and are absent rather than
/// stubbed.
///
/// Same shape as the other owned-entity DAOs: every mutation goes through
/// [_mutate], which opens the transaction, stamps the row and queues exactly
/// one outbox row.
final class CompanyDao {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory CompanyDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => CompanyDao._(database, clock, uuid, deviceId);

  const CompanyDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  EntityStamper get _stamper => EntityStamper(_clock);

  /// The companies a batch may be opened against, by name.
  ///
  /// Excludes the inactive as well as the deleted. Nothing sets `is_active`
  /// false yet — deactivation is a screen that does not exist — but the filter
  /// belongs in the query that would otherwise be wrong the day it does, and
  /// the column's whole purpose is that an old company stays in history while
  /// leaving the picker.
  ///
  /// By name rather than by recency: a driver has three companies, not thirty,
  /// and a list that reorders itself under the thumb is worse than one that
  /// does not.
  Future<List<Company>> selectable({required String ownerId}) {
    return (_db.select(_db.companies)
          ..where(
            ($CompaniesTable c) =>
                c.ownerId.equals(ownerId) &
                c.deletedAt.isNull() &
                c.isActive.equals(true),
          )
          ..orderBy(<OrderClauseGenerator<$CompaniesTable>>[
            ($CompaniesTable c) => OrderingTerm(expression: c.name),
            ($CompaniesTable c) => OrderingTerm(expression: c.id),
          ]))
        .get();
  }

  /// One company by id, whatever its state.
  ///
  /// Includes the deleted and the inactive on purpose: a batch from last month
  /// points at a company, and that batch has to render. Same offer/resolve
  /// split as the geography repository — what may be *chosen* is narrower than
  /// what must be *displayed*.
  Future<Company?> byId(String id) => (_db.select(
    _db.companies,
  )..where(($CompaniesTable c) => c.id.equals(id))).getSingleOrNull();

  /// Adds a company.
  ///
  /// No duplicate check. Two agencies can share a name — the driver knows
  /// which is which, and a uniqueness rule invented here would block a real
  /// case to prevent a typo the driver can see and fix.
  Future<Company> create({
    required String ownerId,
    required String name,
    String? contactPhone,
    String? notes,
  }) {
    final String id = _uuid.next();
    final EntityStamp stamp = _stamper.forInsert();

    return _mutate<Company>(
      entityId: id,
      operation: OutboxOperation.create,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'name': name,
        'contact_phone': ?contactPhone,
        'notes': ?notes,
      },
      write: () => _db
          .into(_db.companies)
          .insertReturning(
            CompaniesCompanion.insert(
              id: id,
              ownerId: ownerId,
              name: name,
              contactPhone: Value<String?>(contactPhone),
              notes: Value<String?>(notes),
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          ),
    );
  }

  /// Edits a company. Only the named fields move.
  Future<Company> edit({
    required Company current,
    String? name,
    String? contactPhone,
    String? notes,
  }) {
    final EntityStamp stamp = _stamper.forUpdate(current.stamp);

    return _mutate<Company>(
      entityId: current.id,
      operation: OutboxOperation.update,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'name': ?name,
        'contact_phone': ?contactPhone,
        'notes': ?notes,
      },
      write: () async {
        await (_db.update(
          _db.companies,
        )..where(($CompaniesTable c) => c.id.equals(current.id))).write(
          CompaniesCompanion(
            name: Value<String>.absentIfNull(name),
            contactPhone: Value<String?>.absentIfNull(contactPhone),
            notes: Value<String?>.absentIfNull(notes),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
        return (_db.select(
          _db.companies,
        )..where(($CompaniesTable c) => c.id.equals(current.id))).getSingle();
      },
    );
  }

  /// Soft-deletes a company. Batches pointing at it still resolve.
  Future<void> softDelete(Company current) {
    final EntityStamp stamp = _stamper.forSoftDelete(current.stamp);

    return _mutate<void>(
      entityId: current.id,
      operation: OutboxOperation.delete,
      at: stamp.updatedAt,
      payload: const <String, Object?>{},
      write: () async {
        await (_db.update(
          _db.companies,
        )..where(($CompaniesTable c) => c.id.equals(current.id))).write(
          CompaniesCompanion(
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
              entityType: 'company',
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
extension CompanyStamp on Company {
  EntityStamp get stamp => EntityStamp(
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
  );
}

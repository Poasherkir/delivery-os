import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/value_objects/customer_risk_flag.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../../../domain/value_objects/phone_e164.dart';
import '../app_database.dart';
import '../conventions/entity_stamp.dart';

/// Reads and writes customers.
///
/// The first owned-mutable-entity DAO, so it is where invariant 5 stops being
/// a per-site habit and becomes a shape: every mutation goes through
/// [_mutate], which opens the transaction, stamps the row and queues the
/// outbox command in one place. A method that wrote a customer without going
/// through it would be caught by `outbox_guard_test`.
///
/// **No restore.** A soft-deleted customer stays deleted; the product need is
/// merge, which is a separate M1 feature. `EntityStamper.forRestore` exists for
/// other entities.
final class CustomerDao {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory CustomerDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => CustomerDao._(database, clock, uuid, deviceId);

  const CustomerDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  EntityStamper get _stamper => EntityStamper(_clock);

  /// The customer with this phone, or null. Soft-deleted rows are invisible.
  ///
  /// The identity lookup, and it has to be instant: every order entry runs it
  /// before anything else happens. `idx_customers_owner_phone` covers it.
  Future<Customer?> findByPhone({
    required String ownerId,
    required PhoneE164 phone,
  }) {
    return (_db.select(_db.customers)
          ..where(
            ($CustomersTable c) =>
                c.ownerId.equals(ownerId) &
                c.phoneE164.equalsValue(phone) &
                c.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Every live customer, oldest first.
  Future<List<Customer>> all({required String ownerId}) {
    return (_db.select(_db.customers)
          ..where(
            ($CustomersTable c) =>
                c.ownerId.equals(ownerId) & c.deletedAt.isNull(),
          )
          // §6.1: milliseconds collide, and UUIDv7 sorts chronologically, so
          // the id is a deterministic tiebreak.
          ..orderBy(<OrderClauseGenerator<$CustomersTable>>[
            ($CustomersTable c) => OrderingTerm(expression: c.createdAt),
            ($CustomersTable c) => OrderingTerm(expression: c.id),
          ]))
        .get();
  }

  /// The stored row, or null if it is gone.
  Future<Customer?> byId(String id) => (_db.select(
    _db.customers,
  )..where(($CustomersTable c) => c.id.equals(id))).getSingleOrNull();

  /// Free-text search over name and number, through the FTS5 index.
  ///
  /// Substring matching, not prefix: the index uses the trigram tokenizer
  /// precisely so that typing the last digits off a parcel finds the customer.
  /// That costs a floor of three characters — trigram indexes nothing shorter —
  /// so anything under that falls back to a LIKE scan, which is cheap at one
  /// or two characters because almost everything matches anyway.
  ///
  /// The `MATCH` argument is passed as a bound variable and wrapped in double
  /// quotes so FTS5 reads it as a literal string. Without the quoting, a query
  /// containing `*`, `-`, `:` or `OR` would be parsed as query syntax — a
  /// driver typing a phone number with a dash would get a syntax error rather
  /// than a customer.
  Future<List<Customer>> search({
    required String ownerId,
    required String query,
  }) {
    final String trimmed = query.trim();
    if (trimmed.length < _trigramFloor) {
      return _searchByScan(ownerId: ownerId, query: trimmed);
    }

    return _db
        .customSelect(
          'SELECT c.* FROM customers_fts f '
          'JOIN customers c ON c.id = f.customer_id '
          'WHERE customers_fts MATCH ?2 '
          'AND c.owner_id = ?1 AND c.deleted_at IS NULL '
          'ORDER BY c.created_at, c.id',
          variables: <Variable<Object>>[
            Variable<String>(ownerId),
            Variable<String>('"${trimmed.replaceAll('"', '""')}"'),
          ],
          readsFrom: <ResultSetImplementation<Table, Object?>>{_db.customers},
        )
        .map((QueryRow row) => _db.customers.map(row.data))
        .get();
  }

  /// Trigram indexes no substring shorter than this.
  static const int _trigramFloor = 3;

  /// The one- and two-character case the index cannot serve.
  Future<List<Customer>> _searchByScan({
    required String ownerId,
    required String query,
  }) {
    final String like = '%${query.toLowerCase()}%';
    return _db
        .customSelect(
          'SELECT * FROM customers WHERE owner_id = ?1 AND deleted_at IS NULL '
          'AND (lower(display_name) LIKE ?2 OR lower(phone_e164) LIKE ?2 '
          'OR lower(phone_raw) LIKE ?2) '
          'ORDER BY created_at, id',
          variables: <Variable<Object>>[
            Variable<String>(ownerId),
            Variable<String>(like),
          ],
          readsFrom: <ResultSetImplementation<Table, Object?>>{_db.customers},
        )
        .map((QueryRow row) => _db.customers.map(row.data))
        .get();
  }

  /// Creates a customer. Returns the stored row.
  ///
  /// Throws when the owner already has a live customer on this number — the
  /// partial unique index enforces it, and the caller is expected to have
  /// looked the number up first. Duplicate *detection* is a UI flow, not a
  /// silent upsert here: merging two records is a decision with consequences
  /// for orders and learned pins, and it is not this method's to make.
  Future<Customer> create({
    required String ownerId,
    required PhoneE164 phone,
    required String displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag riskFlag = CustomerRiskFlag.none,
  }) {
    final String id = _uuid.next();
    final EntityStamp stamp = _stamper.forInsert();

    return _mutate<Customer>(
      entityId: id,
      operation: OutboxOperation.create,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'phone_e164': phone.e164,
        'display_name': displayName,
        'phone_alt': ?phoneAlt?.e164,
        'notes': ?notes,
        'risk_flag': riskFlag.name,
      },
      write: () => _db
          .into(_db.customers)
          .insertReturning(
            CustomersCompanion.insert(
              id: id,
              ownerId: ownerId,
              phoneE164: Value<PhoneE164?>(phone),
              displayName: displayName,
              phoneAlt: Value<PhoneE164?>(phoneAlt),
              notes: Value<String?>(notes),
              riskFlag: Value<CustomerRiskFlag>(riskFlag),
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          ),
    );
  }

  /// Creates a customer whose number the parser rejected.
  ///
  /// **The reason `phone_e164` is nullable.** A driver in an agency at 07:00
  /// cannot be stopped from entering an order because a validator disagrees
  /// with a pre-2008 landline format. The raw string is kept verbatim, the
  /// record is created, and [needingPhoneReview] finds it later.
  ///
  /// Not a fallback that [create] reaches for on its own: a caller that meant
  /// to save a real number and typo'd it should see the parse failure, not have
  /// it silently absorbed. Choosing this path is the entry flow saying "keep it
  /// anyway", which is a decision a human made.
  Future<Customer> createUnparsed({
    required String ownerId,
    required String rawPhone,
    required String displayName,
    String? notes,
  }) {
    final String id = _uuid.next();
    final EntityStamp stamp = _stamper.forInsert();

    return _mutate<Customer>(
      entityId: id,
      operation: OutboxOperation.create,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'phone_raw': rawPhone,
        'display_name': displayName,
        'notes': ?notes,
      },
      write: () => _db
          .into(_db.customers)
          .insertReturning(
            CustomersCompanion.insert(
              id: id,
              ownerId: ownerId,
              displayName: displayName,
              phoneRaw: Value<String>(rawPhone),
              notes: Value<String?>(notes),
              createdAt: stamp.createdAt,
              updatedAt: stamp.updatedAt,
              version: stamp.version,
            ),
          ),
    );
  }

  /// Customers whose number never parsed, oldest first.
  ///
  /// Derived from the data rather than a stored flag: a third column saying
  /// "needs review" could disagree with the other two, and there is exactly one
  /// state that means it — no parsed number.
  Future<List<Customer>> needingPhoneReview({required String ownerId}) {
    return (_db.select(_db.customers)
          ..where(
            ($CustomersTable c) =>
                c.ownerId.equals(ownerId) &
                c.deletedAt.isNull() &
                c.phoneE164.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$CustomersTable>>[
            ($CustomersTable c) => OrderingTerm(expression: c.createdAt),
            ($CustomersTable c) => OrderingTerm(expression: c.id),
          ]))
        .get();
  }

  /// Replaces an unparsed number with one that parses.
  ///
  /// The correction flow's write. Clears `phone_raw` in the same statement,
  /// because the CHECK constraint permits exactly one of the two — and because
  /// keeping the rejected string after it has been superseded would leave two
  /// answers to "what is this customer's number".
  Future<Customer> resolvePhone({
    required Customer current,
    required PhoneE164 phone,
  }) {
    final EntityStamp stamp = _stamper.forUpdate(current.stamp);

    return _mutate<Customer>(
      entityId: current.id,
      operation: OutboxOperation.update,
      at: stamp.updatedAt,
      payload: <String, Object?>{'phone_e164': phone.e164},
      write: () async {
        await (_db.update(
          _db.customers,
        )..where(($CustomersTable c) => c.id.equals(current.id))).write(
          CustomersCompanion(
            phoneE164: Value<PhoneE164?>(phone),
            phoneRaw: const Value<String?>(null),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
        return (_db.select(
          _db.customers,
        )..where(($CustomersTable c) => c.id.equals(current.id))).getSingle();
      },
    );
  }

  /// Edits a customer. Only the named fields move.
  ///
  /// Takes the whole [current] row rather than an id, because the stamp has to
  /// be derived from the version already stored — `EntityStamper.forUpdate`
  /// bumps it, and a DAO that read the row itself could bump a version it had
  /// not seen change.
  Future<Customer> edit({
    required Customer current,
    String? displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag? riskFlag,
  }) {
    final EntityStamp stamp = _stamper.forUpdate(current.stamp);

    return _mutate<Customer>(
      entityId: current.id,
      operation: OutboxOperation.update,
      at: stamp.updatedAt,
      payload: <String, Object?>{
        'display_name': ?displayName,
        'phone_alt': ?phoneAlt?.e164,
        'notes': ?notes,
        'risk_flag': ?riskFlag?.name,
      },
      write: () async {
        await (_db.update(
          _db.customers,
        )..where(($CustomersTable c) => c.id.equals(current.id))).write(
          CustomersCompanion(
            displayName: Value<String>.absentIfNull(displayName),
            phoneAlt: Value<PhoneE164?>.absentIfNull(phoneAlt),
            notes: Value<String?>.absentIfNull(notes),
            riskFlag: Value<CustomerRiskFlag>.absentIfNull(riskFlag),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
        return (_db.select(
          _db.customers,
        )..where(($CustomersTable c) => c.id.equals(current.id))).getSingle();
      },
    );
  }

  /// Soft-deletes a customer. The row stays; orders pointing at it still read.
  Future<void> softDelete(Customer current) {
    final EntityStamp stamp = _stamper.forSoftDelete(current.stamp);

    return _mutate<void>(
      entityId: current.id,
      operation: OutboxOperation.delete,
      at: stamp.updatedAt,
      payload: const <String, Object?>{},
      write: () async {
        await (_db.update(
          _db.customers,
        )..where(($CustomersTable c) => c.id.equals(current.id))).write(
          CustomersCompanion(
            deletedAt: Value<DateTime?>(stamp.deletedAt),
            updatedAt: Value<DateTime>(stamp.updatedAt),
            version: Value<int>(stamp.version),
          ),
        );
      },
    );
  }

  /// Invariant 5, in one place.
  ///
  /// The entity write and the outbox row go in one transaction, so a queued
  /// command can never describe a write that did not land, and a landed write
  /// can never be missing from the queue. Putting it here rather than in each
  /// method is the difference between a rule every future method has to
  /// remember and a rule it cannot avoid.
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
              entityType: 'customer',
              entityId: entityId,
              operation: operation,
              // Raw JSON, replayed verbatim (§11.2). Parsing it through a live
              // model would let a refactor change what a queued write means.
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
extension CustomerStamp on Customer {
  EntityStamp get stamp => EntityStamp(
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
  );
}

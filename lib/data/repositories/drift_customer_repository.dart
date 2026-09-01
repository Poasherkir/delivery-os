import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/value_objects/customer_risk_flag.dart';
import '../../domain/value_objects/phone_e164.dart';
import '../db/app_database.dart' as db;
import '../db/daos/customer_dao.dart';

/// [CustomerRepository] against the local database.
///
/// The Drift row is imported under a prefix because both types are correctly
/// called `Customer` — one is the table's shape, the other is what the app
/// means by a customer, and neither should be renamed to dodge the collision.
final class DriftCustomerRepository implements CustomerRepository {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftCustomerRepository({
    required CustomerDao dao,
    required String ownerId,
  }) => DriftCustomerRepository._(dao, ownerId);

  const DriftCustomerRepository._(this._dao, this._ownerId);

  final CustomerDao _dao;
  final String _ownerId;

  @override
  Future<List<Customer>> all() async =>
      (await _dao.all(ownerId: _ownerId)).map(_toDomain).toList();

  @override
  Future<List<Customer>> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      // A cleared search field is not a search that found nothing.
      return all();
    }
    return (await _dao.search(
      ownerId: _ownerId,
      query: trimmed,
    )).map(_toDomain).toList();
  }

  @override
  Future<Customer?> findByPhone(PhoneE164 phone) async {
    final db.Customer? row = await _dao.findByPhone(
      ownerId: _ownerId,
      phone: phone,
    );
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Customer>> needingPhoneReview() async =>
      (await _dao.needingPhoneReview(
        ownerId: _ownerId,
      )).map(_toDomain).toList();

  @override
  Future<Customer> create({
    required PhoneE164 phone,
    required String displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag riskFlag = CustomerRiskFlag.none,
  }) async {
    // Checked before writing rather than catching the constraint violation,
    // so the caller gets the customer that already holds the number. A bare
    // "unique constraint failed" would make the UI search for it again to say
    // anything useful.
    //
    // This is a check-then-act and the index is still the real guarantee: two
    // concurrent creates would leave one of them throwing, which is correct.
    // There is one driver on one phone, so the race is theoretical.
    final Customer? existing = await findByPhone(phone);
    if (existing != null) {
      throw DuplicatePhoneException(existing);
    }

    return _toDomain(
      await _dao.create(
        ownerId: _ownerId,
        phone: phone,
        displayName: displayName,
        phoneAlt: phoneAlt,
        notes: notes,
        riskFlag: riskFlag,
      ),
    );
  }

  @override
  Future<Customer> createUnparsed({
    required String rawPhone,
    required String displayName,
    String? notes,
  }) async => _toDomain(
    await _dao.createUnparsed(
      ownerId: _ownerId,
      rawPhone: rawPhone,
      displayName: displayName,
      notes: notes,
    ),
  );

  @override
  Future<Customer> edit({
    required Customer current,
    String? displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag? riskFlag,
  }) async => _toDomain(
    await _dao.edit(
      current: await _row(current),
      displayName: displayName,
      phoneAlt: phoneAlt,
      notes: notes,
      riskFlag: riskFlag,
    ),
  );

  @override
  Future<Customer> resolvePhone({
    required Customer current,
    required PhoneE164 phone,
  }) async {
    final Customer? existing = await findByPhone(phone);
    if (existing != null && existing.id != current.id) {
      // Correcting a number onto one somebody else already holds is the
      // duplicate case arriving by a different door, and it has the same
      // answer: show the driver who has it.
      throw DuplicatePhoneException(existing);
    }
    return _toDomain(
      await _dao.resolvePhone(current: await _row(current), phone: phone),
    );
  }

  @override
  Future<void> softDelete(Customer current) async =>
      _dao.softDelete(await _row(current));

  /// The stored row behind a domain customer.
  ///
  /// Re-read rather than reconstructed. The DAO stamps an edit from the
  /// version it is given, and a row rebuilt from a domain object that has been
  /// sitting in a form for two minutes would carry a stale one — silently
  /// overwriting whatever moved in between.
  Future<db.Customer> _row(Customer customer) async {
    final db.Customer? row = await _dao.byId(customer.id);
    if (row == null) {
      throw StateError('customer ${customer.id} no longer exists');
    }
    return row;
  }

  Customer _toDomain(db.Customer row) => Customer(
    id: row.id,
    displayName: row.displayName,
    version: row.version,
    phone: row.phoneE164,
    phoneRaw: row.phoneRaw,
    phoneAlt: row.phoneAlt,
    notes: row.notes,
    riskFlag: row.riskFlag,
    totalOrders: row.totalOrders,
    totalDelivered: row.totalDelivered,
    totalFailed: row.totalFailed,
    lastDeliveredAt: row.lastDeliveredAt,
  );
}

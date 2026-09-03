import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../db/app_database.dart' as db;
import '../db/daos/address_dao.dart';

/// [AddressRepository] against the local database.
final class DriftAddressRepository implements AddressRepository {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftAddressRepository({
    required AddressDao dao,
    required String ownerId,
  }) => DriftAddressRepository._(dao, ownerId);

  const DriftAddressRepository._(this._dao, this._ownerId);

  final AddressDao _dao;
  final String _ownerId;

  @override
  Future<List<Address>> forCustomer(String customerId) async =>
      (await _dao.forCustomer(customerId)).map(_toDomain).toList();

  @override
  Future<Address> create({
    required String customerId,
    required int wilayaCode,
    required int communeId,
    String? detail,
    String? label,
  }) async {
    final String? trimmed = detail?.trim();

    return _toDomain(
      await _dao.create(
        ownerId: _ownerId,
        customerId: customerId,
        wilayaCode: wilayaCode,
        communeId: communeId,
        // An empty detail is stored as null rather than as an empty string.
        // Two spellings of "nothing here" would each have to be checked
        // everywhere the field is read.
        detail: (trimmed?.isEmpty ?? true) ? null : trimmed,
        label: label,
      ),
    );
  }

  Address _toDomain(db.CustomerAddress row) => Address(
    id: row.id,
    customerId: row.customerId,
    wilayaCode: row.wilayaCode,
    communeId: row.communeId,
    isPrimary: row.isPrimary,
    version: row.version,
    detail: row.detail,
    label: row.label,
    confidence: row.geoConfidence,
  );
}

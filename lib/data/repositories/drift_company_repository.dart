import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../db/app_database.dart' as db;
import '../db/daos/company_dao.dart';

/// [CompanyRepository] against the local database.
///
/// The Drift row is imported under a prefix because both types are correctly
/// called `Company`, the same collision `DriftCustomerRepository` has and for
/// the same reason. Neither is renamed to dodge it.
final class DriftCompanyRepository implements CompanyRepository {
  /// Routed through a private positional constructor so the fields stay
  /// private while the call site stays named.
  factory DriftCompanyRepository({
    required CompanyDao dao,
    required String ownerId,
  }) => DriftCompanyRepository._(dao, ownerId);

  const DriftCompanyRepository._(this._dao, this._ownerId);

  final CompanyDao _dao;
  final String _ownerId;

  @override
  Future<List<Company>> selectable() async =>
      (await _dao.selectable(ownerId: _ownerId)).map(_toDomain).toList();

  @override
  Future<Company?> byId(String id) async {
    final db.Company? row = await _dao.byId(id);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Company> create({
    required String name,
    String? contactPhone,
    String? notes,
  }) async => _toDomain(
    await _dao.create(
      ownerId: _ownerId,
      name: name.trim(),
      contactPhone: contactPhone,
      notes: notes,
    ),
  );

  @override
  Future<Company> edit({
    required Company current,
    String? name,
    String? contactPhone,
    String? notes,
  }) async => _toDomain(
    await _dao.edit(
      current: await _row(current),
      name: name?.trim(),
      contactPhone: contactPhone,
      notes: notes,
    ),
  );

  @override
  Future<void> softDelete(Company current) async =>
      _dao.softDelete(await _row(current));

  /// The stored row behind a domain company.
  ///
  /// Re-read rather than reconstructed, for the reason
  /// `DriftCustomerRepository._row` gives: the DAO stamps an edit from the
  /// version it is handed, and a row rebuilt from an object that has been
  /// sitting in a form would carry a stale one.
  Future<db.Company> _row(Company company) async {
    final db.Company? row = await _dao.byId(company.id);
    if (row == null) {
      throw StateError('company ${company.id} no longer exists');
    }
    return row;
  }

  Company _toDomain(db.Company row) => Company(
    id: row.id,
    name: row.name,
    version: row.version,
    contactPhone: row.contactPhone,
    notes: row.notes,
  );
}

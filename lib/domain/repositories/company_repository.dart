import '../entities/company.dart';

/// Reading and writing companies, as `features/` sees it.
///
/// Note what is absent. No `deactivate`: the table carries `is_active` and
/// [selectable] already honours it, but nothing sets it, because hiding a
/// company from the picker without deleting it is a decision with a screen
/// attached and no screen exists. No duplicate-name check either — two agencies
/// can share a name, and a uniqueness rule invented here would block a real
/// case to prevent a typo the driver can see.
abstract interface class CompanyRepository {
  /// The companies a batch may be opened against, by name.
  ///
  /// Excludes the deleted and the inactive. This is the *offer* list, and it is
  /// narrower than what has to be displayed — [byId] resolves a company a past
  /// batch points at, whatever state it is in.
  Future<List<Company>> selectable();

  /// One company by id, including the deleted and the inactive.
  Future<Company?> byId(String id);

  /// Adds a company. [name] is the only thing a driver has to type.
  Future<Company> create({
    required String name,
    String? contactPhone,
    String? notes,
  });

  /// Edits a company. Only the named fields move.
  Future<Company> edit({
    required Company current,
    String? name,
    String? contactPhone,
    String? notes,
  });

  /// Soft-deletes a company. Batches pointing at it still resolve.
  Future<void> softDelete(Company current);
}

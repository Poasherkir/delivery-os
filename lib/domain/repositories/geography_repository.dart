import '../entities/place.dart';

/// Reading Algeria's wilayas and communes.
///
/// **Two kinds of read, and the difference is the whole design.** Anything that
/// *offers* a choice excludes retired rows; anything that *resolves* a stored
/// id includes them. A driver must never be offered a wilaya the state has
/// abolished, and an address recorded before the abolition must never render
/// as a blank.
///
/// The `byId` methods are the ones that carry old data forward, so they take no
/// filter and have no way to express one.
abstract interface class GeographyRepository {
  /// Wilayas a driver can choose from, ordered by code.
  ///
  /// Code order rather than alphabetical: Algerian wilaya codes are the
  /// numbering every carrier and every bordereau uses, and a driver looking for
  /// 16 scans for 16.
  Future<List<Wilaya>> selectableWilayas();

  /// Communes a driver can choose from within a wilaya, by name.
  Future<List<Commune>> selectableCommunes(int wilayaCode);

  /// Free-text search across communes, optionally within one wilaya.
  ///
  /// Matches either name. A driver reading a French label off a parcel and a
  /// driver typing Arabic must find the same commune.
  Future<List<Commune>> searchCommunes(String query, {int? wilayaCode});

  /// Resolves a stored code, retired or not. Null only if it never existed.
  Future<Wilaya?> wilayaByCode(int code);

  /// Resolves a stored id, retired or not. Null only if it never existed.
  Future<Commune?> communeById(int id);
}

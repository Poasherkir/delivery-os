import 'package:meta/meta.dart';

/// A delivery company the driver works for.
///
/// Small because a company is chosen once per batch and never per order — the
/// order-entry path reads [name] and nothing else. `logo_path`, activation and
/// the payment rule that decides what the driver is owed all exist on the table
/// or in later milestones; none of them belongs in the contract a screen sees
/// today, and adding them now would be inventing the shape of a screen that has
/// not been designed.
@immutable
final class Company {
  const Company({
    required this.id,
    required this.name,
    required this.version,
    this.contactPhone,
    this.notes,
  });

  final String id;
  final String name;

  /// Carried so an edit can be stamped without re-reading the row. Opaque to
  /// the UI, which must never construct or increment it.
  final int version;

  /// Free text, deliberately not a `PhoneE164`.
  ///
  /// Dial-and-display data, never an identity key. Agencies hand out things
  /// like a mobile and a landline separated by a slash, which is useful to a
  /// driver and is not a phone number.
  final String? contactPhone;

  final String? notes;

  @override
  bool operator ==(Object other) =>
      other is Company && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  /// The name is safe to log — a company is a business, not a household — but
  /// [contactPhone] is left out anyway. It costs nothing to omit and it is the
  /// one field here that could turn out to be somebody's personal mobile.
  @override
  String toString() => 'Company($id, v$version, $name)';
}

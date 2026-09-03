import 'package:meta/meta.dart';

import '../value_objects/geo_confidence.dart';

/// Somewhere a parcel goes.
///
/// Carries the commune id rather than a resolved commune name, for the reason
/// `Wilaya` carries both names: which name to show is the caller's decision,
/// made from the active locale, and resolving it here would move that decision
/// somewhere that cannot see the locale.
///
/// No coordinates on the entity even though the row has them. Nothing in M1
/// renders a pin, [confidence] is what a screen actually asks — can this be
/// routed — and a latitude carried through the boundary before anything needs
/// it is a household's location travelling further than it has to.
@immutable
final class Address {
  const Address({
    required this.id,
    required this.customerId,
    required this.wilayaCode,
    required this.communeId,
    required this.isPrimary,
    required this.version,
    this.detail,
    this.label,
    this.confidence = GeoConfidence.none,
  });

  final String id;
  final String customerId;
  final int wilayaCode;
  final int communeId;

  /// Exactly one of a customer's live addresses is primary.
  final bool isPrimary;

  /// Carried so a later write can be stamped without re-reading the row.
  final int version;

  /// The cité, the block, the floor — what a driver uses to find a door.
  final String? detail;

  /// What the driver calls it: `maison`, `travail`.
  final String? label;

  /// Tier 0 until a delivery is confirmed here. Invariant 9: a tier-0 stop is
  /// never routed.
  final GeoConfidence confidence;

  /// Whether this address can be routed to.
  ///
  /// Derived, never stored. False for everything typed by hand, which is most
  /// of them until the first delivery lands a pin.
  bool get isRoutable => confidence != GeoConfidence.none;

  @override
  bool operator ==(Object other) =>
      other is Address && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  /// Neither the detail nor a coordinate appears here.
  ///
  /// A customer's home address is, with their phone number, the most sensitive
  /// pair in this system. `Bt 12, 3e étage, Cité 1000 Logements` in a crash
  /// payload is a household's front door, and the commune id alone is not.
  @override
  String toString() =>
      'Address($id, v$version, commune $communeId, ${confidence.name})';
}

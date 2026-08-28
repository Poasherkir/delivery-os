import 'package:meta/meta.dart';

/// Why a pin that was trusted is being taken back down.
///
/// A value rather than a free string, so corrections are countable: "how often
/// are we promoting fixes taken away from the door" is a question the M2
/// correction flow should be able to answer without parsing prose.
///
/// **Provisional.** These two cover the failures known at M0. The list is
/// expected to grow, but each addition should come from an observed correction
/// in the field, not from imagining one.
enum PinCorrectionReason {
  /// The fix was not recorded at the delivery point — marked delivered from
  /// the car two streets away, or captured at the agency rather than the door.
  capturedAwayFromDeliveryPoint,

  /// A human said the location is wrong: the driver on a later visit, or the
  /// customer.
  reportedIncorrect,
}

/// How much a coordinate is trusted, 0 to 4.
///
/// Mirrors `customer_addresses.geo_confidence`. The tier numbers are persisted,
/// so they are part of the schema and cannot be reordered.
///
/// Confidence is the gate on the learned-pin geocoder, which is the one asset
/// in this product that compounds — and therefore the one that a bad value
/// degrades permanently and silently. Two rules follow, and they are
/// deliberately separate operations rather than one with a flag:
///
/// * **Evidence only ever raises confidence.** [upgrade] takes the higher of
///   two tiers and can never lower one. A worse observation is not news.
/// * **Correcting a proven-wrong pin is a deliberate, logged act.** [demote]
///   is the only way down, it demands a [PinCorrectionReason], and it is never
///   called as a side effect of anything.
///
/// Without the second, a wrong confidence-4 pin would be permanent and would
/// outrank every later correction — routing that customer to the wrong place
/// forever.
enum GeoConfidence implements Comparable<GeoConfidence> {
  /// No usable location. Never routed (invariant 9); surfaced in the "needs
  /// location" list instead.
  none(0),

  /// The centroid of the declared commune. Routable, but clustered into a zone
  /// stop rather than treated as an address — see `docs/ARCHITECTURE.md` §10.1.
  communeCentroid(1),

  /// Resolved from an address string. Usable, flagged as approximate.
  geocoded(2),

  /// The driver placed it on the map. Trusted.
  driverPinned(3),

  /// Confirmed by device GPS at the moment of delivery. The learned pin, and
  /// the reason the geocoder improves with every drop.
  gpsConfirmed(4);

  const GeoConfidence(this.tier);

  /// The persisted value. Part of the schema.
  final int tier;

  /// Reads a tier back from the database.
  ///
  /// Throws on an unknown value rather than degrading. Degrading upward would
  /// over-trust a coordinate the code does not understand, and degrading to
  /// [none] would silently drop a stop off the route — both are worse than a
  /// loud failure on data this app wrote itself.
  static GeoConfidence fromTier(int tier) {
    for (final GeoConfidence confidence in values) {
      if (confidence.tier == tier) {
        return confidence;
      }
    }
    throw ArgumentError.value(tier, 'tier', 'not a known confidence tier');
  }

  /// Whether a stop at this confidence may enter the optimizer.
  ///
  /// Invariant 9: a confidence-0 stop is never routed. Routing a coordinate
  /// nobody has is worse than telling the driver it is missing.
  bool get isRoutable => this != none;

  /// Whether the optimizer must cluster this into a zone stop rather than
  /// treat it as an address (§10.1). A commune centroid can be kilometres from
  /// the door.
  bool get isZoneOnly => this == communeCentroid;

  /// Usable, but shown to the driver as approximate (§10.1).
  bool get isApproximate => this == geocoded;

  /// Good enough to route to directly, without a caveat (§10.1).
  bool get isExact => this >= driverPinned;

  /// The confidence after observing [evidence].
  ///
  /// Monotonic: returns whichever is higher, never the lower. A GPS fix does
  /// not stop being a GPS fix because a later order arrived with only a
  /// commune. Use [demote] to correct a pin that is actually wrong.
  GeoConfidence upgrade(GeoConfidence evidence) =>
      evidence.tier > tier ? evidence : this;

  /// Deliberately lowers this confidence, because the pin has been shown to be
  /// wrong.
  ///
  /// The only way down. Not an inverse of [upgrade] and not reachable from it:
  /// this exists for a user action or the M2 correction flow, never as a side
  /// effect of recording an observation.
  ///
  /// Returns a [PinCorrection] rather than a bare tier, and is [useResult], so
  /// the audit trail is **enforced rather than documented**. A discarded
  /// correction fails analysis; a `reason` parameter that the method never read
  /// would only have been a comment with a type, and the first person tidying
  /// up would delete it.
  ///
  /// Throws unless [to] is strictly lower — raising is [upgrade]'s job, and a
  /// no-op "demotion" almost certainly means the caller has the direction
  /// wrong.
  @useResult
  PinCorrection demote({
    required GeoConfidence to,
    required PinCorrectionReason reason,
  }) {
    if (to.tier >= tier) {
      throw ArgumentError.value(
        to,
        'to',
        'demote must lower the tier; $name is already at $tier '
            '(use upgrade to raise)',
      );
    }
    return PinCorrection(previous: this, confidence: to, reason: reason);
  }

  bool operator <(GeoConfidence other) => tier < other.tier;

  bool operator <=(GeoConfidence other) => tier <= other.tier;

  bool operator >(GeoConfidence other) => tier > other.tier;

  bool operator >=(GeoConfidence other) => tier >= other.tier;

  @override
  int compareTo(GeoConfidence other) => tier.compareTo(other.tier);
}

/// A deliberate lowering of a pin's confidence.
///
/// Carries everything an `audit_logs` entry needs — what it was, what it became,
/// and why — so recording the correction is a matter of persisting this value
/// rather than remembering to assemble one.
@immutable
final class PinCorrection {
  const PinCorrection({
    required this.previous,
    required this.confidence,
    required this.reason,
  });

  /// The tier before the correction.
  final GeoConfidence previous;

  /// The tier after it. Always strictly lower than [previous].
  final GeoConfidence confidence;

  final PinCorrectionReason reason;

  @override
  bool operator ==(Object other) =>
      other is PinCorrection &&
      other.previous == previous &&
      other.confidence == confidence &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(previous, confidence, reason);

  /// Tiers and a reason only — no coordinate ever appears here, so this is safe
  /// in a log.
  @override
  String toString() =>
      'PinCorrection(${previous.name} -> ${confidence.name}, ${reason.name})';
}

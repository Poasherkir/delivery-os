import 'package:flutter/foundation.dart';

/// The badge attached to a coordinate-confidence marker.
enum ConfidenceBadge {
  /// No badge. Tiers 1–3.
  none,

  /// Tier 0: the stop has no usable location and cannot be routed.
  unknown,

  /// Tier 4: GPS-confirmed at the door.
  confirmed,
}

/// The visual treatment for one coordinate-confidence tier.
///
/// **There is deliberately no colour here.** Four status buckets already own
/// the palette's hues; a fifth ramp competing with them would be unreadable in
/// sunlight and impossible under colour-blindness. Confidence is carried by
/// border weight, dash pattern, fill and badge, so a marker can state its
/// status *and* its confidence at the same time without the two fighting.
///
/// Tiers mirror `geo_confidence` in the schema: 0 none, 1 commune centroid,
/// 2 geocoded string, 3 driver-pinned, 4 GPS-confirmed at delivery.
@immutable
class ConfidenceTreatment {
  const ConfidenceTreatment({
    required this.tier,
    required this.borderWidth,
    required this.dashPattern,
    required this.filled,
    required this.badge,
  });

  final int tier;
  final double borderWidth;

  /// `null` means a solid outline. Otherwise on/off lengths.
  final List<double>? dashPattern;

  /// Whether the marker body is filled or left as an outline.
  final bool filled;

  final ConfidenceBadge badge;
}

abstract final class ConfidenceTokens {
  /// Tier 0 — no location. Never routed (invariant 9); shown in the
  /// "needs location" list rather than on the route.
  static const ConfidenceTreatment none = ConfidenceTreatment(
    tier: 0,
    borderWidth: 1,
    dashPattern: <double>[2, 3],
    filled: false,
    badge: ConfidenceBadge.unknown,
  );

  /// Tier 1 — commune centroid. Routable but clustered as a zone stop.
  static const ConfidenceTreatment centroid = ConfidenceTreatment(
    tier: 1,
    borderWidth: 1,
    dashPattern: <double>[5, 3],
    filled: false,
    badge: ConfidenceBadge.none,
  );

  /// Tier 2 — geocoded string. Approximate; flagged to the driver.
  static const ConfidenceTreatment geocoded = ConfidenceTreatment(
    tier: 2,
    borderWidth: 1,
    dashPattern: null,
    filled: false,
    badge: ConfidenceBadge.none,
  );

  /// Tier 3 — pinned by the driver on the map.
  static const ConfidenceTreatment pinned = ConfidenceTreatment(
    tier: 3,
    borderWidth: 2,
    dashPattern: null,
    filled: true,
    badge: ConfidenceBadge.none,
  );

  /// Tier 4 — GPS-confirmed at delivery. The learned-pin asset.
  static const ConfidenceTreatment confirmed = ConfidenceTreatment(
    tier: 4,
    borderWidth: 2,
    dashPattern: null,
    filled: true,
    badge: ConfidenceBadge.confirmed,
  );

  /// Indexed by tier.
  static const List<ConfidenceTreatment> byTier = <ConfidenceTreatment>[
    none,
    centroid,
    geocoded,
    pinned,
    confirmed,
  ];
}

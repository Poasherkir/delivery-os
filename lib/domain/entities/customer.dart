import 'package:meta/meta.dart';

import '../value_objects/customer_risk_flag.dart';
import '../value_objects/phone_e164.dart';

/// A person who receives parcels.
///
/// Exists so `features/` can render a customer without importing Drift. The
/// layering rule is one-directional and this is where it starts costing
/// something — the Drift row and this type carry nearly the same fields, and
/// the mapping between them is real code that does nothing visible.
///
/// It earns that cost twice over. `features/` cannot accidentally reach a
/// column that is not part of the contract, and the two nullable phone columns
/// collapse here into the one thing a screen actually asks: is there a number
/// we can dial, or a string a human has to look at.
@immutable
final class Customer {
  const Customer({
    required this.id,
    required this.displayName,
    required this.version,
    this.phone,
    this.phoneRaw,
    this.phoneAlt,
    this.notes,
    this.riskFlag = CustomerRiskFlag.none,
    this.totalOrders = 0,
    this.totalDelivered = 0,
    this.totalFailed = 0,
    this.lastDeliveredAt,
  }) : assert(
         (phone == null) != (phoneRaw == null),
         'exactly one of phone and phoneRaw is set — the same rule the CHECK '
         'constraint holds in the database',
       );

  final String id;
  final String displayName;

  /// Carried so an edit can be stamped without re-reading the row. Opaque to
  /// the UI, which must never construct or increment it.
  final int version;

  /// The identity key, when the number parsed.
  final PhoneE164? phone;

  /// What the driver typed, when it did not. Verbatim.
  final String? phoneRaw;

  final PhoneE164? phoneAlt;
  final String? notes;
  final CustomerRiskFlag riskFlag;

  final int totalOrders;
  final int totalDelivered;
  final int totalFailed;
  final DateTime? lastDeliveredAt;

  /// Whether a human still has to look at this number.
  ///
  /// Derived, never stored. There is exactly one state that means it.
  bool get needsPhoneReview => phone == null;

  /// How many of this customer's orders came back undelivered.
  ///
  /// Deliberately *not* a risk signal. Nothing in this app infers
  /// [riskFlag] from history — a customer who was out twice is not a problem
  /// customer, and a rule that decided otherwise would quietly build a
  /// blacklist nobody agreed to.
  int get failedCount => totalFailed;

  @override
  bool operator ==(Object other) =>
      other is Customer && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  /// Masked, because this reaches log lines and crash payloads.
  ///
  /// A customer's phone number is the most sensitive field in this system, and
  /// the raw one is not safer for being unparsed — it is the same human. The
  /// unmasked value stays available on [phone] for the code that dials it.
  @override
  String toString() =>
      'Customer($id, v$version, '
      '${phone?.toString() ?? 'unparsed'})';
}

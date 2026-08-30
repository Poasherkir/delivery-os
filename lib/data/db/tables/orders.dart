import 'package:drift/drift.dart';

import '../../../domain/state/order_status.dart';
import '../../../domain/value_objects/delivery_attempt_outcome.dart';
import '../../../domain/value_objects/delivery_type.dart';
import '../../../domain/value_objects/payment_method.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/owner_columns.dart';
import 'batches.dart';
import 'companies.dart';
import 'customers.dart';
import 'users.dart';

/// One parcel.
///
/// Every monetary column is `INTEGER` centimes through [CentimesConverter]
/// (invariant 1). There is no `double` anywhere on this table and there never
/// will be: a settlement that is off by one dinar costs the driver's trust
/// permanently.
///
/// Seven money columns, and they are not independent. `cod_amount` is what the
/// customer owes; `driver_commission` is the one value a rule evaluation
/// rounds; `company_amount` is the residual,
/// `cod_amount − driver_commission − other_fees`. Rounding two of them
/// independently is how `Σ company_amount + Σ driver_commission ==
/// Σ collected_amount` silently stops holding (§12.2).
class Orders extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get batchId =>
      text().withLength(min: 36, max: 36).references(Batches, #id)();

  /// Denormalized from the batch so a company-scoped query needs no join, and
  /// so an order can never be silently reattributed by moving its batch. §14:
  /// a company must never read another company's orders even though they share
  /// a driver.
  TextColumn get companyId =>
      text().withLength(min: 36, max: 36).references(Companies, #id)();

  /// Nullable: an order can be imported from a manifest before its customer
  /// record exists, and M1's entry flow must not block on that.
  TextColumn get customerId => text()
      .withLength(min: 36, max: 36)
      .nullable()
      .references(Customers, #id)();

  TextColumn get addressId => text()
      .withLength(min: 36, max: 36)
      .nullable()
      .references(CustomerAddresses, #id)();

  /// Unique per company, never globally (§14). Two companies can and do use
  /// the same number.
  TextColumn get trackingNumber => text().withLength(min: 1, max: 100)();

  /// Home or stop-desk. A stop-desk parcel never enters the optimizer but
  /// stays in the batch and in the money (§1.4).
  TextColumn get deliveryType => text()
      .map(
        const EnumTextConverter<DeliveryType>(
          DeliveryType.values,
          'DeliveryType',
        ),
      )
      .withDefault(const Constant('home'))();

  /// Never assigned directly — invariant 6 routes every change through
  /// `OrderStateMachine.transitionTo`.
  TextColumn get status => text()
      .map(
        const EnumTextConverter<OrderStatus>(OrderStatus.values, 'OrderStatus'),
      )
      .withDefault(const Constant('pending'))();

  /// A cost penalty in the optimizer, not a hard constraint (§10.1).
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// `HH:MM`, local. Time windows are a V2 feature; the columns exist because
  /// adding them later means migrating a driver's live data.
  TextColumn get windowStart => text().withLength(min: 5, max: 5).nullable()();

  TextColumn get windowEnd => text().withLength(min: 5, max: 5).nullable()();

  TextColumn get notes => text().nullable()();

  // --- money, all centimes -------------------------------------------------

  /// What the goods are worth. Not what is collected.
  IntColumn get productValue =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  /// What the customer owes at the door. Mutable with an audit trail: a
  /// merchant can negotiate a discount mid-delivery (§1.2).
  IntColumn get codAmount =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  IntColumn get deliveryFee =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  /// The residual: `cod_amount − driver_commission − other_fees`. Derived by
  /// subtraction, never rounded independently.
  IntColumn get companyAmount =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  /// The one value a rule evaluation rounds, once (§12.2).
  IntColumn get driverCommission =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  IntColumn get otherFees =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  /// What was actually taken. Differs from [codAmount] when a discount was
  /// negotiated, and the difference is what a settlement has to explain.
  IntColumn get collectedAmount =>
      integer().map(const CentimesConverter()).withDefault(const Constant(0))();

  /// Only cash moves the driver's cash-on-hand figure (§12.4).
  TextColumn get paymentMethod => text()
      .map(
        const EnumTextConverter<PaymentMethod>(
          PaymentMethod.values,
          'PaymentMethod',
        ),
      )
      .nullable()();

  /// Pinned at creation and never changed — invariant 8. Editing a company's
  /// rule creates version N+1 and leaves this alone, which is what keeps a
  /// months-old settlement reproducible.
  IntColumn get paymentRuleVersion => integer().nullable()();

  // --- outcome -------------------------------------------------------------

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  IntColumn get deliveredAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  /// The outcome of the most recent attempt — **any** attempt, not only a
  /// failed one. Null means never attempted.
  ///
  /// **This is a cache.** `delivery_attempts` is the record; this is a
  /// denormalization of its most recent row, so an order list renders without a
  /// join. Nothing derives money from it.
  ///
  /// **Written only by the transaction that inserts the attempt**, never set
  /// independently. That is the EntityStamper argument again: a cache
  /// maintained by convention drifts out of step with its source, a cache
  /// maintained by a single write path cannot.
  ///
  /// Populated on success as well as failure. A field that is only sometimes
  /// maintained is worse than one always maintained — a reader has to know
  /// which case they are in before they can trust it.
  TextColumn get lastAttemptOutcome => text()
      .map(
        const EnumTextConverter<DeliveryAttemptOutcome>(
          DeliveryAttemptOutcome.values,
          'DeliveryAttemptOutcome',
        ),
      )
      .nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{ownerId, companyId, trackingNumber},
  ];
}

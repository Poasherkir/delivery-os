import 'package:drift/drift.dart';

import '../../../domain/value_objects/centimes.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/owner_columns.dart';
import 'batches.dart';
import 'companies.dart';
import 'users.dart';

/// What the driver spent.
///
/// An owned mutable entity: a driver mistypes a fuel amount and fixes it. These
/// come off the driver's own earnings, never off the company's amount, which is
/// why they are their own table rather than another column on an order.
@TableIndex.sql(
  'CREATE INDEX idx_expenses_owner_date ON expenses (owner_id, service_date DESC)',
)
class Expenses extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  /// `YYYY-MM-DD`. Expenses belong to a business day, not to a batch — a tank
  /// of fuel covers every company the driver worked that day.
  TextColumn get serviceDate => text().withLength(min: 10, max: 10)();

  TextColumn get category => text().map(
    const EnumTextConverter<ExpenseCategory>(
      ExpenseCategory.values,
      'ExpenseCategory',
    ),
  )();

  IntColumn get amount => integer().map(const CentimesConverter())();

  TextColumn get note => text().nullable()();

  /// App-private path (§13).
  TextColumn get receiptPath => text().nullable()();
}

/// A frozen snapshot of what one batch produced.
///
/// **Append-only, and this is invariant 7 made structural.** Once a row exists
/// for a batch, the money for that day is decided. Corrections become
/// [SettlementAdjustments] rows; there is no update path and there never will
/// be one.
@TableIndex.sql(
  'CREATE INDEX idx_settlements_owner_date '
  'ON daily_settlements (owner_id, service_date DESC)',
)
class DailySettlements extends Table with UuidPrimaryKey, AppendOnlyColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  /// One settlement per batch, enforced.
  TextColumn get batchId =>
      text().withLength(min: 36, max: 36).references(Batches, #id).unique()();

  TextColumn get serviceDate => text().withLength(min: 10, max: 10)();

  IntColumn get ordersTotal => integer()();

  IntColumn get ordersDelivered => integer()();

  IntColumn get ordersFailed => integer()();

  IntColumn get ordersPending => integer()();

  /// What the day should have collected.
  IntColumn get expectedCollection =>
      integer().map(const CentimesConverter())();

  /// What it actually collected. The gap is what the driver and the agency
  /// argue about, and the reason this app exists.
  IntColumn get actualCollection => integer().map(const CentimesConverter())();

  IntColumn get companyAmount => integer().map(const CentimesConverter())();

  IntColumn get driverGross => integer().map(const CentimesConverter())();

  IntColumn get expensesAllocated => integer().map(const CentimesConverter())();

  IntColumn get driverNet => integer().map(const CentimesConverter())();

  /// The `payment_rules.rule_version` this was computed under. Business data,
  /// not an audit column.
  IntColumn get ruleVersion => integer()();

  /// The per-order breakdown, frozen as raw JSON.
  ///
  /// **Never a typed converter, for the same reason as `payment_rules.spec`
  /// and more sharply.** Freezing the snapshot is the entire point: it has to
  /// stay readable and reproducible years after the models that produced it
  /// have changed shape. If it deserializes through a live model, a refactor
  /// silently rewrites history — and this is the history a driver would take
  /// to an agency to prove they are owed money.
  TextColumn get snapshot => text()();

  /// sha256 of the canonical JSON of [snapshot]. What makes tampering
  /// detectable and what a server compares against at V2 rather than
  /// overwriting.
  TextColumn get contentHash => text().withLength(min: 64, max: 64)();

  IntColumn get confirmedAt =>
      integer().map(const UtcMillisecondsConverter())();
}

/// A correction to a settled day.
///
/// Append-only, and never deleted. The only way to change a confirmed
/// settlement is to add one of these beside it, so the original figure and the
/// correction both survive — which is what lets a disagreement be reconstructed
/// rather than argued from memory.
class SettlementAdjustments extends Table
    with UuidPrimaryKey, AppendOnlyColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get settlementId =>
      text().withLength(min: 36, max: 36).references(DailySettlements, #id)();

  /// Signed. A correction can go either way, which is why [Centimes] permits
  /// negatives at all.
  IntColumn get amount => integer().map(const CentimesConverter())();

  TextColumn get reason => text().withLength(min: 1, max: 500)();
}

/// Cash physically handed to a company. A *versement*.
///
/// **An owned mutable entity, deliberately, unlike a settlement.** A settlement
/// is computed and frozen; a remittance is hand-entered cash, and typos are
/// certain — a driver has to be able to fix 45 000 to 45 500 thirty seconds
/// later. The control is not immutability but the audit trail: **every edit
/// writes an `audit_logs` row.**
///
/// A remittance is not tied to a batch or a day. The driver may hold cash for
/// two or three days and then settle several batches at once, which is why
/// [coversFrom] and [coversTo] are a range rather than a foreign key (§1.3).
@TableIndex.sql(
  'CREATE INDEX idx_remit_owner_company '
  'ON remittances (owner_id, company_id, remitted_at DESC)',
)
class Remittances extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get companyId =>
      text().withLength(min: 36, max: 36).references(Companies, #id)();

  IntColumn get amount => integer().map(const CentimesConverter())();

  TextColumn get method => text().map(
    const EnumTextConverter<RemittanceMethod>(
      RemittanceMethod.values,
      'RemittanceMethod',
    ),
  )();

  /// Transfer reference or receipt number, as written on the paper.
  TextColumn get reference => text().nullable()();

  TextColumn get receiptPath => text().nullable()();

  /// The span of business days this payment covers. Nullable because a driver
  /// often hands over a round number without attributing it to specific days.
  TextColumn get coversFrom => text().withLength(min: 10, max: 10).nullable()();

  TextColumn get coversTo => text().withLength(min: 10, max: 10).nullable()();

  IntColumn get remittedAt => integer().map(const UtcMillisecondsConverter())();
}

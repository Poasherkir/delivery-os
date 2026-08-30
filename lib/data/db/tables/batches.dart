import 'package:drift/drift.dart';

import '../../../domain/value_objects/batch_status.dart';
import '../conventions/audit_columns.dart';
import '../conventions/converters.dart';
import '../conventions/owner_columns.dart';
import 'companies.dart';
import 'users.dart';

/// One driver, one company, one service date.
///
/// The unit of daily work and the unit of settlement (§2.1). A driver working
/// two companies in one day has **two batches and one route** — the route spans
/// batches, which is easy to get wrong and expensive to fix later.
@DataClassName('Batch')
class Batches extends Table with UuidPrimaryKey, OwnedMutableColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get companyId =>
      text().withLength(min: 36, max: 36).references(Companies, #id)();

  /// The business day, `YYYY-MM-DD`. Not a timestamp: a delivery at 00:30
  /// belongs to the previous working day, so the calendar date is its own fact
  /// rather than something derived from an instant (§6.1).
  TextColumn get serviceDate => text().withLength(min: 10, max: 10)();

  /// open, closed, settled. A batch cannot reach `closed` while any of its
  /// orders is in an open state, and `settled` freezes it: corrections after
  /// that become `settlement_adjustments` rows, never edits (invariant 7).
  TextColumn get status => text()
      .map(
        const EnumTextConverter<BatchStatus>(BatchStatus.values, 'BatchStatus'),
      )
      .withDefault(const Constant('open'))();

  IntColumn get closedAt =>
      integer().map(const UtcMillisecondsConverter()).nullable()();

  /// One batch per company per day. Re-importing a manifest must find the
  /// existing batch rather than opening a second one beside it.
  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{ownerId, companyId, serviceDate},
  ];
}

import 'package:drift/drift.dart';

import '../conventions/audit_columns.dart';
import '../conventions/owner_columns.dart';
import 'companies.dart';
import 'users.dart';

/// A versioned commission rule for one company.
///
/// **Append-only** — invariant 3, category 2. `owner_id` and `created_at` and
/// nothing else: no `updated_at`, no audit `version`, no soft delete, and no
/// update path in the DAO when it arrives. Editing a company's rule creates a
/// new row at the next [ruleVersion]; it never touches an existing one.
///
/// That is invariant 8 made structural rather than remembered. An order pins
/// `payment_rule_version` at creation, and a settlement computed from it has to
/// stay reproducible months later — which is impossible if the row it was
/// computed from can be edited.
class PaymentRules extends Table with UuidPrimaryKey, AppendOnlyColumns {
  @override
  TextColumn get ownerId =>
      text().withLength(min: 36, max: 36).references(Users, #id)();

  TextColumn get companyId =>
      text().withLength(min: 36, max: 36).references(Companies, #id)();

  /// The rule's own version number.
  ///
  /// **Business data, not the audit column from invariant 3.** This is the
  /// value `orders.payment_rule_version` pins. It is called `rule_version`
  /// rather than `version` precisely because the collision would otherwise get
  /// "fixed" one day by attaching an `EntityStamper` to it — which would make
  /// a company's rule history mutable and break every historical settlement.
  IntColumn get ruleVersion => integer()();

  /// The rule document, as raw JSON.
  ///
  /// **Deliberately not deserialized through a typed converter**, which is what
  /// this column most looks like it wants.
  ///
  /// Specs are pinned per order, and §12.2 requires that editing a company's
  /// rule never changes a historical settlement. A typed column binds every
  /// stored row to whatever shape the model has *today*: the day the spec gains
  /// a field or renames one, every historical rule becomes unreadable or —
  /// worse — silently reinterpreted, and the settlements computed from them can
  /// no longer be reproduced or audited.
  ///
  /// So the column stores bytes and the domain decides meaning. The document's
  /// own `version` field tells a version-aware parser which shape to expect,
  /// at the use site, in M3.
  TextColumn get spec => text()();

  /// A calendar date, `YYYY-MM-DD`. Not a timestamp: a rule takes effect on a
  /// day, not at an instant, and giving it a time invites timezone confusion
  /// for no benefit (§6.1).
  TextColumn get effectiveFrom => text().withLength(min: 10, max: 10)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{companyId, ruleVersion},
  ];
}

import 'package:drift/drift.dart';

// Used by the generated part, not by this file directly. Drift emits its code
// as a `part`, so any type a column converter produces has to be visible from
// the library the part belongs to.
import '../../domain/value_objects/phone_e164.dart';
import 'conventions/converters.dart';
import 'tables/companies.dart';
import 'tables/geography.dart';
import 'tables/payment_rules.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// The local database. Schema version 1.
///
/// Tables arrive across M0-15 to M0-17 and the schema stays at version 1
/// throughout, because nothing has shipped — there is no installed copy to
/// migrate from. Indexes, the migration strategy and the encrypted open land in
/// M0-18 and M0-19.
@DriftDatabase(
  tables: <Type>[Users, Companies, PaymentRules, Wilayas, Communes],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

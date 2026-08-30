import 'package:drift/drift.dart';

// Used by the generated part, not by this file directly. Drift emits its code
// as a `part`, so any type a column converter produces has to be visible from
// the library the part belongs to.
import '../../domain/state/order_status.dart';
import '../../domain/value_objects/batch_status.dart';
import '../../domain/value_objects/centimes.dart';
import '../../domain/value_objects/customer_risk_flag.dart';
import '../../domain/value_objects/delivery_attempt_outcome.dart';
import '../../domain/value_objects/delivery_type.dart';
import '../../domain/value_objects/geo_confidence.dart';
import '../../domain/value_objects/ledger_enums.dart';
import '../../domain/value_objects/payment_method.dart';
import '../../domain/value_objects/phone_e164.dart';
import '../../domain/value_objects/route_status.dart';
import 'conventions/converters.dart';
import 'tables/batches.dart';
import 'tables/companies.dart';
import 'tables/customers.dart';
import 'tables/delivery.dart';
import 'tables/geography.dart';
import 'tables/ledger.dart';
import 'tables/orders.dart';
import 'tables/payment_rules.dart';
import 'tables/routes.dart';
import 'tables/sync.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// The local database. Schema version 1.
///
/// Tables arrive across M0-15 to M0-17 and the schema stays at version 1
/// throughout, because nothing has shipped — there is no installed copy to
/// migrate from. Indexes, the migration strategy and the encrypted open land in
/// M0-18 and M0-19.
@DriftDatabase(
  tables: <Type>[
    Users,
    Companies,
    PaymentRules,
    Wilayas,
    Communes,
    Customers,
    CustomerAddresses,
    Batches,
    Orders,
    DeliveryAttempts,
    ProofOfDelivery,
    Routes,
    RouteStops,
    MatrixCache,
    Expenses,
    DailySettlements,
    SettlementAdjustments,
    Remittances,
    Outbox,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

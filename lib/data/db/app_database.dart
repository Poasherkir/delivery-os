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

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),

    // Every one of these is **per connection**, not a property of the file, so
    // they are set on open rather than once at creation. `journal_mode` is the
    // exception — it persists — but setting it again costs nothing and means
    // one place to read rather than two.
    //
    // They are asserted from an *opened database* in the schema test rather
    // than trusted here, because this is exactly the code that gets refactored
    // and silently dropped.
    beforeOpen: (OpeningDetails details) async {
      // SQLite ignores foreign keys unless asked. Without this every
      // REFERENCES clause in the schema is decoration, and an orphaned
      // order_id would sit there until something tried to read through it.
      //
      // A no-op inside a transaction, which is why it belongs here.
      await customStatement('PRAGMA foreign_keys = ON');

      // The phone is dropped, run flat, and killed by an OEM task manager
      // mid-shift. WAL survives all three materially better than the rollback
      // journal, and it lets a read proceed while a write is in flight.
      await customStatement('PRAGMA journal_mode = WAL');

      // FULL, not the usual NORMAL, and this is the one place the slower
      // setting is wanted.
      //
      // With WAL and NORMAL, an OS crash or sudden power loss can lose the
      // last committed transaction. Here that transaction is a driver marking
      // a parcel delivered and 6 400 DA collected — a record that exists
      // nowhere else, in an app whose entire claim is that the money
      // reconciles. Writes are small and infrequent; a few milliseconds per
      // commit is invisible and losing a delivery is not.
      //
      // Do not "optimize" this back to NORMAL.
      await customStatement('PRAGMA synchronous = FULL');
    },
  );
}

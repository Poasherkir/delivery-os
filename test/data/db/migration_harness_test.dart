import 'package:delivery_os/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'schema_versions/schema.dart';
import 'schema_versions/schema_v1.dart' as v1;

String _id(int n) => '0199a1b2-c3d4-7000-8000-${n.toString().padLeft(12, '0')}';

/// A payment rule spec carrying a field no build has ever seen.
///
/// The same document used in M0-15's table test, on purpose: reproducibility of
/// a historical settlement has to survive **schema evolution**, not only schema
/// stasis. A migration that silently reshaped this would break every settlement
/// computed under it, months after the fact.
const String _futureSpec =
    '{"version":9,"delivered":{"driver_commission":'
    '{"type":"invented_in_2028","amount":30000}},"unknown_field":true}';

/// The frozen per-order breakdown, likewise.
const String _futureSnapshot =
    '{"version":42,"orders":[{"id":"x","invented_field":true}],'
    '"totals":{"unknown":1}}';

/// Money seeded deliberately negative and deliberately not round.
///
/// A converter quietly changing its type or its sign handling is the migration
/// failure this project can least afford, and `0` or `1000` would survive both
/// mistakes without complaint.
const int _cod = -640127;
const int _commission = -30089;
const int _adjustment = -15073;

/// The strictest verification drift offers, applied to every check here.
///
/// Both defaults are wrong for a guard. `validateDropped` is off by default, so
/// a table deleted from the Dart but left behind by a migration would pass
/// silently — exactly the residue a migration is most likely to leave.
/// `validateColumnConstraints` is on by default and is spelled out anyway,
/// because a default that flips in a future drift is a guard that quietly stops
/// checking `NOT NULL`, defaults and uniqueness.
const ValidationOptions _strict = ValidationOptions(
  validateDropped: true,
  validateColumnConstraints: true,
);

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());

    // A migration test necessarily opens the same database more than once —
    // seed it at the old version, migrate, reopen and read it back. Drift's
    // warning about that is right in an app and wrong here, and pages of it
    // would bury the one line that actually says what diverged.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  group('the committed dump describes the live schema', () {
    test(
      'a database built from the Dart matches drift_schema_v1.json',
      () async {
        // The guard on the harness itself. Without it, somebody adds a column,
        // forgets to regenerate the dump, and every migration test afterwards
        // validates against a database that no longer exists — passing while
        // describing fiction.
        //
        // migrateAndValidate builds a reference from the dump, opens this
        // database (whose onCreate runs createAll from the table definitions),
        // and compares the two.
        final AppDatabase db = AppDatabase(NativeDatabase.memory());
        await verifier.migrateAndValidate(db, 1, options: _strict);
        await db.close();
      },
    );

    test('the helper knows exactly the versions that are dumped', () {
      // A version present in code but absent from drift_schema/ would fail at
      // migration time on a driver's phone rather than here.
      expect(GeneratedHelper.versions, <int>[1]);
    });
  });

  group('a seeded database survives a migration', () {
    /// Seeds one row in every table, in literal v1 SQL.
    ///
    /// Raw SQL rather than the typed API on purpose: the fixture has to pin the
    /// **v1 shape**, so a renamed column fails here loudly instead of quietly
    /// adapting through whatever the current model happens to be.
    Future<void> seed(v1.DatabaseAtV1 db) async {
      Future<void> run(String sql) => db.customStatement(sql);

      await run(
        'INSERT INTO users (id, phone, display_name, locale, created_at, '
        'updated_at, deleted_at) VALUES '
        "('${_id(1)}', '+213550123456', 'Malik', 'fr', 1000, 2000, NULL)",
      );
      await run(
        'INSERT INTO companies (id, owner_id, name, logo_path, contact_phone, '
        'notes, is_active, created_at, updated_at, deleted_at, version) VALUES '
        "('${_id(2)}', '${_id(1)}', 'Yalidine', '/logo.png', "
        "'0770 11 22 33', 'note', 0, 1000, 2000, 3000, 7)",
      );
      await run(
        'INSERT INTO payment_rules (id, owner_id, company_id, rule_version, '
        'spec, effective_from, created_at) VALUES '
        "('${_id(3)}', '${_id(1)}', '${_id(2)}', 9, '$_futureSpec', "
        "'2026-08-30', 1000)",
      );
      await run(
        'INSERT INTO wilayas (code, name_fr, name_ar, latitude, longitude, '
        "geohash) VALUES (16, 'Alger', 'الجزائر', 36.7538, 3.0588, 'snd1jdg67')",
      );
      await run(
        'INSERT INTO communes (id, wilaya_code, name_fr, name_ar, latitude, '
        'longitude, geohash, boundary) VALUES '
        "(1601, 16, 'Bab Ezzouar', 'باب الزوار', 36.72, 3.19, 'sndj', "
        '\'{"type":"Polygon"}\')',
      );
      await run(
        'INSERT INTO customers (id, owner_id, phone_e164, phone_alt, '
        'display_name, notes, risk_flag, total_orders, total_delivered, '
        'total_failed, last_delivered_at, created_at, updated_at, deleted_at, '
        'version) VALUES '
        "('${_id(4)}', '${_id(1)}', '+213660123456', '+213770123456', "
        "'Amine', 'careful', 'problem', 12, 9, 3, 5000, 1000, 2000, NULL, 4)",
      );
      await run(
        'INSERT INTO customer_addresses (id, owner_id, customer_id, '
        'wilaya_code, commune_id, detail, latitude, longitude, geohash, '
        'accuracy_m, geo_confidence, geo_source, confirmed_deliveries, label, '
        'is_primary, created_at, updated_at, deleted_at, version) VALUES '
        "('${_id(5)}', '${_id(1)}', '${_id(4)}', 16, 1601, 'Bt 12', "
        "36.7231, 3.1899, 'sndjq7xyz', 12, 4, 'gps', 3, 'maison', 1, "
        '1000, 2000, NULL, 6)',
      );
      await run(
        'INSERT INTO batches (id, owner_id, company_id, service_date, status, '
        'closed_at, created_at, updated_at, deleted_at, version) VALUES '
        "('${_id(6)}', '${_id(1)}', '${_id(2)}', '2026-08-30', 'settled', "
        '9000, 1000, 2000, NULL, 3)',
      );
      await run(
        'INSERT INTO orders (id, owner_id, batch_id, company_id, customer_id, '
        'address_id, tracking_number, delivery_type, status, priority, '
        'window_start, window_end, notes, product_value, cod_amount, '
        'delivery_fee, company_amount, driver_commission, other_fees, '
        'collected_amount, payment_method, payment_rule_version, '
        'attempt_count, delivered_at, last_attempt_outcome, created_at, '
        'updated_at, deleted_at, version) VALUES '
        "('${_id(7)}', '${_id(1)}', '${_id(6)}', '${_id(2)}', '${_id(4)}', "
        "'${_id(5)}', 'YAL-0001', 'stopdesk', 'returnedToAgency', 2, "
        "'09:00', '12:00', 'fragile', -123457, $_cod, -4211, -610038, "
        "$_commission, -1013, $_cod, 'transfer', 9, 3, 8000, "
        "'wrongAddress', 1000, 2000, NULL, 5)",
      );
      await run(
        'INSERT INTO delivery_attempts (id, owner_id, order_id, attempt_no, '
        'outcome, outcome_note, latitude, longitude, geohash, accuracy_m, '
        'occurred_at, created_at) VALUES '
        "('${_id(8)}', '${_id(1)}', '${_id(7)}', 3, 'refused', 'no cash', "
        "36.72, 3.18, 'sndjq', 45, 7000, 7100)",
      );
      await run(
        'INSERT INTO proof_of_delivery (id, owner_id, order_id, photo_path, '
        'signature_path, latitude, longitude, captured_at, driver_note, '
        'uploaded, created_at) VALUES '
        "('${_id(9)}', '${_id(1)}', '${_id(7)}', '/pod.jpg', NULL, "
        "36.72, 3.18, 8000, 'left with neighbour', 1, 8100)",
      );
      await run(
        'INSERT INTO routes (id, owner_id, service_date, status, '
        'origin_latitude, origin_longitude, total_distance_m, '
        'total_duration_s, optimized_at, started_at, completed_at, algorithm, '
        'created_at, updated_at, deleted_at, version) VALUES '
        "('${_id(10)}', '${_id(1)}', '2026-08-30', 'completed', 36.75, 3.05, "
        "76400, 10080, 6000, 6100, 9000, 'dart-2opt-v1', 1000, 2000, NULL, 2)",
      );
      await run(
        'INSERT INTO route_stops (id, route_id, order_id, sequence, '
        'leg_distance_m, leg_duration_s, eta, arrived_at, departed_at, '
        'is_locked, created_at, updated_at) VALUES '
        "('${_id(11)}', '${_id(10)}', '${_id(7)}', 4, 3200, 420, 6500, "
        '6600, 6700, 1, 1000, 2000)',
      );
      await run(
        'INSERT INTO matrix_cache (id, point_hash, durations, distances, '
        'provider, fetched_at) VALUES '
        "('${_id(12)}', '${'c' * 64}', '[[0,420],[420,0]]', "
        "'[[0,3200],[3200,0]]', 'mapbox', 5000)",
      );
      await run(
        'INSERT INTO expenses (id, owner_id, service_date, category, amount, '
        'note, receipt_path, created_at, updated_at, deleted_at, version) '
        "VALUES ('${_id(13)}', '${_id(1)}', '2026-08-30', 'maintenance', "
        "-88213, 'brake pads', '/r.jpg', 1000, 2000, NULL, 2)",
      );
      await run(
        'INSERT INTO daily_settlements (id, owner_id, batch_id, service_date, '
        'orders_total, orders_delivered, orders_failed, orders_pending, '
        'expected_collection, actual_collection, company_amount, driver_gross, '
        'expenses_allocated, driver_net, rule_version, snapshot, content_hash, '
        'confirmed_at, created_at) VALUES '
        "('${_id(14)}', '${_id(1)}', '${_id(6)}', '2026-08-30', 15, 13, 2, 0, "
        '-6000119, -5850071, -5460033, -390047, -120019, -270028, 9, '
        "'$_futureSnapshot', '${'a' * 64}', 9500, 9600)",
      );
      await run(
        'INSERT INTO settlement_adjustments (id, owner_id, settlement_id, '
        'amount, reason, created_at) VALUES '
        "('${_id(15)}', '${_id(1)}', '${_id(14)}', $_adjustment, "
        "'agency recounted', 9700)",
      );
      await run(
        'INSERT INTO remittances (id, owner_id, company_id, amount, method, '
        'reference, receipt_path, covers_from, covers_to, remitted_at, '
        'created_at, updated_at, deleted_at, version) VALUES '
        "('${_id(16)}', '${_id(1)}', '${_id(2)}', -4550031, 'baridimob', "
        "'REF-9', '/rec.jpg', '2026-08-28', '2026-08-30', 9800, 1000, 2000, "
        'NULL, 3)',
      );
      await run(
        'INSERT INTO outbox (id, entity_type, entity_id, operation, payload, '
        'device_id, created_at, attempts, last_error, synced_at) VALUES '
        "('${_id(17)}', 'order', '${_id(7)}', 'command', "
        '\'{"collected":-640127}\', \'device-1\', 1000, 2, \'timeout\', NULL)',
      );
      await run(
        'INSERT INTO audit_logs (id, owner_id, entity_type, entity_id, action, '
        'before, after, occurred_at, created_at) VALUES '
        "('${_id(18)}', '${_id(1)}', 'remittance', '${_id(16)}', "
        '\'remittance.amend\', \'{"amount":-4500000}\', '
        '\'{"amount":-4550031}\', 9900, 9950)',
      );
    }

    test('every row and every value comes through unchanged', () async {
      // The identity case: v1 to v1, so nothing should change. That is the
      // point — it proves the harness itself works before there is a real
      // migration to trust it with. M1's raw-phone column is its first real
      // customer.
      final InitializedSchema schema = await verifier.schemaAt(1);

      final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
      await seed(old);
      await old.close();

      final AppDatabase migrated = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(migrated, 1, options: _strict);
      await migrated.close();

      final AppDatabase after = AppDatabase(schema.newConnection());
      addTearDown(after.close);

      // Every table still holds its row.
      for (final TableInfo<Table, Object?> table in after.allTables) {
        final QueryRow row = await after
            .customSelect('SELECT count(*) c FROM ${table.actualTableName}')
            .getSingle();
        expect(
          row.read<int>('c'),
          1,
          reason: '${table.actualTableName} lost its row',
        );
      }
    });

    test('negative, non-round money is intact to the centime', () async {
      final InitializedSchema schema = await verifier.schemaAt(1);
      final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
      await seed(old);
      await old.close();

      final AppDatabase migrated = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(migrated, 1, options: _strict);
      await migrated.close();

      final AppDatabase after = AppDatabase(schema.newConnection());
      addTearDown(after.close);

      final QueryRow order = await after
          .customSelect(
            'SELECT cod_amount, driver_commission, company_amount, '
            'collected_amount FROM orders',
          )
          .getSingle();

      expect(order.read<int>('cod_amount'), _cod);
      expect(order.read<int>('driver_commission'), _commission);
      expect(order.read<int>('company_amount'), -610038);
      // A converter that flipped a sign or truncated would not survive this.
      expect(
        order.read<int>('cod_amount') + order.read<int>('driver_commission'),
        _cod + _commission,
      );

      expect(
        (await after
                .customSelect('SELECT amount FROM settlement_adjustments')
                .getSingle())
            .read<int>('amount'),
        _adjustment,
      );
      expect(
        (await after
                .customSelect('SELECT driver_net FROM daily_settlements')
                .getSingle())
            .read<int>('driver_net'),
        -270028,
      );
    });

    test('frozen JSON survives byte for byte', () async {
      // Reproducibility of a historical settlement has to survive schema
      // evolution, not only schema stasis. Both documents carry fields no
      // build has ever seen.
      final InitializedSchema schema = await verifier.schemaAt(1);
      final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
      await seed(old);
      await old.close();

      final AppDatabase migrated = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(migrated, 1, options: _strict);
      await migrated.close();

      final AppDatabase after = AppDatabase(schema.newConnection());
      addTearDown(after.close);

      expect(
        (await after.customSelect('SELECT spec FROM payment_rules').getSingle())
            .read<String>('spec'),
        _futureSpec,
      );
      expect(
        (await after
                .customSelect('SELECT snapshot FROM daily_settlements')
                .getSingle())
            .read<String>('snapshot'),
        _futureSnapshot,
      );
    });

    test('non-default audit values are not reset by the migration', () async {
      // A migration that recreated a table with defaults would look like a
      // success and quietly reset every version counter and soft delete.
      final InitializedSchema schema = await verifier.schemaAt(1);
      final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
      await seed(old);
      await old.close();

      final AppDatabase migrated = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(migrated, 1, options: _strict);
      await migrated.close();

      final AppDatabase after = AppDatabase(schema.newConnection());
      addTearDown(after.close);

      final QueryRow company = await after
          .customSelect('SELECT version, deleted_at, is_active FROM companies')
          .getSingle();

      expect(company.read<int>('version'), 7);
      expect(company.read<int>('deleted_at'), 3000);
      expect(company.read<int>('is_active'), 0);

      final QueryRow address = await after
          .customSelect(
            'SELECT geo_confidence, accuracy_m FROM customer_addresses',
          )
          .getSingle();
      expect(address.read<int>('geo_confidence'), 4);
      expect(address.read<int>('accuracy_m'), 12);
    });
  });
}

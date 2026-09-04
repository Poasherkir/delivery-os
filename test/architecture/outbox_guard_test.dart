import 'dart:io';

import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/data/db/daos/user_settings_dao.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart' hide isNotNull, Batch;
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// Invariant 5, made mechanical: **every mutation writes an outbox row.**
///
/// Until now this was a habit checked per site — the enforcement table in
/// `CLAUDE.md` said so. A habit does not survive the twentieth DAO method
/// written on a Friday, and the failure is silent: the entity write lands, the
/// queue does not, and nothing anywhere notices until V2 sync goes looking for
/// a command that was never recorded.
///
/// Two halves, and neither works alone:
///
/// 1. **A scan** finds every method in `lib/data/db/daos/` that writes. This is
///    the subject set, discovered rather than listed, so a new method cannot
///    escape by not being added anywhere.
/// 2. **A registry** below actually invokes each one and asserts the queue grew
///    by exactly one row. A scanned writer with no entry fails.
///
/// The scan alone would be satisfiable by a method that mentions `outbox` in a
/// comment. The registry alone would be an allowlist that a new method simply
/// never joins. Together they fail closed.
///
/// **Deliberately outside this**: `AppBootstrap.ensureUser` and `GeoLoader`,
/// both of which write and both of which correctly queue nothing. They are not
/// in `daos/`, and each has its own test saying why — bootstrap is not a driver
/// mutation, and bundled reference data never syncs.

/// One exercised mutation.
///
/// [prepare] runs *before* the queue is measured. Without that split, a test
/// for `edit` would count the `create` it needed to have something to edit, and
/// the assertion would be "two rows appeared" rather than "this method queued
/// one" — which is a different claim and a weaker one.
typedef _Mutation = ({
  String dao,
  String method,
  Future<Customer?> Function(_Fixture f)? prepare,
  Future<void> Function(_Fixture f, Customer? prepared) invoke,
});

final class _Fixture {
  _Fixture(this.db, this.clock, this.uuid, this.userId);

  final AppDatabase db;
  final FixedClock clock;
  final UuidV7Generator uuid;
  final String userId;

  /// Carried from prepare to invoke for the mutations that need an existing
  /// address to act on.
  CustomerAddress? pendingAddress;

  /// Same, for the mutations that need an existing company.
  Company? pendingCompany;

  /// Same, for the mutations that need an existing order.
  Order? pendingOrder;

  /// Same, for the mutations that act on a batch.
  Batch? pendingBatch;

  CustomerDao get customers => CustomerDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  AddressDao get addresses => AddressDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  /// An address needs a commune, which needs a wilaya, and foreign keys are on.
  Future<CustomerAddress> anAddress(Customer customer) => addresses.create(
    ownerId: userId,
    customerId: customer.id,
    wilayaCode: 16,
    communeId: 1601,
  );

  CompanyDao get companies => CompanyDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  BatchDao get batches => BatchDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  Future<Company> aCompany([String name = 'Yalidine']) =>
      companies.create(ownerId: userId, name: name);

  OrderDao get orders => OrderDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  /// An order needs a batch, which needs a company. Foreign keys are on.
  Future<Order> anOrder([String tracking = 'YAL-0001']) async {
    final Company company = await aCompany('Yalidine');
    final Batch batch = await batches.ensureOpenBatch(
      ownerId: userId,
      companyId: company.id,
      serviceDate: '2026-09-01',
    );
    return orders.create(
      ownerId: userId,
      batchId: batch.id,
      companyId: company.id,
      trackingNumber: tracking,
    );
  }

  UserSettingsDao get settings => UserSettingsDao(
    database: db,
    clock: clock,
    uuid: uuid,
    deviceId: 'guard-device',
  );

  Future<Customer> aCustomer([String phone = '0550111222']) => customers.create(
    ownerId: userId,
    phone: PhoneE164.parse(phone),
    displayName: 'Amine',
  );
}

/// Every mutation, and how to run it. A scanned writer missing from here fails
/// the coverage test below.
final List<_Mutation> _mutations = <_Mutation>[
  (
    dao: 'CustomerDao',
    method: 'create',
    prepare: null,
    invoke: (_Fixture f, Customer? _) => f.aCustomer(),
  ),
  (
    dao: 'CustomerDao',
    method: 'edit',
    prepare: (_Fixture f) => f.aCustomer('0550333444'),
    invoke: (_Fixture f, Customer? c) =>
        f.customers.edit(current: c!, riskFlag: CustomerRiskFlag.watch),
  ),
  (
    dao: 'CustomerDao',
    method: 'softDelete',
    prepare: (_Fixture f) => f.aCustomer('0550555666'),
    invoke: (_Fixture f, Customer? c) => f.customers.softDelete(c!),
  ),
  (
    dao: 'CustomerDao',
    method: 'createUnparsed',
    prepare: null,
    invoke: (_Fixture f, Customer? _) => f.customers.createUnparsed(
      ownerId: f.userId,
      rawPhone: '021 44 55 66',
      displayName: 'Landline',
    ),
  ),
  (
    dao: 'CustomerDao',
    method: 'resolvePhone',
    prepare: (_Fixture f) => f.customers.createUnparsed(
      ownerId: f.userId,
      rawPhone: '021 77 88 99',
      displayName: 'Landline',
    ),
    invoke: (_Fixture f, Customer? c) => f.customers.resolvePhone(
      current: c!,
      phone: PhoneE164.parse('0550777888'),
    ),
  ),
  (
    dao: 'CompanyDao',
    method: 'create',
    prepare: null,
    invoke: (_Fixture f, Customer? _) => f.aCompany(),
  ),
  (
    dao: 'CompanyDao',
    method: 'edit',
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('ZR Express');
      return null;
    },
    invoke: (_Fixture f, Customer? _) =>
        f.companies.edit(current: f.pendingCompany!, notes: 'Bab Ezzouar hub'),
  ),
  (
    dao: 'CompanyDao',
    method: 'softDelete',
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('Anderson');
      return null;
    },
    invoke: (_Fixture f, Customer? _) =>
        f.companies.softDelete(f.pendingCompany!),
  ),
  (
    dao: 'BatchDao',
    method: 'ensureOpenBatch',
    // The company is made in prepare because creating it queues a row of its
    // own. Only the batch's own command may be counted.
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('Yalidine');
      return null;
    },
    invoke: (_Fixture f, Customer? _) => f.batches.ensureOpenBatch(
      ownerId: f.userId,
      companyId: f.pendingCompany!.id,
      serviceDate: '2026-09-01',
    ),
  ),
  (
    dao: 'BatchDao',
    method: 'close',
    // The batch is opened in prepare because opening queues a row of its own.
    // It closes with no orders on it: the precondition has its own tests, and
    // this one is only asking whether closing queues exactly one command.
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('Yalidine');
      f.pendingBatch = await f.batches.ensureOpenBatch(
        ownerId: f.userId,
        companyId: f.pendingCompany!.id,
        serviceDate: '2026-09-01',
      );
      return null;
    },
    invoke: (_Fixture f, Customer? _) => f.batches.close(f.pendingBatch!),
  ),
  (
    dao: 'BatchDao',
    method: 'reopen',
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('Yalidine');
      final Batch opened = await f.batches.ensureOpenBatch(
        ownerId: f.userId,
        companyId: f.pendingCompany!.id,
        serviceDate: '2026-09-01',
      );
      f.pendingBatch = await f.batches.close(opened);
      return null;
    },
    invoke: (_Fixture f, Customer? _) => f.batches.reopen(f.pendingBatch!),
  ),
  (
    dao: 'OrderDao',
    method: 'create',
    // The company and the batch are made in prepare because each queues a row
    // of its own. Only the order's own command may be counted.
    prepare: (_Fixture f) async {
      f.pendingCompany = await f.aCompany('Yalidine');
      await f.batches.ensureOpenBatch(
        ownerId: f.userId,
        companyId: f.pendingCompany!.id,
        serviceDate: '2026-09-01',
      );
      return null;
    },
    invoke: (_Fixture f, Customer? _) async {
      final Batch batch = await f.batches.ensureOpenBatch(
        ownerId: f.userId,
        companyId: f.pendingCompany!.id,
        serviceDate: '2026-09-01',
      );
      await f.orders.create(
        ownerId: f.userId,
        batchId: batch.id,
        companyId: f.pendingCompany!.id,
        trackingNumber: 'YAL-0001',
      );
    },
  ),
  (
    dao: 'OrderDao',
    method: 'softDelete',
    prepare: (_Fixture f) async {
      f.pendingOrder = await f.anOrder('YAL-0002');
      return null;
    },
    invoke: (_Fixture f, Customer? _) => f.orders.softDelete(f.pendingOrder!),
  ),
  (
    dao: 'UserSettingsDao',
    method: 'setLocale',
    prepare: null,
    invoke: (_Fixture f, Customer? _) => f.settings.setLocale('fr'),
  ),
  (
    dao: 'AddressDao',
    method: 'create',
    prepare: (_Fixture f) => f.aCustomer('0550777888'),
    invoke: (_Fixture f, Customer? c) => f.anAddress(c!),
  ),
  (
    dao: 'AddressDao',
    method: 'makePrimary',
    // The address is made in prepare, not in invoke: creating it queues a row
    // of its own, and counting that would assert "two rows appeared" rather
    // than "this method queued one".
    prepare: (_Fixture f) async {
      final Customer c = await f.aCustomer('0550777999');
      f.pendingAddress = await f.anAddress(c);
      return c;
    },
    invoke: (_Fixture f, Customer? _) =>
        f.addresses.makePrimary(f.pendingAddress!),
  ),
  (
    dao: 'AddressDao',
    method: 'edit',
    prepare: (_Fixture f) async {
      final Customer c = await f.aCustomer('0550888111');
      f.pendingAddress = await f.anAddress(c);
      return c;
    },
    invoke: (_Fixture f, Customer? _) =>
        f.addresses.edit(current: f.pendingAddress!, detail: 'Bt 12'),
  ),
  (
    dao: 'AddressDao',
    method: 'softDelete',
    prepare: (_Fixture f) async {
      final Customer c = await f.aCustomer('0550888222');
      f.pendingAddress = await f.anAddress(c);
      return c;
    },
    invoke: (_Fixture f, Customer? _) =>
        f.addresses.softDelete(f.pendingAddress!),
  ),
];

/// Methods that write but must not queue, each with the reason it is exempt.
/// Adding a name here is a deliberate, reviewable line — the same shape as the
/// permission allowlist.
const Map<String, String> _exempt = <String, String>{};

void main() {
  late AppDatabase db;
  late _Fixture fixture;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 1, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(db, clock, uuid).ensureUser();
    // Foreign keys are on, so an address needs somewhere to point.
    await db.customStatement(
      "INSERT INTO wilayas (code, name_fr, name_ar) VALUES (16, 'Alger', 'x')",
    );
    await db.customStatement(
      'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
      "VALUES (1601, 16, 'Bab Ezzouar', 'x')",
    );
    fixture = _Fixture(db, clock, uuid, user.id);
  });

  tearDown(() => db.close());

  Future<int> outboxCount() async =>
      (await db.customSelect('SELECT count(*) c FROM outbox').getSingle())
          .read<int>('c');

  group('every registered mutation queues exactly one command', () {
    for (final _Mutation m in _mutations) {
      test('${m.dao}.${m.method}', () async {
        final Customer? prepared = await m.prepare?.call(fixture);
        final int before = await outboxCount();

        await m.invoke(fixture, prepared);

        final int after = await outboxCount();
        expect(
          after - before,
          1,
          reason:
              '${m.dao}.${m.method} wrote an entity without queuing exactly '
              'one outbox row. Invariant 5.',
        );
      });
    }
  });

  test('and the command names the entity it changed', () async {
    // A queued row pointing at nothing is worse than no row: it would be
    // replayed at V2 against an id the server cannot resolve.
    final Customer c = await fixture.aCustomer();
    final QueryRow row = await db
        .customSelect(
          'SELECT entity_type, entity_id FROM outbox ORDER BY id DESC LIMIT 1',
        )
        .getSingle();

    expect(row.read<String>('entity_type'), 'customer');
    expect(row.read<String>('entity_id'), c.id);
  });

  test('the registry covers every writer found in daos/', () {
    // The half that makes this fail closed. The subject set is discovered by
    // scanning, so a new DAO method cannot escape by never being listed.
    final Set<String> registered = <String>{
      for (final _Mutation m in _mutations) '${m.dao}.${m.method}',
    };

    final List<String> found = <String>[];
    final Directory daos = Directory('lib/data/db/daos');
    expect(
      daos.existsSync(),
      isTrue,
      reason: 'the scan has nothing to look at, so it checks nothing',
    );

    for (final FileSystemEntity entity in daos.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final List<String> lines = entity.readAsLinesSync();
      String? currentClass;
      String? currentMethod;

      for (final String line in lines) {
        final RegExpMatch? cls = RegExp(
          r'^(?:final |abstract )?class (\w+)',
        ).firstMatch(line);
        if (cls != null) {
          currentClass = cls.group(1);
        }

        // A public method signature at class-body indentation.
        final RegExpMatch? method = RegExp(
          r'^  (?:Future<[^>]*>|void) (\w+)\(',
        ).firstMatch(line);
        if (method != null) {
          currentMethod = method.group(1);
        }

        final bool writes =
            line.contains('.into(') ||
            line.contains('_db.update(') ||
            line.contains('_db.delete(');
        if (writes && currentClass != null && currentMethod != null) {
          // `_mutate` is the shared funnel, not a mutation of its own.
          if (currentMethod.startsWith('_')) {
            continue;
          }
          found.add('$currentClass.$currentMethod');
        }
      }
    }

    expect(
      found,
      isNotEmpty,
      reason: 'the scan found no writers at all, so it proved nothing',
    );

    final Set<String> unproven = found.toSet()
      ..removeAll(registered)
      ..removeAll(_exempt.keys);

    expect(
      unproven,
      isEmpty,
      reason:
          'these DAO methods write but are not proven to queue an outbox row: '
          '${unproven.join(', ')}. Add them to _mutations with an invocation, '
          'or to _exempt with the reason they must not queue.',
    );
  });
}

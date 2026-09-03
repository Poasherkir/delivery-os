import 'dart:async';

import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/address_dao.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/db/daos/order_dao.dart';
import 'package:delivery_os/data/repositories/drift_address_repository.dart';
import 'package:delivery_os/data/repositories/drift_batch_repository.dart';
import 'package:delivery_os/data/repositories/drift_company_repository.dart';
import 'package:delivery_os/data/repositories/drift_customer_repository.dart';
import 'package:delivery_os/data/repositories/drift_geography_repository.dart';
import 'package:delivery_os/data/repositories/drift_order_repository.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/address_repository.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/orders/presentation/order_entry_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/app_fonts.dart';

/// **The M1 gate, in the half a device cannot answer.**
///
/// Fifteen parcels in under four minutes is sixteen seconds each. The number
/// most likely to fail that is not the hardware — it is how many discrete
/// things the driver has to do per parcel, and that is measurable today, on
/// this form, without a phone or a manifest.
///
/// If a returning customer costs twelve interactions, no device is fast enough
/// and the form is wrong. If it costs four, the hardware question becomes the
/// real one. This test is what tells those apart, and it fails when a change to
/// the form makes entry more expensive — which is the regression that would
/// otherwise only surface with a stopwatch in an agency at 07:00.
///
/// **What counts as one interaction.** One discrete act by the driver:
///
/// - a tap on a control — a button, a list row, a field they must reach
/// - typing the contents of one field, however many characters
///
/// Moving focus to a field costs one and typing into it costs one, so filling
/// a field is two — unless focus is already there, which is why the phone field
/// autofocuses after a scan. Characters typed are counted separately: they do
/// not scale with taps, and a ten-digit phone number is several seconds on its
/// own.
///
/// **What is outside this measurement.** Aiming the camera, which is not a tap
/// and is not something a widget test can hold. And the FAB that opens the
/// scanner, which is paid once for the first parcel and never again: saving
/// with *Enregistrer et scanner* reopens the camera itself, so parcels two
/// through fifteen begin at the form with the phone field already focused.
/// Counts what the driver does, and does it.
///
/// Wrapping the tester rather than counting afterwards, so a step cannot be
/// performed without being counted — the failure mode of any manual tally.
final class Driver {
  Driver(this.tester);

  final WidgetTester tester;

  int focusMoves = 0;
  int taps = 0;
  int fieldEntries = 0;
  int characters = 0;

  int get interactions => focusMoves + taps + fieldEntries;

  Future<void> press(Finder target) async {
    taps++;
    await tester.tap(target);
    await _settle();
  }

  /// Fills a field. [focused] when the caret is already there — after a scan
  /// the phone field autofocuses, and that saved tap is the point of it.
  Future<void> fill(Finder target, String text, {bool focused = false}) async {
    if (!focused) {
      focusMoves++;
    }
    fieldEntries++;
    characters += text.length;
    await tester.enterText(target, text);
    await _settle();
  }

  /// Past the debounces as well as the frames.
  ///
  /// `pumpAndSettle` stops when nothing more is scheduled, and a pending
  /// `Timer` schedules nothing — so the customer lookup and the commune search
  /// would never resolve and every count here would be measuring a form that
  /// had not finished reacting.
  ///
  /// The wait is not an interaction and is not counted as one. It is 250 ms
  /// that elapses while the driver is still moving their thumb.
  Future<void> _settle() async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(loadAppFonts);

  late db.AppDatabase database;
  late CompanyRepository companies;
  late CustomerRepository customers;
  late AddressRepository addresses;
  late OrderRepository orders;
  late List<Object> overrides;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 3, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();

    await database.customStatement(
      "INSERT INTO wilayas (code, name_fr, name_ar) VALUES (16, 'Alger', 'x')",
    );
    await database.customStatement(
      'INSERT INTO communes (id, wilaya_code, name_fr, name_ar) '
      "VALUES (1601, 16, 'Bab Ezzouar', 'باب الزوار')",
    );

    companies = DriftCompanyRepository(
      dao: CompanyDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
    customers = DriftCustomerRepository(
      dao: CustomerDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
    orders = DriftOrderRepository(
      dao: OrderDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    );
    addresses = DriftAddressRepository(
      dao: AddressDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );

    await companies.create(name: 'Yalidine');

    overrides = <Object>[
      companyRepositoryProvider.overrideWithValue(companies),
      customerRepositoryProvider.overrideWithValue(customers),
      orderRepositoryProvider.overrideWithValue(orders),
      addressRepositoryProvider.overrideWithValue(addresses),
      batchRepositoryProvider.overrideWithValue(
        DriftBatchRepository(
          dao: BatchDao(
            database: database,
            clock: clock,
            uuid: uuid,
            deviceId: 'device-under-test',
          ),
          clock: clock,
          ownerId: user.id,
        ),
      ),
      geographyRepositoryProvider.overrideWithValue(
        DriftGeographyRepository(database),
      ),
    ];
  });

  tearDown(() => database.close());

  Future<Driver> open(WidgetTester tester, {required String tracking}) async {
    // Tall on purpose: a ListView builds only what fits, and a field below the
    // fold would otherwise look absent rather than merely unscrolled. Scrolling
    // is its own cost and is measured in the last test here, not hidden inside
    // every other one.
    tester.view.physicalSize = const Size(360, 1400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: SizedBox.expand()),
        ),
        GoRoute(
          path: OrderEntryScreen.path,
          builder: (BuildContext context, GoRouterState state) =>
              OrderEntryScreen(scannedTracking: state.extra as String?),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp.router(
          locale: AppLocales.french,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The parcel arrives scanned. Not counted: aiming a camera is not a tap,
    // and for parcels two through fifteen the previous save opened it.
    unawaited(router.push(OrderEntryScreen.path, extra: tracking));
    await tester.pumpAndSettle();

    return Driver(tester);
  }

  Finder key(String name) => find.byKey(Key(name));

  /// The parcel the scripted sequence was supposed to save.
  ///
  /// Fails by name rather than on a null check, because *this* is the guard:
  /// the counts below are a property of the script and cannot move on their
  /// own, so what catches a form that started demanding more is the minimum
  /// sequence no longer producing a parcel. That failure has to say so.
  Future<Order> savedParcel(String tracking) async {
    final Order? found = await orders.findByTracking(
      companyId: (await companies.selectable()).single.id,
      trackingNumber: tracking,
    );
    expect(
      found,
      isNotNull,
      reason:
          'the minimum sequence saved nothing: the form now requires '
          'something this script does not supply, so entry costs more than '
          'the budget below claims',
    );
    return found!;
  }

  group('a returning customer', () {
    setUp(() async {
      // Somebody the driver has delivered to before, with an address already
      // on file. This is the majority case once the app has been used for a
      // week, and it is the one the loop is built around.
      final Customer amine = await customers.create(
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine Bensalem',
      );
      // With somewhere to deliver to. Without this the claim below — that a
      // returning customer's address costs nothing to enter — would be tested
      // against a customer who has no address to inherit.
      await addresses.create(
        customerId: amine.id,
        wilayaCode: 16,
        communeId: 1601,
        detail: 'Bt 12, 3e étage',
      );
    });

    testWidgets('costs what it costs, and the number is recorded', (
      WidgetTester tester,
    ) async {
      final Driver driver = await open(tester, tracking: 'YAL-0001');

      // Phone: the caret is already here after a scan.
      await driver.fill(key('orderEntry.phone'), '0550123456', focused: true);
      // Amount off the manifest.
      await driver.fill(key('orderEntry.cod'), '4500');
      await driver.press(key('orderEntry.save'));

      // **This is the guard, not the counter.** The count above is a property
      // of the script — it cannot change unless somebody edits this file. What
      // catches a form that started demanding more is that the *scripted
      // minimum still produces a complete parcel*: attached to the right
      // person, pointing at their door, carrying the money.
      final Order saved = await savedParcel('YAL-0001');
      final Customer amine = (await customers.findByPhone(
        PhoneE164.parse('0550123456'),
      ))!;

      expect(saved.customerId, amine.id);
      expect(
        saved.addressId,
        isNotNull,
        reason:
            'the address must arrive with the customer, untyped — that is '
            'the whole reason this path is four and not eleven',
      );
      expect(saved.codAmount, const Centimes(450000));
      expect(
        await customers.all(),
        hasLength(1),
        reason: 'a second record for the same person',
      );

      // ── The budget ───────────────────────────────────────────────────────
      // Four interactions: type the number, reach the amount, type it, save.
      // Sixteen seconds a parcel leaves four seconds each, with the scan and a
      // driver who is not a typist inside that.
      //
      // Exact, not a ceiling. A ceiling would be satisfied by a script that
      // does less than a real entry, and this script *is* the claim — the
      // number changes when somebody adds a step to it, which is what "the
      // form got more expensive" looks like from here.
      expect(
        driver.interactions,
        4,
        reason: 'entry for a known customer changed cost',
      );
      expect(driver.characters, 14);
    });

    testWidgets('and the address comes with them, untyped', (
      WidgetTester tester,
    ) async {
      // The reason the number above is four and not nine. Looking a customer
      // up while the driver types is what removes the commune, the detail and
      // the name from the majority case.
      final Driver driver = await open(tester, tracking: 'YAL-0002');

      await driver.fill(key('orderEntry.phone'), '0550123456', focused: true);

      expect(
        key('orderEntry.name'),
        findsNothing,
        reason: 'an existing customer is recognised, not retyped',
      );
    });
  });

  group('a new customer', () {
    testWidgets('costs what it costs, and the number is recorded', (
      WidgetTester tester,
    ) async {
      final Driver driver = await open(tester, tracking: 'YAL-0003');

      await driver.fill(key('orderEntry.phone'), '0550999888', focused: true);
      await driver.fill(key('orderEntry.name'), 'Karim Haddad');

      // The commune sheet: one tap to open, and its search field autofocuses,
      // so typing is free of a focus move. One tap to choose.
      await driver.press(key('orderEntry.commune'));
      await driver.fill(key('communePicker.query'), 'Bab', focused: true);
      await driver.press(key('communePicker.row.1601'));

      await driver.fill(key('orderEntry.address'), 'Bt 12, 3e étage');
      await driver.fill(key('orderEntry.cod'), '4500');
      await driver.press(key('orderEntry.save'));

      final Order saved = await savedParcel('YAL-0003');
      expect(saved.customerId, isNotNull);
      expect(
        saved.addressId,
        isNotNull,
        reason: 'a new customer must end up with somewhere to deliver to',
      );
      expect(
        (await addresses.forCustomer(saved.customerId!)).single.detail,
        'Bt 12, 3e étage',
        reason:
            'the detail is what makes this an address rather than a '
            'commune centroid',
      );

      // ── The budget ───────────────────────────────────────────────────────
      // Eleven interactions. Every one of them is a fact only the driver has:
      // the number, the name, which commune, which building, how much. The
      // form asks for nothing it could have derived.
      //
      // This is the expensive path and it is also the shrinking one — every
      // new customer entered today is a returning customer tomorrow, and the
      // four-interaction path is where a used app spends its mornings.
      expect(
        driver.interactions,
        11,
        reason: 'entry for a new customer changed cost',
      );
      expect(driver.characters, 44);
    });

    testWidgets('and a parcel with no customer at all costs three', (
      WidgetTester tester,
    ) async {
      // The floor. A driver with a manifest and no phone numbers can still
      // empty it into the app and attach people later.
      final Driver driver = await open(tester, tracking: 'YAL-0004');

      await driver.fill(key('orderEntry.cod'), '4500');
      await driver.press(key('orderEntry.save'));

      final Order saved = await savedParcel('YAL-0004');
      expect(saved.needsCustomer, isTrue);
      expect(driver.interactions, 3);
    });
  });

  testWidgets('nothing below the fold is needed for either path', (
    WidgetTester tester,
  ) async {
    // Scrolling is an interaction the counts above do not include, so it must
    // not be required. On a 360x640 phone — the 2GB device this is built for —
    // everything the two paths touch has to be reachable without one, except
    // the save button, which is one scroll at the end of a form the driver has
    // just filled downward.
    tester.view.physicalSize = const Size(360, 640) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: SizedBox.expand()),
        ),
        GoRoute(
          path: OrderEntryScreen.path,
          builder: (BuildContext context, GoRouterState state) =>
              OrderEntryScreen(scannedTracking: state.extra as String?),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp.router(
          locale: AppLocales.french,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push(OrderEntryScreen.path, extra: 'YAL-0005'));
    await tester.pumpAndSettle();

    // The phone is where the caret lands and must be visible without moving.
    expect(key('orderEntry.phone'), findsOneWidget);
  });
}

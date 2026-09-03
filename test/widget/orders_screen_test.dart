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
import 'package:delivery_os/domain/entities/address.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/address_repository.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/orders/presentation/order_entry_screen.dart';
import 'package:delivery_os/features/orders/presentation/orders_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/app_fonts.dart';

/// Against a real in-memory database, the same as the other orders screens.
/// The row this list renders is assembled by a five-table join, and a fake
/// repository would not exercise it.
void main() {
  setUpAll(loadAppFonts);

  late db.AppDatabase database;
  late CompanyRepository companies;
  late BatchRepository batches;
  late CustomerRepository customers;
  late AddressRepository addresses;
  late OrderRepository orders;
  late String companyId;
  late String batchId;
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
    batches = DriftBatchRepository(
      dao: BatchDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
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
    addresses = DriftAddressRepository(
      dao: AddressDao(
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

    companyId = (await companies.create(name: 'Yalidine')).id;
    batchId = (await batches.ensureOpenBatch(companyId: companyId)).id;

    overrides = <Object>[
      orderRepositoryProvider.overrideWithValue(orders),
      companyRepositoryProvider.overrideWithValue(companies),
      customerRepositoryProvider.overrideWithValue(customers),
      addressRepositoryProvider.overrideWithValue(addresses),
      batchRepositoryProvider.overrideWithValue(batches),
      geographyRepositoryProvider.overrideWithValue(
        DriftGeographyRepository(database),
      ),
    ];
  });

  tearDown(() => database.close());

  Future<Order> addOrder({
    String tracking = 'YAL-0001',
    String? customerId,
    String? addressId,
    Centimes cod = Centimes.zero,
    DeliveryType type = DeliveryType.home,
    String? company,
    String? batch,
  }) => orders.create(
    batchId: batch ?? batchId,
    companyId: company ?? companyId,
    trackingNumber: tracking,
    customerId: customerId,
    addressId: addressId,
    codAmount: cod,
    deliveryType: type,
  );

  Future<Customer> addCustomer([String phone = '0550123456']) => customers
      .create(phone: PhoneE164.parse(phone), displayName: 'Amine Bensalem');

  Future<Address> addAddress(String customerId, {String? detail}) =>
      addresses.create(
        customerId: customerId,
        wilayaCode: 16,
        communeId: 1601,
        detail: detail,
      );

  /// Every test names its locale. The runner reports `en-US`, which falls back
  /// to Arabic — so a test that stays silent is exercising RTL while reading as
  /// though it were LTR.
  Future<GoRouter> pump(WidgetTester tester, {required Locale locale}) async {
    // Tall enough that the entry form's save button is never below the fold —
    // one test here pushes that screen and taps it. A ListView only builds
    // what fits, so at the default test surface `find.byKey` would answer
    // "not on this screen" for a field that is simply unscrolled.
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
              const OrdersScreen(),
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
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  group('before anything is entered', () {
    testWidgets('the empty state explains and points at the scan FAB', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.text("Aucun colis aujourd'hui"), findsOneWidget);
      expect(find.text('Scannez un colis pour commencer.'), findsOneWidget);
      expect(find.byKey(const Key('orders.scan')), findsOneWidget);
    });
  });

  group('a parcel with nobody attached', () {
    setUp(() => addOrder());

    testWidgets('shows the needs-customer badge and no address badge', (
      WidgetTester tester,
    ) async {
      // Not a second badge for the same absence: with no customer, there is
      // nobody the address badge could be offered on behalf of.
      await pump(tester, locale: AppLocales.french);

      expect(find.text('Client à ajouter'), findsOneWidget);
      expect(find.text('Adresse à ajouter'), findsNothing);
      expect(find.text('YAL-0001'), findsOneWidget);
    });
  });

  group('a parcel with a customer but no address', () {
    setUp(() async {
      final Customer c = await addCustomer();
      await addOrder(customerId: c.id);
    });

    testWidgets('shows the name and the needs-address badge', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.text('Amine Bensalem'), findsOneWidget);
      expect(find.text('Adresse à ajouter'), findsOneWidget);
      expect(find.text('Client à ajouter'), findsNothing);
    });
  });

  group('a parcel with a full address', () {
    setUp(() async {
      final Customer c = await addCustomer();
      final Address a = await addAddress(c.id, detail: 'Bt 12, 3e étage');
      await addOrder(customerId: c.id, addressId: a.id);
    });

    testWidgets('shows the commune and the detail, and no badges', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.textContaining('Bab Ezzouar'), findsOneWidget);
      expect(find.textContaining('Bt 12, 3e étage'), findsOneWidget);
      expect(find.text('Client à ajouter'), findsNothing);
      expect(find.text('Adresse à ajouter'), findsNothing);
    });

    testWidgets('and in Arabic, the commune reads in Arabic', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.arabic);

      expect(find.textContaining('باب الزوار'), findsOneWidget);
      expect(find.textContaining('Bab Ezzouar'), findsNothing);
    });
  });

  group('the amount', () {
    setUp(() => addOrder(cod: Centimes.fromDinars(4500)));

    testWidgets('renders with the currency abbreviation, French digits', (
      WidgetTester tester,
    ) async {
      // MoneyFormat is locale-independent by design: identical digits and
      // separators in both locales, so a driver reading a paper bordereau
      // never has to convert scripts while reconciling cash.
      await pump(tester, locale: AppLocales.french);
      expect(find.textContaining('4'), findsWidgets);
      expect(find.textContaining('DA'), findsOneWidget);
    });

    testWidgets(
      'and the currency abbreviation is localized, the digits are not',
      (WidgetTester tester) async {
        await pump(tester, locale: AppLocales.arabic);

        expect(find.textContaining('دج'), findsOneWidget);
        expect(find.textContaining('DA'), findsNothing);
      },
    );
  });

  group('delivery type', () {
    testWidgets('home and stop desk render different icons', (
      WidgetTester tester,
    ) async {
      await addOrder(tracking: 'YAL-HOME');
      await addOrder(tracking: 'YAL-STOP', type: DeliveryType.stopdesk);

      await pump(tester, locale: AppLocales.french);

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    });
  });

  group('company', () {
    testWidgets('is hidden when the whole day is one company', (
      WidgetTester tester,
    ) async {
      await addOrder();

      await pump(tester, locale: AppLocales.french);

      expect(find.text('Yalidine'), findsNothing);
    });

    testWidgets('and shown once a second company appears', (
      WidgetTester tester,
    ) async {
      final String other = (await companies.create(name: 'ZR Express')).id;
      final String otherBatch = (await batches.ensureOpenBatch(
        companyId: other,
      )).id;
      await addOrder(tracking: 'YAL-0001');
      await addOrder(tracking: 'ZR-0001', company: other, batch: otherBatch);

      await pump(tester, locale: AppLocales.french);

      expect(find.text('Yalidine'), findsOneWidget);
      expect(find.text('ZR Express'), findsOneWidget);
    });
  });

  testWidgets('newest first, so the parcel just entered is at the top', (
    WidgetTester tester,
  ) async {
    await addOrder(tracking: 'YAL-0001');
    await addOrder(tracking: 'YAL-0002');
    await addOrder(tracking: 'YAL-0003');

    await pump(tester, locale: AppLocales.french);

    final List<String> order = tester
        .widgetList<Text>(find.textContaining('YAL-'))
        .map((Text t) => t.data ?? '')
        .toList();

    expect(order, <String>['YAL-0003', 'YAL-0002', 'YAL-0001']);
  });

  testWidgets('every row clears the minimum tap target', (
    WidgetTester tester,
  ) async {
    // The driver is tapping one-handed while holding a parcel.
    await addOrder(tracking: 'YAL-0001');
    await addOrder(tracking: 'YAL-0002');

    await pump(tester, locale: AppLocales.french);

    final Iterable<Element> rows = tester.elementList(find.byType(ListTile));
    expect(rows, isNotEmpty, reason: 'nothing was measured');
    for (final Element row in rows) {
      expect(row.size!.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('saving a parcel from the entry form refreshes this list', (
    WidgetTester tester,
  ) async {
    // The provider does not poll — invalidation from the entry screen is the
    // only way it learns a parcel landed, and this is what proves that wire
    // is actually connected rather than merely present in the diff.
    final GoRouter router = await pump(tester, locale: AppLocales.french);
    expect(find.text("Aucun colis aujourd'hui"), findsOneWidget);

    // Not awaited: the future completes when the pushed route pops, which
    // is after the test has finished with it.
    unawaited(router.push(OrderEntryScreen.path, extra: 'YAL-0001'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('orderEntry.save')));
    await tester.pumpAndSettle();

    expect(find.text('YAL-0001'), findsOneWidget);
    expect(find.text("Aucun colis aujourd'hui"), findsNothing);
  });
}

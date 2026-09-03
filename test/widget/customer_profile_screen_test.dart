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
import 'package:delivery_os/data/repositories/drift_order_repository.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/entities/customer_history.dart';
import 'package:delivery_os/domain/repositories/address_repository.dart';
import 'package:delivery_os/domain/repositories/customer_contact.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/customers/presentation/customer_profile_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/app_fonts.dart';

/// Records what the screen asked for instead of launching it.
///
/// The point of `CustomerContact` being an interface: a test can assert that
/// tapping "Appeler" reached the dialer with the right number, on a host with
/// no dialer and no Android intents.
final class _RecordingContact implements CustomerContact {
  final List<PhoneE164> dialled = <PhoneE164>[];
  final List<PhoneE164> messaged = <PhoneE164>[];

  /// What both methods return. False is a phone with no WhatsApp installed —
  /// an ordinary state the screen has to render rather than swallow.
  bool succeeds = true;

  @override
  Future<bool> dial(PhoneE164 phone) async {
    dialled.add(phone);
    return succeeds;
  }

  @override
  Future<bool> whatsApp(PhoneE164 phone) async {
    messaged.add(phone);
    return succeeds;
  }
}

void main() {
  setUpAll(loadAppFonts);

  late db.AppDatabase database;
  late CustomerRepository customers;
  late AddressRepository addresses;
  late OrderRepository orders;
  late _RecordingContact contact;
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
    companyId = (await DriftCompanyRepository(
      dao: CompanyDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    ).create(name: 'Yalidine')).id;
    batchId = (await DriftBatchRepository(
      dao: BatchDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    ).ensureOpenBatch(companyId: companyId)).id;

    contact = _RecordingContact();

    overrides = <Object>[
      customerRepositoryProvider.overrideWithValue(customers),
      addressRepositoryProvider.overrideWithValue(addresses),
      orderRepositoryProvider.overrideWithValue(orders),
      customerContactProvider.overrideWithValue(contact),
    ];
  });

  tearDown(() => database.close());

  Future<Customer> aCustomer({String phone = '0550123456'}) => customers.create(
    phone: PhoneE164.parse(phone),
    displayName: 'Amine Bensalem',
  );

  Future<void> addOrders(String customerId, int howMany) async {
    for (int i = 0; i < howMany; i++) {
      await orders.create(
        batchId: batchId,
        companyId: companyId,
        trackingNumber: 'YAL-${1000 + i}',
        customerId: customerId,
        codAmount: Centimes.fromDinars(4500),
      );
    }
  }

  /// Every test names its locale. The runner reports `en-US`, which falls back
  /// to Arabic — so a test that stays silent is exercising RTL while reading as
  /// though it were LTR.
  Future<void> pump(
    WidgetTester tester,
    String customerId, {
    required Locale locale,
  }) async {
    // Tall, so a windowed history and its "see all" are laid out rather than
    // below the fold — a ListView only builds what fits, and this screen is
    // deliberately long.
    tester.view.physicalSize = const Size(360, 2400) * 3;
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
          path: CustomerProfileScreen.pathPattern,
          builder: (BuildContext context, GoRouterState state) =>
              CustomerProfileScreen(customerId: state.pathParameters['id']!),
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

    // Not awaited: the future completes when the pushed route pops.
    unawaited(router.push(CustomerProfileScreen.pathFor(customerId)));
    await tester.pumpAndSettle();
  }

  group('who they are', () {
    testWidgets('the name and the number, unmasked', (
      WidgetTester tester,
    ) async {
      // The driver's own screen: reading the number is the point. Masking is
      // for logs and crash payloads, not for the person who has to dial it.
      final Customer c = await aCustomer();

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.text('Amine Bensalem'), findsOneWidget);
      expect(find.text('+213550123456'), findsOneWidget);
    });
  });

  group('reaching them', () {
    testWidgets('calling hands the dialer the right number', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();
      await pump(tester, c.id, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('customerProfile.call')));
      await tester.pumpAndSettle();

      expect(contact.dialled, <PhoneE164>[PhoneE164.parse('0550123456')]);
    });

    testWidgets('and WhatsApp the same one', (WidgetTester tester) async {
      final Customer c = await aCustomer();
      await pump(tester, c.id, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('customerProfile.whatsapp')));
      await tester.pumpAndSettle();

      expect(contact.messaged, <PhoneE164>[PhoneE164.parse('0550123456')]);
    });

    testWidgets('a landline is offered a call but not WhatsApp', (
      WidgetTester tester,
    ) async {
      // A landline cannot have WhatsApp. A button that always fails is worse
      // than one that is not there.
      final Customer c = await aCustomer(phone: '0234455667');
      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.byKey(const Key('customerProfile.call')), findsOneWidget);
      expect(find.byKey(const Key('customerProfile.whatsapp')), findsNothing);
    });

    testWidgets('and nothing handling the link says so rather than nothing', (
      WidgetTester tester,
    ) async {
      // Most often WhatsApp simply not being installed. A button that silently
      // does nothing is worse than one that admits it could not.
      contact.succeeds = false;
      final Customer c = await aCustomer();
      await pump(tester, c.id, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('customerProfile.whatsapp')));
      await tester.pumpAndSettle();

      expect(
        find.text('Aucune application ne peut ouvrir ce lien.'),
        findsOneWidget,
      );
    });
  });

  group('a number that never parsed', () {
    testWidgets('offers no actions, and says why', (WidgetTester tester) async {
      // Absent buttons with no explanation would read as a broken screen. And
      // the copy blames the parser, not the driver — a pre-2008 landline is
      // our gap, not their typo.
      final Customer c = await customers.createUnparsed(
        rawPhone: '021 44 55 66',
        displayName: 'Atelier Centre',
      );

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.byKey(const Key('customerProfile.call')), findsNothing);
      expect(find.byKey(const Key('customerProfile.whatsapp')), findsNothing);
      expect(
        find.byKey(const Key('customerProfile.needsReview')),
        findsOneWidget,
      );
      expect(find.text('021 44 55 66'), findsOneWidget);
    });
  });

  group('where they live', () {
    testWidgets('the addresses, with the primary marked', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();
      await addresses.create(
        customerId: c.id,
        wilayaCode: 16,
        communeId: 1601,
        detail: 'Bt 12, 3e étage',
      );

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.text('Bt 12, 3e étage'), findsOneWidget);
      expect(find.text('Principale'), findsOneWidget);
    });

    testWidgets('and an empty state when there are none', (
      WidgetTester tester,
    ) async {
      // Ordinary for a customer entered from a manifest before a delivery.
      final Customer c = await aCustomer();

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.text('Aucune adresse enregistrée.'), findsOneWidget);
    });
  });

  group('what they have had', () {
    testWidgets('the parcels, with the day and the amount', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();
      await addOrders(c.id, 2);

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.text('YAL-1000'), findsOneWidget);
      expect(find.text('YAL-1001'), findsOneWidget);
      expect(find.textContaining('2026-09-03'), findsWidgets);
      expect(find.textContaining('DA'), findsWidgets);
    });

    testWidgets('an empty state when there are none', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.text('Aucun colis pour ce client.'), findsOneWidget);
    });

    testWidgets('no see-all when the history fits in the window', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();
      await addOrders(c.id, 3);

      await pump(tester, c.id, locale: AppLocales.french);

      expect(find.byKey(const Key('customerProfile.showAll')), findsNothing);
    });
  });

  group('the window', () {
    /// Scrolls to the end of the history.
    ///
    /// A `ListView` builds only what fits, so the see-all sits below the fold
    /// on any real screen and `find.byKey` would answer "absent" for something
    /// merely unscrolled. Scrolling is also what the driver does — the offer
    /// belongs at the end of the list it is offering to extend, not floating
    /// over it.
    Future<void> scrollToEnd(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('customerProfile.showAll')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opens bounded, and says what it is hiding', (
      WidgetTester tester,
    ) async {
      // The design note this screen was built to: a detail view tapped into
      // mid-round must not open by loading a year of history, and it must not
      // present a truncated list as though it were the whole of it.
      final Customer c = await aCustomer();
      await addOrders(c.id, CustomerHistory.defaultWindow + 5);

      await pump(tester, c.id, locale: AppLocales.french);
      await scrollToEnd(tester);

      expect(
        find.text('50 sur 55 colis'),
        findsOneWidget,
        reason: 'the screen must say the list is partial',
      );
      expect(find.byKey(const Key('customerProfile.showAll')), findsOneWidget);
    });

    testWidgets('and the parcels outside the window are not rendered', (
      WidgetTester tester,
    ) async {
      // The window is a real bound, not a label. YAL-1000 is the oldest of the
      // fifty-five and falls outside the fifty most recent, so it must not be
      // anywhere in the list — scrolled to or not.
      final Customer c = await aCustomer();
      await addOrders(c.id, CustomerHistory.defaultWindow + 5);

      await pump(tester, c.id, locale: AppLocales.french);
      await scrollToEnd(tester);

      expect(find.text('YAL-1000'), findsNothing);
      expect(find.text('YAL-1054'), findsNothing);
      // The newest is at the top, and the fiftieth-newest is the oldest shown.
      expect(find.text('YAL-1005'), findsOneWidget);
    });

    testWidgets('and see-all loads the rest', (WidgetTester tester) async {
      final Customer c = await aCustomer();
      await addOrders(c.id, CustomerHistory.defaultWindow + 5);
      await pump(tester, c.id, locale: AppLocales.french);
      await scrollToEnd(tester);

      await tester.tap(find.byKey(const Key('customerProfile.showAll')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customerProfile.showAll')),
        findsNothing,
        reason: 'nothing is hidden any more, so nothing offers to show it',
      );

      // The oldest parcel is now reachable, which it was not before.
      await tester.scrollUntilVisible(
        find.text('YAL-1000'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('YAL-1000'), findsOneWidget);
    });
  });

  group('Arabic', () {
    testWidgets('renders right to left, in Arabic', (
      WidgetTester tester,
    ) async {
      final Customer c = await aCustomer();
      await addresses.create(
        customerId: c.id,
        wilayaCode: 16,
        communeId: 1601,
        detail: 'Bt 12',
      );

      await pump(tester, c.id, locale: AppLocales.arabic);

      expect(find.text('بطاقة الزبون'), findsOneWidget);
      expect(find.text('اتصال'), findsOneWidget);
      expect(find.text('الأساسي'), findsOneWidget);
      expect(find.text('Fiche client'), findsNothing);
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('customerProfile.call'))),
        ),
        TextDirection.rtl,
      );
    });
  });

  group('tap targets', () {
    testWidgets('the contact actions clear the minimum', (
      WidgetTester tester,
    ) async {
      // The driver is holding a parcel in one hand, and these two are what the
      // screen exists for.
      final Customer c = await aCustomer();
      await pump(tester, c.id, locale: AppLocales.french);

      for (final String key in <String>[
        'customerProfile.call',
        'customerProfile.whatsapp',
      ]) {
        expect(
          tester.getSize(find.byKey(Key(key))).height,
          greaterThanOrEqualTo(48),
          reason: '$key is under the minimum tap target',
        );
      }
    });
  });
}

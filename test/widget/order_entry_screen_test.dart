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
import 'package:delivery_os/domain/entities/company.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/orders/presentation/order_entry_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/app_fonts.dart';

/// Against a real in-memory database rather than fakes.
///
/// Five repositories feed this screen and faking all five would be more code
/// than the screen, most of it re-implementing constraints the database already
/// has. What is left to test here is what the *screen* does: which state it
/// renders, what it requires, and what it sends.
void main() {
  setUpAll(loadAppFonts);

  late db.AppDatabase database;
  late CompanyRepository companies;
  late OrderRepository orders;
  late CustomerRepository customers;
  late BatchRepository batches;
  // Riverpod 3 does not export the `Override` type, so this is inferred.
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

    customers = DriftCustomerRepository(
      dao: CustomerDao(
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

    overrides = <Object>[
      companyRepositoryProvider.overrideWithValue(companies),
      orderRepositoryProvider.overrideWithValue(orders),
      customerRepositoryProvider.overrideWithValue(customers),
      addressRepositoryProvider.overrideWithValue(
        DriftAddressRepository(
          dao: AddressDao(
            database: database,
            clock: clock,
            uuid: uuid,
            deviceId: 'device-under-test',
          ),
          ownerId: user.id,
        ),
      ),
      batchRepositoryProvider.overrideWithValue(batches),
      geographyRepositoryProvider.overrideWithValue(
        DriftGeographyRepository(database),
      ),
    ];
  });

  tearDown(() => database.close());

  /// Every test names its locale. The runner reports `en-US`, which falls back
  /// to Arabic — so a test that stays silent is exercising RTL while reading as
  /// though it were LTR.
  Future<void> pump(
    WidgetTester tester, {
    required Locale locale,
    String? scanned,
    Size size = const Size(360, 1400),
  }) async {
    // Taller than any real phone by default, so the whole form is laid out and
    // a test can ask what is on it. A ListView builds only what fits, so at a
    // real viewport `find.byKey` answers "not on this screen" for a field that
    // is simply below the fold — which is a claim about scrolling, not about
    // the form. The one test that *is* about the viewport sets its own size.
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // A real router rather than a bare `home:`. The screen pops itself after a
    // save and pushes the scanner and the company form, all of which go through
    // GoRouter — a MaterialApp without one throws at the first save, which is
    // exactly the path most worth testing.
    //
    // Pushed onto a route that exists, so there is something to pop back to,
    // the same way it is reached in the app: above the shell, over Orders.
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
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Not awaited: the future completes when the pushed route pops, which
    // is after the test has finished with it.
    unawaited(router.push(OrderEntryScreen.path, extra: scanned));
    await tester.pumpAndSettle();
  }

  group('before any company exists', () {
    testWidgets('the empty state explains and offers a way in', (
      WidgetTester tester,
    ) async {
      // Nothing is seeded to avoid this state: an invented company would end
      // up in a settlement. So the first morning starts here, once.
      await pump(tester, locale: AppLocales.french);

      expect(find.text('Aucune société'), findsOneWidget);
      expect(
        find.text('Ajoutez la société qui vous a remis ces colis.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('orderEntry.addCompany')), findsOneWidget);
    });

    testWidgets('and no form is shown, because there is nowhere to file it', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.byKey(const Key('orderEntry.tracking')), findsNothing);
      expect(find.byKey(const Key('orderEntry.saveAndScan')), findsNothing);
    });
  });

  group('with one company', () {
    setUp(() => companies.create(name: 'Yalidine'));

    testWidgets('it is selected without asking', (WidgetTester tester) async {
      // A picker with a single row is a tap that answers a question the driver
      // was not asked.
      await pump(tester, locale: AppLocales.french);

      expect(find.byKey(const Key('orderEntry.company')), findsOneWidget);
      expect(find.text('Yalidine'), findsOneWidget);
      expect(find.byKey(const Key('orderEntry.tracking')), findsOneWidget);
    });

    testWidgets('the scanned number arrives pre-filled', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('orderEntry.tracking')))
            .controller
            ?.text,
        'YAL-0001',
      );
    });

    testWidgets('every field the form owes is on it', (
      WidgetTester tester,
    ) async {
      // Named individually rather than counted. A count passes when a field is
      // swapped for another, which is the change worth catching.
      await pump(tester, locale: AppLocales.french);

      for (final String key in <String>[
        'orderEntry.tracking',
        'orderEntry.phone',
        'orderEntry.name',
        'orderEntry.commune',
        'orderEntry.address',
        'orderEntry.cod',
        'orderEntry.deliveryType',
        'orderEntry.notes',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: '$key is missing');
      }
    });

    testWidgets('and there is nothing else on it', (WidgetTester tester) async {
      // In particular no date field: the batch carries the service date,
      // derived from the 04:00 cutoff, and choosing it is a batch screen's job
      // in M2. A date field on the path measured with a stopwatch is friction
      // bought for a case that has its own answer elsewhere.
      //
      // Asserted as a count rather than by naming what must be absent, because
      // a check for the absence of something that was never there passes
      // forever without looking at anything. Six text fields: tracking, phone,
      // name, address, amount, note. The commune is a sheet and the delivery
      // type is a toggle.
      await pump(tester, locale: AppLocales.french);

      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('and the whole form is reachable on a small phone', (
      WidgetTester tester,
    ) async {
      // The one test here that is about the viewport rather than the form.
      // 360x640 is the 2GB device this app is built for.
      await pump(tester, locale: AppLocales.french, size: const Size(360, 640));

      await tester.scrollUntilVisible(
        find.byKey(const Key('orderEntry.saveAndScan')),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byKey(const Key('orderEntry.saveAndScan')), findsOneWidget);
    });

    testWidgets('a parcel with no tracking number is refused', (
      WidgetTester tester,
    ) async {
      // The only blocking validation. Everything else is optional on purpose.
      await pump(tester, locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      expect(find.text('Le n° de suivi est obligatoire.'), findsOneWidget);
    });

    testWidgets('and a tracking number alone is enough', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      final List<Company> all = await companies.selectable();
      final Order? saved = await orders.findByTracking(
        companyId: all.single.id,
        trackingNumber: 'YAL-0001',
      );
      expect(saved, isNotNull);
      expect(saved!.codAmount, Centimes.zero);
    });

    testWidgets('the amount is read as whole dinars', (
      WidgetTester tester,
    ) async {
      // Invariant 1, at the one door money comes in by. 4500 DA is 450000
      // centimes — 4500 × 100 by the definition of the unit, with nothing
      // rounded on the way.
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.enterText(find.byKey(const Key('orderEntry.cod')), '4500');
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      final List<Company> all = await companies.selectable();
      final Order saved = (await orders.findByTracking(
        companyId: all.single.id,
        trackingNumber: 'YAL-0001',
      ))!;
      expect(saved.codAmount, const Centimes(450000));
    });

    testWidgets('scanning the same parcel twice says so, calmly', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orderEntry.duplicate')), findsOneWidget);
      expect(find.text('Ce colis est déjà dans la tournée.'), findsOneWidget);
    });

    testWidgets('and the message blames nobody', (WidgetTester tester) async {
      // A driver hits this screen fifteen times a morning and rescanning is
      // ordinary. No vocabulary that reads as a mistake they made.
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      final String message = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('orderEntry.duplicate')),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data ?? '')
          .join(' ')
          .toLowerCase();

      for (final String forbidden in <String>[
        'erreur',
        'invalide',
        'échec',
        'impossible',
        'vous avez',
      ]) {
        expect(
          message,
          isNot(contains(forbidden)),
          reason: '"$forbidden" reads as the driver\'s fault',
        );
      }
    });
  });

  group('a number that already belongs to somebody', () {
    setUp(() async {
      await companies.create(name: 'Yalidine');
      // Somebody with a history, so the count on the card has something to
      // say. A record with no parcels would render "Aucune commande", which
      // is true but does not exercise the recognition aid.
      final Customer amine = await customers.create(
        phone: PhoneE164.parse('0550123456'),
        displayName: 'Amine Bensalem',
      );
      final String batchId = (await batches.ensureOpenBatch(
        companyId: (await companies.selectable()).single.id,
      )).id;
      for (int i = 0; i < 3; i++) {
        await orders.create(
          batchId: batchId,
          companyId: (await companies.selectable()).single.id,
          trackingNumber: 'YAL-OLD-$i',
          customerId: amine.id,
        );
      }
      await database.customStatement(
        'UPDATE customers SET total_orders = 3 WHERE id = ?',
        <Object?>[amine.id],
      );
    });

    testWidgets('names them, so the driver can see it is the right person', (
      WidgetTester tester,
    ) async {
      // The gap this closes: the name field vanishing was the only signal a
      // match had happened, which says something was found but not who.
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.enterText(
        find.byKey(const Key('orderEntry.phone')),
        '0550123456',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orderEntry.existing')), findsOneWidget);
      expect(find.text('Amine Bensalem'), findsOneWidget);
    });

    testWidgets('and shows how many parcels they have had', (
      WidgetTester tester,
    ) async {
      // Two Amines are common; one with three parcels is not.
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.enterText(
        find.byKey(const Key('orderEntry.phone')),
        '0550123456',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('3 commandes'), findsOneWidget);
    });

    testWidgets('and stops asking for a name', (WidgetTester tester) async {
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.enterText(
        find.byKey(const Key('orderEntry.phone')),
        '0550123456',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orderEntry.name')), findsNothing);
    });
  });

  group('home versus stop desk', () {
    setUp(() => companies.create(name: 'Yalidine'));

    testWidgets('both options are offered, and home is selected', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.text('À domicile'), findsOneWidget);
      expect(find.text('Point relais'), findsOneWidget);
      expect(
        tester
            .widget<SegmentedButton<DeliveryType>>(
              find.byKey(const Key('orderEntry.deliveryType')),
            )
            .selected,
        <DeliveryType>{DeliveryType.home},
      );
    });

    testWidgets('one tap makes it a stop-desk parcel, and it is stored', (
      WidgetTester tester,
    ) async {
      // It cannot be derived from anything else — it comes off the label — and
      // a stop-desk parcel must never enter the optimized route. Without this
      // field M4 sends the driver to a house for a parcel waiting at an agency.
      await pump(tester, locale: AppLocales.french, scanned: 'YAL-0001');

      await tester.tap(find.text('Point relais'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('orderEntry.save')));
      await tester.pumpAndSettle();

      final List<Company> all = await companies.selectable();
      final Order saved = (await orders.findByTracking(
        companyId: all.single.id,
        trackingNumber: 'YAL-0001',
      ))!;
      expect(saved.deliveryType, DeliveryType.stopdesk);
    });

    testWidgets('and every delivery type has a label', (
      WidgetTester tester,
    ) async {
      // Fails closed the day a third type is added without copy for it.
      await pump(tester, locale: AppLocales.french);

      final SegmentedButton<DeliveryType> toggle = tester
          .widget<SegmentedButton<DeliveryType>>(
            find.byKey(const Key('orderEntry.deliveryType')),
          );
      expect(
        toggle.segments.map((ButtonSegment<DeliveryType> s) => s.value),
        DeliveryType.values,
      );
    });
  });

  group('with two companies', () {
    setUp(() async {
      await companies.create(name: 'Yalidine');
      await companies.create(name: 'ZR Express');
    });

    testWidgets('the driver chooses, because guessing guesses the batch', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      expect(find.text('Yalidine'), findsOneWidget);
      expect(find.text('ZR Express'), findsOneWidget);
      expect(find.byKey(const Key('orderEntry.tracking')), findsNothing);
    });

    testWidgets('and choosing one opens the form under it', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      await tester.tap(find.text('ZR Express'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orderEntry.company')), findsOneWidget);
      expect(find.byKey(const Key('orderEntry.tracking')), findsOneWidget);
    });
  });

  group('Arabic', () {
    setUp(() => companies.create(name: 'Yalidine'));

    testWidgets('renders right to left', (WidgetTester tester) async {
      await pump(tester, locale: AppLocales.arabic);

      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('orderEntry.tracking'))),
        ),
        TextDirection.rtl,
      );
    });

    testWidgets('and in Arabic, not the template language', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.arabic);

      expect(find.text('طرد جديد'), findsOneWidget);
      expect(find.text('إلى المنزل'), findsOneWidget);
      expect(find.text('نقطة الاستلام'), findsOneWidget);
      expect(find.text('Nouveau colis'), findsNothing);
    });
  });

  group('tap targets', () {
    setUp(() => companies.create(name: 'Yalidine'));

    testWidgets('the next action is the largest thing on screen', (
      WidgetTester tester,
    ) async {
      // The driver is holding a parcel in one hand, and this is the loop the
      // four-minute gate measures.
      await pump(tester, locale: AppLocales.french);

      final Size next = tester.getSize(
        find.byKey(const Key('orderEntry.saveAndScan')),
      );
      final Size secondary = tester.getSize(
        find.byKey(const Key('orderEntry.save')),
      );

      expect(next.height, greaterThan(secondary.height));
      expect(next.height, greaterThanOrEqualTo(56));
    });

    testWidgets('and nothing tappable is under 48dp', (
      WidgetTester tester,
    ) async {
      await pump(tester, locale: AppLocales.french);

      for (final String key in <String>[
        'orderEntry.saveAndScan',
        'orderEntry.save',
        'orderEntry.deliveryType',
        'orderEntry.changeCompany',
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

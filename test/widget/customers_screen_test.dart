import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/customers/presentation/customer_form_screen.dart';
import 'package:delivery_os/features/customers/presentation/customers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fonts.dart';

/// An in-memory repository, so these tests exercise the screens rather than
/// Drift. The database-backed behaviour has its own tests.
final class _FakeRepo implements CustomerRepository {
  _FakeRepo([List<Customer>? seed]) : _rows = <Customer>[...?seed];

  final List<Customer> _rows;
  int nextVersion = 2;

  @override
  Future<List<Customer>> all() async => List<Customer>.of(_rows);

  @override
  Future<List<Customer>> search(String query) async {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return all();
    }
    return _rows
        .where(
          (Customer c) =>
              c.displayName.toLowerCase().contains(q) ||
              (c.phone?.e164 ?? c.phoneRaw ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<Customer?> findByPhone(PhoneE164 phone) async =>
      _rows.where((Customer c) => c.phone == phone).firstOrNull;

  @override
  Future<List<Customer>> needingPhoneReview() async =>
      _rows.where((Customer c) => c.needsPhoneReview).toList();

  @override
  Future<Customer> create({
    required PhoneE164 phone,
    required String displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag riskFlag = CustomerRiskFlag.none,
  }) async {
    final Customer? clash = await findByPhone(phone);
    if (clash != null) {
      throw DuplicatePhoneException(clash);
    }
    final Customer c = Customer(
      id: 'new-${_rows.length}',
      displayName: displayName,
      version: 1,
      phone: phone,
      notes: notes,
      riskFlag: riskFlag,
    );
    _rows.add(c);
    return c;
  }

  @override
  Future<Customer> createUnparsed({
    required String rawPhone,
    required String displayName,
    String? notes,
  }) async {
    final Customer c = Customer(
      id: 'raw-${_rows.length}',
      displayName: displayName,
      version: 1,
      phoneRaw: rawPhone,
      notes: notes,
    );
    _rows.add(c);
    return c;
  }

  @override
  Future<Customer> edit({
    required Customer current,
    String? displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag? riskFlag,
  }) async {
    final Customer updated = Customer(
      id: current.id,
      displayName: displayName ?? current.displayName,
      version: nextVersion++,
      phone: current.phone,
      phoneRaw: current.phoneRaw,
      notes: notes ?? current.notes,
      riskFlag: riskFlag ?? current.riskFlag,
    );
    _rows[_rows.indexWhere((Customer c) => c.id == current.id)] = updated;
    return updated;
  }

  @override
  Future<Customer> resolvePhone({
    required Customer current,
    required PhoneE164 phone,
  }) async {
    final Customer? clash = await findByPhone(phone);
    if (clash != null && clash.id != current.id) {
      throw DuplicatePhoneException(clash);
    }
    final Customer updated = Customer(
      id: current.id,
      displayName: current.displayName,
      version: nextVersion++,
      phone: phone,
      notes: current.notes,
      riskFlag: current.riskFlag,
    );
    _rows[_rows.indexWhere((Customer c) => c.id == current.id)] = updated;
    return updated;
  }

  @override
  Future<void> softDelete(Customer current) async =>
      _rows.removeWhere((Customer c) => c.id == current.id);
}

Customer _customer({
  required String id,
  required String name,
  String? phone,
  String? raw,
}) => Customer(
  id: id,
  displayName: name,
  version: 1,
  phone: phone == null ? null : PhoneE164.parse(phone),
  phoneRaw: raw,
);

void main() {
  setUpAll(loadAppFonts);

  /// Every test names its locale. The runner reports `en-US`, which correctly
  /// falls back to Arabic — so a test that stays silent is exercising RTL while
  /// reading as though it were LTR.
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    required Locale locale,
    _FakeRepo? repo,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerRepositoryProvider.overrideWithValue(repo ?? _FakeRepo()),
        ],
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppL10n.localizationsDelegates,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the list', () {
    testWidgets('shows the customers it is given, in French', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CustomersScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine Bensalem', phone: '0550111111'),
          _customer(id: 'b', name: 'Karim Haddad', phone: '0550222222'),
        ]),
      );

      expect(find.text('Amine Bensalem'), findsOneWidget);
      expect(find.text('+213550222222'), findsOneWidget);
    });

    testWidgets('an empty database says where customers come from', (
      WidgetTester tester,
    ) async {
      await pump(tester, const CustomersScreen(), locale: AppLocales.french);

      // Two different empties: this one is "there is nothing yet", and it has
      // to explain rather than look like a failed search.
      expect(find.text('Aucun client'), findsOneWidget);
      expect(find.textContaining('dès le premier colis'), findsOneWidget);
    });

    testWidgets('a search that matches nothing says something else', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CustomersScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine', phone: '0550111111'),
        ]),
      );

      await tester.enterText(find.byKey(const Key('customers.search')), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Aucun résultat pour cette recherche.'), findsOneWidget);
      expect(find.text('Aucun client'), findsNothing);
    });

    testWidgets('search filters the list', (WidgetTester tester) async {
      await pump(
        tester,
        const CustomersScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine Bensalem', phone: '0550111111'),
          _customer(id: 'b', name: 'Karim Haddad', phone: '0550222222'),
        ]),
      );

      await tester.enterText(
        find.byKey(const Key('customers.search')),
        'karim',
      );
      await tester.pumpAndSettle();

      expect(find.text('Karim Haddad'), findsOneWidget);
      expect(find.text('Amine Bensalem'), findsNothing);
    });

    testWidgets('an unparsed number is badged, not hidden', (
      WidgetTester tester,
    ) async {
      // The customer most in need of attention is the one the parser rejected.
      await pump(
        tester,
        const CustomersScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'r', name: 'Atelier Centre', raw: '021 44 55 66'),
        ]),
      );

      expect(find.text('021 44 55 66'), findsOneWidget);
      expect(find.text('Numéro à vérifier'), findsOneWidget);
    });

    testWidgets('renders right-to-left in Arabic', (WidgetTester tester) async {
      await pump(
        tester,
        const CustomersScreen(),
        locale: AppLocales.arabic,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'أمين', phone: '0550111111'),
        ]),
      );

      expect(
        Directionality.of(tester.element(find.text('أمين'))),
        TextDirection.rtl,
      );
      expect(find.text('ابحث عن زبون'), findsOneWidget);
    });
  });

  group('the form', () {
    testWidgets('a name is required', (WidgetTester tester) async {
      await pump(tester, const CustomerFormScreen(), locale: AppLocales.french);

      await tester.tap(find.byKey(const Key('customerForm.save')));
      await tester.pumpAndSettle();

      expect(find.text('Le nom est obligatoire.'), findsOneWidget);
    });

    testWidgets('an unrecognised number warns without blocking', (
      WidgetTester tester,
    ) async {
      // The rule this screen exists to honour: a validator that disagrees with
      // a real landline must not stop a driver entering an order at 07:00.
      final _FakeRepo repo = _FakeRepo();
      await pump(
        tester,
        const CustomerFormScreen(),
        locale: AppLocales.french,
        repo: repo,
      );

      await tester.enterText(
        find.byKey(const Key('customerForm.name')),
        'Atelier',
      );
      await tester.enterText(
        find.byKey(const Key('customerForm.phone')),
        '021 44',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customerForm.unrecognized')),
        findsOneWidget,
      );

      // And it still saves, verbatim.
      await tester.tap(find.byKey(const Key('customerForm.save')));
      await tester.pumpAndSettle();

      final List<Customer> saved = await repo.all();
      expect(saved.single.phoneRaw, '021 44');
      expect(saved.single.needsPhoneReview, isTrue);
    });

    testWidgets('a recognised number shows no warning', (
      WidgetTester tester,
    ) async {
      await pump(tester, const CustomerFormScreen(), locale: AppLocales.french);

      await tester.enterText(
        find.byKey(const Key('customerForm.phone')),
        '0550123456',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customerForm.unrecognized')), findsNothing);
    });

    testWidgets('a number already taken surfaces the customer while typing', (
      WidgetTester tester,
    ) async {
      // The point of looking up as the driver types. Finding the customer here
      // saves retyping a name and an address; finding them at save time saves
      // nothing.
      await pump(
        tester,
        const CustomerFormScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          Customer(
            id: 'a',
            displayName: 'Amine Bensalem',
            version: 1,
            phone: PhoneE164.parse('0550111111'),
            totalOrders: 12,
          ),
        ]),
      );

      await tester.enterText(
        find.byKey(const Key('customerForm.phone')),
        '0550111111',
      );
      // Past the debounce.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customerForm.existing')), findsOneWidget);
      expect(find.text('Amine Bensalem'), findsOneWidget);
      expect(find.text('12 colis'), findsOneWidget);
      expect(find.byKey(const Key('customerForm.useExisting')), findsOneWidget);
    });

    testWidgets('a free number surfaces nothing', (WidgetTester tester) async {
      await pump(
        tester,
        const CustomerFormScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine', phone: '0550111111'),
        ]),
      );

      await tester.enterText(
        find.byKey(const Key('customerForm.phone')),
        '0660999888',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customerForm.existing')), findsNothing);
      expect(find.byKey(const Key('customerForm.unrecognized')), findsNothing);
    });

    testWidgets('a duplicate names the customer holding the number', (
      WidgetTester tester,
    ) async {
      // Naming them is the point: "unique constraint failed" would send the
      // driver off to search for a record the app already had in hand.
      await pump(
        tester,
        const CustomerFormScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine Bensalem', phone: '0550111111'),
        ]),
      );

      await tester.enterText(
        find.byKey(const Key('customerForm.name')),
        'Quelqu\'un',
      );
      await tester.enterText(
        find.byKey(const Key('customerForm.phone')),
        '0550111111',
      );
      await tester.tap(find.byKey(const Key('customerForm.save')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Amine Bensalem'),
        findsOneWidget,
        reason: 'the duplicate message did not name the existing customer',
      );
      expect(
        find.byKey(const Key('customerForm.duplicateOpen')),
        findsOneWidget,
      );
    });

    testWidgets('editing loads the existing values', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CustomerFormScreen(customerId: 'a'),
        locale: AppLocales.french,
        repo: _FakeRepo(<Customer>[
          _customer(id: 'a', name: 'Amine Bensalem', phone: '0550111111'),
        ]),
      );

      expect(find.text('Amine Bensalem'), findsOneWidget);
      expect(find.text('+213550111111'), findsOneWidget);
      expect(find.text('Modifier le client'), findsOneWidget);
    });

    testWidgets('the save button meets the tap target minimum', (
      WidgetTester tester,
    ) async {
      await pump(tester, const CustomerFormScreen(), locale: AppLocales.french);

      final Size size = tester.getSize(
        find.byKey(const Key('customerForm.save')),
      );
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}

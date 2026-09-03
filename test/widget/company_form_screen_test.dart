import 'dart:async';

import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/generated/app_l10n.dart';
import 'package:delivery_os/core/theme/app_theme.dart';
import 'package:delivery_os/domain/entities/company.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:delivery_os/features/companies/presentation/companies_screen.dart';
import 'package:delivery_os/features/companies/presentation/company_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/app_fonts.dart';

final class _FakeRepo implements CompanyRepository {
  _FakeRepo([List<Company>? seed]) : _rows = <Company>[...?seed];

  final List<Company> _rows;

  @override
  Future<List<Company>> selectable() async => List<Company>.of(_rows);

  @override
  Future<Company?> byId(String id) async =>
      _rows.where((Company c) => c.id == id).firstOrNull;

  @override
  Future<Company> create({
    required String name,
    String? contactPhone,
    String? notes,
  }) async {
    final Company created = Company(
      id: 'c${_rows.length + 1}',
      name: name,
      version: 1,
      contactPhone: contactPhone,
      notes: notes,
    );
    _rows.add(created);
    return created;
  }

  @override
  Future<Company> edit({
    required Company current,
    String? name,
    String? contactPhone,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<void> softDelete(Company current) => throw UnimplementedError();
}

void main() {
  setUpAll(loadAppFonts);

  /// Every test names its locale. The runner reports `en-US`, which falls back
  /// to Arabic — so a test that stays silent is exercising RTL while reading as
  /// though it were LTR.
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    required Locale locale,
    required _FakeRepo repo,
  }) async {
    // A real router rather than a bare `home:`. The form pops itself with the
    // created company so the caller that needed one can carry on, and a
    // MaterialApp without a GoRouter throws on the first save — which is the
    // path most worth testing. Pushed onto a route that exists, so there is
    // something to pop back to, the same way it is reached in the app.
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: SizedBox.expand()),
        ),
        GoRoute(
          path: '/screen',
          builder: (BuildContext context, GoRouterState state) => screen,
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [companyRepositoryProvider.overrideWithValue(repo)],
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

    // Not awaited: the future completes when the pushed route pops, which is
    // after the test has finished with it.
    unawaited(router.push('/screen'));
    await tester.pumpAndSettle();
  }

  group('the form', () {
    testWidgets('asks for three things and requires one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(),
      );

      expect(find.byKey(const Key('companyForm.name')), findsOneWidget);
      expect(find.byKey(const Key('companyForm.phone')), findsOneWidget);
      expect(find.byKey(const Key('companyForm.notes')), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('an empty name is refused', (WidgetTester tester) async {
      final _FakeRepo repo = _FakeRepo();
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.french,
        repo: repo,
      );

      await tester.tap(find.byKey(const Key('companyForm.save')));
      await tester.pumpAndSettle();

      expect(find.text('Le nom est obligatoire.'), findsOneWidget);
      expect(await repo.selectable(), isEmpty);
    });

    testWidgets('a name alone is enough', (WidgetTester tester) async {
      final _FakeRepo repo = _FakeRepo();
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.french,
        repo: repo,
      );

      await tester.enterText(
        find.byKey(const Key('companyForm.name')),
        'Yalidine',
      );
      await tester.tap(find.byKey(const Key('companyForm.save')));
      await tester.pumpAndSettle();

      final List<Company> saved = await repo.selectable();
      expect(saved, hasLength(1));
      expect(saved.single.name, 'Yalidine');
      expect(saved.single.contactPhone, isNull);
    });

    testWidgets('and the phone is kept exactly as typed', (
      WidgetTester tester,
    ) async {
      // Free text, not a validated number. An agency hands out a mobile and a
      // landline together; normalizing would lose the second one.
      final _FakeRepo repo = _FakeRepo();
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.french,
        repo: repo,
      );

      await tester.enterText(
        find.byKey(const Key('companyForm.name')),
        'ZR Express',
      );
      await tester.enterText(
        find.byKey(const Key('companyForm.phone')),
        '0770 11 22 33 / 021 44 55 66',
      );
      await tester.tap(find.byKey(const Key('companyForm.save')));
      await tester.pumpAndSettle();

      expect(
        (await repo.selectable()).single.contactPhone,
        '0770 11 22 33 / 021 44 55 66',
      );
    });

    testWidgets('the save button is the largest tappable thing', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(),
      );

      expect(
        tester.getSize(find.byKey(const Key('companyForm.save'))).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('and it renders in Arabic, right to left', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CompanyFormScreen(),
        locale: AppLocales.arabic,
        repo: _FakeRepo(),
      );

      expect(find.text('شركة جديدة'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('companyForm.name'))),
        ),
        TextDirection.rtl,
      );
    });
  });

  group('the list', () {
    testWidgets('explains itself when it is empty', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const CompaniesScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(),
      );

      expect(find.text('Aucune société'), findsOneWidget);
      expect(find.byKey(const Key('companies.new')), findsOneWidget);
    });

    testWidgets('and shows what it has, by name', (WidgetTester tester) async {
      await pump(
        tester,
        const CompaniesScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Company>[
          Company(id: 'a', name: 'Anderson', version: 1),
          Company(
            id: 'b',
            name: 'Yalidine',
            version: 1,
            contactPhone: '0770 11 22 33',
          ),
        ]),
      );

      expect(find.text('Anderson'), findsOneWidget);
      expect(find.text('Yalidine'), findsOneWidget);
      expect(find.text('0770 11 22 33'), findsOneWidget);
      expect(find.text('Aucune société'), findsNothing);
    });

    testWidgets('every row clears the minimum tap target', (
      WidgetTester tester,
    ) async {
      // The driver is tapping one-handed while holding a parcel.
      await pump(
        tester,
        const CompaniesScreen(),
        locale: AppLocales.french,
        repo: _FakeRepo(<Company>[
          Company(id: 'a', name: 'Anderson', version: 1),
          Company(id: 'b', name: 'Yalidine', version: 1),
        ]),
      );

      final Iterable<Element> rows = tester.elementList(find.byType(ListTile));
      expect(rows, isNotEmpty, reason: 'nothing was measured');
      for (final Element row in rows) {
        expect(row.size!.height, greaterThanOrEqualTo(48));
      }
    });
  });
}

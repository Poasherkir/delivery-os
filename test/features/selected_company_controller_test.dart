import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/domain/entities/company.dart';
import 'package:delivery_os/domain/repositories/company_repository.dart';
import 'package:delivery_os/features/orders/controllers/selected_company_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A list of companies and nothing else. The database-backed behaviour has its
/// own tests; what matters here is which of them gets chosen and when.
final class _FakeRepo implements CompanyRepository {
  _FakeRepo([List<Company>? seed]) : _rows = <Company>[...?seed];

  final List<Company> _rows;
  int selectableCalls = 0;

  @override
  Future<List<Company>> selectable() async {
    selectableCalls++;
    return List<Company>.of(_rows);
  }

  @override
  Future<Company?> byId(String id) async =>
      _rows.where((Company c) => c.id == id).firstOrNull;

  @override
  Future<Company> create({
    required String name,
    String? contactPhone,
    String? notes,
  }) => throw UnimplementedError();

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

Company company(String id, String name) =>
    Company(id: id, name: name, version: 1);

void main() {
  ProviderContainer containerWith(_FakeRepo repo) {
    final ProviderContainer container = ProviderContainer(
      overrides: [companyRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('nothing is selected until something selects it', () {
    // Not persisted and not defaulted. A stale selection restored at midday
    // would file parcels under the wrong batch, which is the one mistake here
    // that reaches the money.
    expect(containerWith(_FakeRepo()).read(selectedCompanyProvider), isNull);
  });

  test('one company is chosen without asking', () async {
    // A picker with a single row is a tap that answers a question the driver
    // was not asked.
    final ProviderContainer container = containerWith(
      _FakeRepo(<Company>[company('a', 'Yalidine')]),
    );

    final Company? resolved = await container
        .read(selectedCompanyProvider.notifier)
        .resolve();

    expect(resolved?.name, 'Yalidine');
    expect(container.read(selectedCompanyProvider)?.name, 'Yalidine');
  });

  test('but two are not, because guessing guesses the batch', () async {
    final ProviderContainer container = containerWith(
      _FakeRepo(<Company>[
        company('a', 'Yalidine'),
        company('b', 'ZR Express'),
      ]),
    );

    expect(
      await container.read(selectedCompanyProvider.notifier).resolve(),
      isNull,
    );
  });

  test('and none stays none rather than inventing one', () async {
    // An invented company would end up in a settlement.
    final ProviderContainer container = containerWith(_FakeRepo());

    expect(
      await container.read(selectedCompanyProvider.notifier).resolve(),
      isNull,
    );
  });

  test('an existing selection is not re-resolved', () async {
    // The screen calls resolve on every build of the entry form, which is once
    // per parcel. Fifteen queries for an answer already held is the kind of
    // cost the four-minute gate is made of.
    final _FakeRepo repo = _FakeRepo(<Company>[company('a', 'Yalidine')]);
    final ProviderContainer container = containerWith(repo);
    final SelectedCompanyController controller = container.read(
      selectedCompanyProvider.notifier,
    );

    controller.select(company('b', 'ZR Express'));
    final Company? resolved = await controller.resolve();

    expect(resolved?.name, 'ZR Express');
    expect(repo.selectableCalls, 0);
  });

  test('clearing brings the picker back', () async {
    final ProviderContainer container = containerWith(
      _FakeRepo(<Company>[company('a', 'Yalidine')]),
    );
    final SelectedCompanyController controller = container.read(
      selectedCompanyProvider.notifier,
    );
    await controller.resolve();

    controller.clear();

    expect(container.read(selectedCompanyProvider), isNull);
  });

  test(
    'and with no database it selects nothing rather than throwing',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [companyRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(
        await container.read(selectedCompanyProvider.notifier).resolve(),
        isNull,
      );
    },
  );
}

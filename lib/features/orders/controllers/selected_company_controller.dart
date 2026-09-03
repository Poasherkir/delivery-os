import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/entities/company.dart';
import '../../../domain/repositories/company_repository.dart';

/// Which company today's parcels came from.
///
/// **Selected once per batch, never per order.** A driver empties one company's
/// manifest before starting the next, so asking per parcel would be fifteen
/// taps for one answer. It lives outside the entry screen so it survives the
/// scan-save-scan loop, which rebuilds that screen every time round.
///
/// Not persisted. The selection is a property of this session, and a driver who
/// reopens the app at midday is as likely to be starting the second company as
/// continuing the first — restoring a stale choice would silently file parcels
/// under the wrong batch, which is the one mistake here that reaches the money.
/// [resolve] picks the obvious answer instead when there is exactly one.
class SelectedCompanyController extends Notifier<Company?> {
  @override
  Company? build() => null;

  void select(Company company) => state = company;

  /// Drops the selection so the picker comes back.
  void clear() => state = null;

  /// Chooses the only company there is, if there is only one.
  ///
  /// A driver with one company should never see a picker; a driver with three
  /// must, because guessing would be guessing about the batch. Returns the
  /// selection, which is null when the driver still has to choose or when no
  /// company exists yet.
  Future<Company?> resolve() async {
    if (state != null) {
      return state;
    }

    final CompanyRepository? repo = ref.read(companyRepositoryProvider);
    final List<Company> companies =
        await repo?.selectable() ?? const <Company>[];

    if (companies.length == 1) {
      state = companies.single;
    }
    return state;
  }
}

final NotifierProvider<SelectedCompanyController, Company?>
selectedCompanyProvider = NotifierProvider<SelectedCompanyController, Company?>(
  SelectedCompanyController.new,
);

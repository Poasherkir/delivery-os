import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';

/// What the driver has typed into the search field.
///
/// A provider rather than widget state so the list can be rebuilt from
/// elsewhere — creating a customer invalidates the list, and the query has to
/// survive that.
final NotifierProvider<CustomerSearchQuery, String> customerSearchProvider =
    NotifierProvider<CustomerSearchQuery, String>(CustomerSearchQuery.new);

class CustomerSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// The customers matching the current query, oldest first.
///
/// Returns empty rather than throwing when the database is not open. A screen
/// reached while startup is still resolving should render its empty state, not
/// an error — and if startup *failed*, the driver is on the unreadable-database
/// screen and never sees this at all.
final FutureProvider<List<Customer>> customerListProvider =
    FutureProvider<List<Customer>>((Ref ref) async {
      final CustomerRepository? repo = ref.watch(customerRepositoryProvider);
      if (repo == null) {
        return const <Customer>[];
      }
      return repo.search(ref.watch(customerSearchProvider));
    });

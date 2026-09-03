import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../app/di.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/customer_history.dart';
import '../../../domain/repositories/address_repository.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/order_repository.dart';

/// Everything one profile screen renders, fetched together.
@immutable
final class CustomerProfile {
  const CustomerProfile({
    required this.customer,
    required this.addresses,
    required this.history,
  });

  final Customer customer;
  final List<Address> addresses;
  final CustomerHistory history;
}

/// How much of a customer's history the profile is currently showing.
///
/// Widget state would be lost every time the profile rebuilds — which it does
/// after an edit — and would silently snap a driver who asked for the full
/// history back to the window. Null means "all of it".
class CustomerHistoryWindow extends Notifier<int?> {
  @override
  int? build() => CustomerHistory.defaultWindow;

  /// Loads the rest. One-way on purpose: there is no reason to offer to
  /// re-hide rows the driver just asked to see.
  void showAll() => state = null;
}

final NotifierProvider<CustomerHistoryWindow, int?> customerHistoryWindow =
    NotifierProvider<CustomerHistoryWindow, int?>(CustomerHistoryWindow.new);

/// One customer, their addresses and their parcels.
///
/// Returns null when the database is not open or the customer is gone, which
/// the screen renders — the same contract as `customerListProvider`, for the
/// same reason: a screen reached mid-startup should show nothing, not an error,
/// and a genuine database failure has its own screen the driver is already on.
// Type inferred: Riverpod 3 does not export a name for a family's type,
// the same gap that keeps `Override` unspellable in the tests.
final customerProfileProvider = FutureProvider.family<CustomerProfile?, String>(
  (Ref ref, String customerId) async {
    final CustomerRepository? customers = ref.watch(customerRepositoryProvider);
    final AddressRepository? addresses = ref.watch(addressRepositoryProvider);
    final OrderRepository? orders = ref.watch(orderRepositoryProvider);
    if (customers == null || addresses == null || orders == null) {
      return null;
    }

    // `all()` rather than a byId: the repository deliberately offers no
    // single-customer read, because every screen so far wanted the list. One
    // customer out of a few hundred is not worth widening the interface for
    // until something needs it to be indexed.
    final Customer? customer = (await customers.all())
        .where((Customer c) => c.id == customerId)
        .firstOrNull;
    if (customer == null) {
      return null;
    }

    return CustomerProfile(
      customer: customer,
      addresses: await addresses.forCustomer(customerId),
      history: await orders.historyForCustomer(
        customerId,
        limit: ref.watch(customerHistoryWindow),
      ),
    );
  },
);

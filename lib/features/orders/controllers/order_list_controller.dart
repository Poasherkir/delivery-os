import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/entities/order_summary.dart';
import '../../../domain/repositories/order_repository.dart';

/// Today's parcels, across every company, newest first.
///
/// Returns empty rather than throwing when the database is not open. A screen
/// reached while startup is still resolving should render its empty state, not
/// an error — and if startup *failed*, the driver is on the unreadable-database
/// screen and never sees this at all. Same shape as `customerListProvider`.
///
/// Invalidated by [OrderEntryScreen] after a save, the same way creating a
/// customer invalidates the customer list — this provider does not poll and
/// has no other way to learn that a parcel landed.
final FutureProvider<List<OrderSummary>> orderListProvider =
    FutureProvider<List<OrderSummary>>((Ref ref) async {
      final OrderRepository? repo = ref.watch(orderRepositoryProvider);
      if (repo == null) {
        return const <OrderSummary>[];
      }
      return repo.summariesForDate();
    });

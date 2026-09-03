import 'package:meta/meta.dart';

import 'order_summary.dart';

/// A customer's parcels, most recent first, and how many there are in total.
///
/// **Windowed from the start.** A customer the driver has delivered to for a
/// year has a few hundred orders, and this is a detail view a driver taps into
/// mid-round, not a report. Loading the whole history by default is the kind of
/// query that looks instant against test data and is slow against a real
/// database — so the default fetches [defaultWindow] and the screen offers to
/// load the rest explicitly.
///
/// [total] is counted rather than inferred from `recent.length`, which is the
/// whole point: it is what lets the screen say honestly that it is showing part
/// of the history instead of silently presenting a truncated list as complete.
/// Counting costs one indexed `COUNT(*)`; the alternative — fetching
/// everything to find out how much there was — is the mistake the window
/// exists to avoid.
@immutable
final class CustomerHistory {
  const CustomerHistory({required this.recent, required this.total});

  /// The window the screen opens with. Fifty rather than a date range: a date
  /// range still returns everything for a busy customer, which is the case
  /// that needed bounding.
  static const int defaultWindow = 50;

  /// Most recent first.
  final List<OrderSummary> recent;

  /// Every live parcel this customer has ever had, however few are in [recent].
  final int total;

  /// Whether [recent] is a window onto something larger.
  bool get isWindowed => total > recent.length;

  /// How many parcels are not shown.
  int get hidden => total - recent.length;

  bool get isEmpty => total == 0;

  @override
  String toString() => 'CustomerHistory(${recent.length} of $total)';
}

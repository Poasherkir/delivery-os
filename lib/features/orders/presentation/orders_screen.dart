import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_l10n.dart';
import '../../../shared/widgets/app_text.dart';
import '../../ingestion/presentation/scanner_screen.dart';
import 'order_entry_screen.dart';

/// Today's orders.
///
/// The list is still to come. What is here is the way parcels get *in*:
/// scanning is an action on this screen rather than a destination of its own,
/// because it is something a driver does to today's work, not a place they go.
/// Five bottom-nav destinations, not six.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  /// Scan, then enter.
  ///
  /// A null scan is not a cancellation. The scanner returns it when the driver
  /// chose manual entry or backed out of a damaged label, and both of those
  /// mean "open the form anyway" — a scanner that traps the driver is worse
  /// than no scanner.
  static Future<void> scanThenEnter(BuildContext context) async {
    final String? scanned = await context.push<String>(ScannerScreen.path);
    if (context.mounted) {
      await context.push<void>(OrderEntryScreen.path, extra: scanned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('orders.scan'),
        onPressed: () => scanThenEnter(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: AppText(l10n.scannerTitle, AppTextStyle.label),
      ),
      body: const SizedBox.expand(),
    );
  }
}

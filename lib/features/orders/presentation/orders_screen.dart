import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_l10n.dart';
import '../../../shared/widgets/app_text.dart';
import '../../ingestion/presentation/scanner_screen.dart';

/// Today's orders.
///
/// The list itself is M1-08. What is here now is the way orders get *in*:
/// scanning is an action on this screen rather than a destination of its own,
/// because it is something a driver does to today's orders, not a place they
/// go. Five bottom-nav destinations, not six.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('orders.scan'),
        // The scanner pops with the scanned string, or null when the driver
        // chose manual entry or backed out. M1-08 takes that value into the
        // order form; until it exists there is nowhere to take it, so the
        // result is deliberately dropped rather than half-handled.
        onPressed: () => context.push<String>(ScannerScreen.path),
        icon: const Icon(Icons.qr_code_scanner),
        label: AppText(l10n.scannerTitle, AppTextStyle.label),
      ),
      body: const SizedBox.expand(),
    );
  }
}

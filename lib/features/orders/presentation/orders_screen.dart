import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/money/money_format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/order_summary.dart';
import '../../../domain/value_objects/delivery_type.dart';
import '../../../shared/widgets/app_text.dart';
import '../../ingestion/presentation/scanner_screen.dart';
import '../controllers/order_list_controller.dart';
import 'order_entry_screen.dart';

/// Today's orders.
///
/// Scanning is an action on this screen rather than a destination of its own,
/// because it is something a driver does to today's work, not a place they go.
/// Five bottom-nav destinations, not six.
///
/// **No status badge.** `OrderStatus` has eight values, but nothing before M2
/// writes any of them: every order this app can currently produce is
/// `pending`, and a badge that always says the same word on every row is
/// decoration, not information. It arrives with the delivery flow that gives
/// it something to say.
class OrdersScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final AsyncValue<List<OrderSummary>> orders = ref.watch(orderListProvider);
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('orders.scan'),
        onPressed: () => scanThenEnter(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: AppText(l10n.scannerTitle, AppTextStyle.label),
      ),
      body: orders.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        // The list failing is not the database failing — that has its own
        // screen. This is a query that went wrong, and the empty state's
        // instruction (scan a parcel) is still the driver's next move.
        error: (Object e, StackTrace s) =>
            _Empty(title: l10n.ordersEmptyTitle, body: l10n.ordersEmptyBody),
        data: (List<OrderSummary> rows) {
          if (rows.isEmpty) {
            return _Empty(
              title: l10n.ordersEmptyTitle,
              body: l10n.ordersEmptyBody,
            );
          }

          // Shown per row only when today spans more than one company — a
          // driver working one never sees a label that only ever says the same
          // thing.
          final bool multipleCompanies =
              rows.map((OrderSummary o) => o.companyName).toSet().length > 1;

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: SpaceTokens.space64),
            itemCount: rows.length,
            separatorBuilder: (BuildContext c, int i) =>
                Divider(height: 1, color: colors.border),
            itemBuilder: (BuildContext c, int i) => _OrderTile(
              summary: rows[i],
              arabic: arabic,
              showCompany: multipleCompanies,
            ),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.summary,
    required this.arabic,
    required this.showCompany,
  });

  final OrderSummary summary;
  final bool arabic;
  final bool showCompany;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final String? commune = summary.commune(arabic: arabic);

    return ListTile(
      key: Key('order.${summary.id}'),
      minVerticalPadding: SpaceTokens.space12,
      leading: Icon(
        // Routing information, not a status — never coloured.
        summary.deliveryType == DeliveryType.stopdesk
            ? Icons.storefront_outlined
            : Icons.home_outlined,
        color: colors.textSecondary,
      ),
      title: summary.needsCustomer
          ? _Badge(label: l10n.orderListNeedsCustomer)
          : AppText(summary.customerName!, AppTextStyle.body),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showCompany)
            AppText(
              summary.companyName,
              AppTextStyle.caption,
              color: colors.textSecondary,
            ),
          AppText(
            summary.trackingNumber,
            AppTextStyle.caption,
            color: colors.textSecondary,
          ),
          if (commune != null)
            AppText(
              summary.addressDetail == null
                  ? commune
                  : '$commune — ${summary.addressDetail}',
              AppTextStyle.bodySmall,
              color: colors.textSecondary,
            )
          else if (!summary.needsCustomer)
            // Only offered once there is a customer to attach it to — an
            // address with nobody to deliver it to is the customer badge's
            // job, not a second one saying the same absence twice.
            _Badge(label: l10n.orderListNeedsAddress),
        ],
      ),
      trailing: AppText(
        MoneyFormat.withCurrency(summary.codAmount, l10n.moneyCurrency),
        AppTextStyle.moneyBody,
        color: colors.moneyOwedFg,
      ),
    );
  }
}

/// Marks something the driver has not attached yet.
///
/// Neutral, in the same register as `customerNeedsPhoneReview`: a parcel
/// entered before its customer or address is an ordinary manifest case, not a
/// mistake, and colouring it as one would blame the driver for something they
/// did on purpose to keep moving.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpaceTokens.space8,
        vertical: SpaceTokens.space4,
      ),
      decoration: BoxDecoration(
        color: colors.statusNeutralBg,
        borderRadius: BorderRadius.circular(RadiusTokens.small),
      ),
      child: AppText(
        label,
        AppTextStyle.caption,
        color: colors.statusNeutralFg,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpaceTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppText(title, AppTextStyle.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: SpaceTokens.space8),
            AppText(
              body,
              AppTextStyle.bodySmall,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

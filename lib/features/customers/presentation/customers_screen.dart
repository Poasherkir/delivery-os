import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/customer.dart';
import '../../../shared/widgets/app_text.dart';
import '../controllers/customer_list_controller.dart';
import 'customer_form_screen.dart';
import 'customer_profile_screen.dart';

/// The customer list, reached from More.
///
/// Search is the primary affordance rather than browsing: by the time this is
/// useful there are hundreds of rows, and a driver arrives knowing either a
/// name or the digits off a parcel.
class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final AsyncValue<List<Customer>> customers = ref.watch(
      customerListProvider,
    );
    final String query = ref.watch(customerSearchProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(MoreEntry.customers.label(l10n), AppTextStyle.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('customers.new'),
        onPressed: () => context.push(CustomerFormScreen.newPath),
        icon: const Icon(Icons.person_add_outlined),
        label: AppText(l10n.customersNew, AppTextStyle.label),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(SpaceTokens.space16),
            child: TextField(
              key: const Key('customers.search'),
              onChanged: ref.read(customerSearchProvider.notifier).set,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.customersSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: customers.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              // The list failing is not the database failing — that has its own
              // screen. This is a query that went wrong, and the driver's next
              // move is to search again.
              error: (Object e, StackTrace s) =>
                  _Empty(title: l10n.customersNoResults),
              data: (List<Customer> rows) {
                if (rows.isEmpty) {
                  return _Empty(
                    // Two different empties. "Nothing matched" means try
                    // another word; "no customers" means there is nothing yet
                    // and says where they come from.
                    title: query.trim().isEmpty
                        ? l10n.customersEmptyTitle
                        : l10n.customersNoResults,
                    body: query.trim().isEmpty ? l10n.customersEmptyBody : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: SpaceTokens.space64),
                  itemCount: rows.length,
                  separatorBuilder: (BuildContext c, int i) =>
                      Divider(height: 1, color: colors.border),
                  itemBuilder: (BuildContext c, int i) =>
                      _CustomerTile(customer: rows[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return ListTile(
      key: Key('customer.${customer.id}'),
      // 48dp comes from the ListTile default; the constraint is stated so a
      // future dense variant does not quietly drop below it.
      minVerticalPadding: SpaceTokens.space12,
      title: AppText(customer.displayName, AppTextStyle.body),
      subtitle: AppText(
        // The unmasked number, deliberately: this is the driver's own screen
        // and dialling it is the point. Masking applies to logs and crash
        // payloads, not to the person who needs to read it.
        customer.phone?.e164 ?? customer.phoneRaw ?? '',
        AppTextStyle.bodySmall,
        color: colors.textSecondary,
      ),
      trailing: customer.needsPhoneReview
          ? _ReviewBadge(label: l10n.customerNeedsPhoneReview)
          : Icon(Icons.chevron_right, color: colors.textDisabled),
      // The profile, not the form. Tapping a customer to see who they are and
      // reach them is the common case; editing is a step taken from there.
      onTap: () => context.push(CustomerProfileScreen.pathFor(customer.id)),
    );
  }
}

/// Marks a number that never parsed.
///
/// Neutral, not an error colour. The driver did nothing wrong — the number is
/// most likely a landline in a format the validator does not know, and
/// colouring it red would blame them for our gap.
class _ReviewBadge extends StatelessWidget {
  const _ReviewBadge({required this.label});

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
  const _Empty({required this.title, this.body});

  final String title;
  final String? body;

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
            if (body != null) ...<Widget>[
              const SizedBox(height: SpaceTokens.space8),
              AppText(
                body!,
                AppTextStyle.bodySmall,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

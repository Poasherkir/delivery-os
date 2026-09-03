import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/money/money_format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/customer_history.dart';
import '../../../domain/entities/order_summary.dart';
import '../../../domain/repositories/customer_contact.dart';
import '../../../domain/value_objects/phone_e164.dart';
import '../../../shared/widgets/app_text.dart';
import '../controllers/customer_profile_controller.dart';
import 'customer_form_screen.dart';

/// One customer: how to reach them, where they live, what they have had.
///
/// **The history is windowed.** A customer the driver has delivered to for a
/// year has a few hundred parcels, and this is a detail view opened mid-round.
/// It shows the fifty most recent and says so; loading the rest is a tap the
/// driver takes, not something they get for opening a screen.
class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({required this.customerId, super.key});

  final String customerId;

  static const String pathPattern = '/customers/:id/profile';

  static String pathFor(String id) => '/customers/$id/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final AsyncValue<CustomerProfile?> profile = ref.watch(
      customerProfileProvider(customerId),
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.customerProfileTitle, AppTextStyle.title),
        actions: <Widget>[
          if (profile.value != null)
            TextButton(
              key: const Key('customerProfile.edit'),
              onPressed: () =>
                  context.push(CustomerFormScreen.editPath(customerId)),
              child: AppText(l10n.customerEdit, AppTextStyle.label),
            ),
        ],
      ),
      body: profile.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        // A customer that cannot be loaded is not a database failure — that
        // has its own screen. Most likely they were merged away or deleted
        // while this route was on the stack.
        error: (Object e, StackTrace s) => const SizedBox.expand(),
        data: (CustomerProfile? data) =>
            data == null ? const SizedBox.expand() : _Body(profile: data),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile});

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';

    return ListView(
      padding: const EdgeInsets.only(bottom: SpaceTokens.space32),
      children: <Widget>[
        _Header(customer: profile.customer),
        const SizedBox(height: SpaceTokens.space8),

        _SectionHeading(l10n.customerAddressesTitle),
        if (profile.addresses.isEmpty)
          _Muted(l10n.customerAddressesEmpty)
        else
          for (final Address address in profile.addresses)
            _AddressTile(address: address),

        const SizedBox(height: SpaceTokens.space16),
        _SectionHeading(l10n.customerHistoryTitle),
        if (profile.history.isEmpty)
          _Muted(l10n.customerHistoryEmpty)
        else ...<Widget>[
          for (final OrderSummary order in profile.history.recent)
            _HistoryTile(summary: order, arabic: arabic),
          if (profile.history.isWindowed) _ShowAll(history: profile.history),
        ],
      ],
    );
  }
}

/// Name, number, and the two things a driver does with a number.
class _Header extends ConsumerWidget {
  const _Header({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final PhoneE164? phone = customer.phone;

    return Padding(
      padding: const EdgeInsets.all(SpaceTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText(customer.displayName, AppTextStyle.headline),
          const SizedBox(height: SpaceTokens.space4),
          AppText(
            // The unmasked number: this is the driver's own screen and reading
            // it is the point. Masking is for logs and crash payloads.
            phone?.e164 ?? customer.phoneRaw ?? '',
            AppTextStyle.body,
            color: colors.textSecondary,
          ),

          const SizedBox(height: SpaceTokens.space16),
          if (phone == null)
            // Says why there are no buttons instead of leaving them absent
            // with no reason, and phrases it as our failure to read the
            // number rather than the driver's to type it.
            _Notice(
              key: const Key('customerProfile.needsReview'),
              text: l10n.customerPhoneNeedsReview,
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: _ContactButton(
                    key: const Key('customerProfile.call'),
                    icon: Icons.call_outlined,
                    label: l10n.customerActionCall,
                    onPressed: (CustomerContact contact) => contact.dial(phone),
                  ),
                ),
                // Only for a mobile. A landline cannot have WhatsApp, and a
                // button that always fails is worse than one that is absent.
                if (phone.isMobile) ...<Widget>[
                  const SizedBox(width: SpaceTokens.space8),
                  Expanded(
                    child: _ContactButton(
                      key: const Key('customerProfile.whatsapp'),
                      icon: Icons.chat_outlined,
                      label: l10n.customerActionWhatsApp,
                      onPressed: (CustomerContact contact) =>
                          contact.whatsApp(phone),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// A contact action that reports when nothing could handle it.
class _ContactButton extends ConsumerWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final Future<bool> Function(CustomerContact) onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);

    return SizedBox(
      // The two actions this screen exists for.
      height: 56,
      child: FilledButton.icon(
        onPressed: () async {
          final bool launched = await onPressed(
            ref.read(customerContactProvider),
          );
          if (launched || !context.mounted) {
            return;
          }
          // A button that silently does nothing is worse than one that says
          // it could not. Most often this is WhatsApp not being installed.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                l10n.customerActionUnavailable,
                AppTextStyle.body,
              ),
            ),
          );
        },
        icon: Icon(icon),
        label: AppText(label, AppTextStyle.label),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return ListTile(
      key: Key('customerProfile.address.${address.id}'),
      minVerticalPadding: SpaceTokens.space12,
      leading: Icon(Icons.place_outlined, color: colors.textSecondary),
      title: AppText(address.detail ?? address.label ?? '', AppTextStyle.body),
      subtitle: address.isPrimary
          ? AppText(
              l10n.customerAddressPrimary,
              AppTextStyle.caption,
              color: colors.textSecondary,
            )
          : null,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.summary, required this.arabic});

  final OrderSummary summary;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;
    final String? commune = summary.commune(arabic: arabic);

    return ListTile(
      key: Key('customerProfile.order.${summary.id}'),
      minVerticalPadding: SpaceTokens.space12,
      title: AppText(summary.trackingNumber, AppTextStyle.body),
      subtitle: AppText(
        // The day, then where it went. No status: nothing before M2 writes
        // one, so every row would read the same word.
        commune == null
            ? summary.serviceDate
            : '${summary.serviceDate} — $commune',
        AppTextStyle.caption,
        color: colors.textSecondary,
      ),
      trailing: AppText(
        MoneyFormat.withCurrency(summary.codAmount, l10n.moneyCurrency),
        AppTextStyle.moneyBody,
        color: colors.moneyOwedFg,
      ),
    );
  }
}

/// Says what is hidden, and offers to load it.
class _ShowAll extends ConsumerWidget {
  const _ShowAll({required this.history});

  final CustomerHistory history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(SpaceTokens.space16),
      child: Column(
        children: <Widget>[
          AppText(
            l10n.customerHistoryShowingSome(
              history.recent.length,
              history.total,
            ),
            AppTextStyle.caption,
            color: colors.textSecondary,
          ),
          const SizedBox(height: SpaceTokens.space8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              key: const Key('customerProfile.showAll'),
              onPressed: () =>
                  ref.read(customerHistoryWindow.notifier).showAll(),
              child: AppText(l10n.customerHistoryShowAll, AppTextStyle.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpaceTokens.space16,
      SpaceTokens.space16,
      SpaceTokens.space16,
      SpaceTokens.space8,
    ),
    child: AppText(text, AppTextStyle.label),
  );
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpaceTokens.space16),
    child: AppText(
      text,
      AppTextStyle.bodySmall,
      color: context.colors.textSecondary,
    ),
  );
}

/// A calm inline message, in the same register as the entry form's.
class _Notice extends StatelessWidget {
  const _Notice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(SpaceTokens.space12),
      decoration: BoxDecoration(
        color: colors.statusNeutralBg,
        borderRadius: BorderRadius.circular(RadiusTokens.small),
      ),
      child: AppText(
        text,
        AppTextStyle.bodySmall,
        color: colors.statusNeutralFg,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/company.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/value_objects/centimes.dart';
import '../../../domain/value_objects/delivery_type.dart';
import '../../../shared/widgets/app_text.dart';
import '../../companies/presentation/company_form_screen.dart';
import '../../customers/controllers/customer_lookup_controller.dart';
import '../../ingestion/presentation/scanner_screen.dart';
import '../controllers/order_entry_controller.dart';
import '../controllers/selected_company_controller.dart';
import 'commune_picker_sheet.dart';

/// Enter one parcel.
///
/// The screen the four-minute gate measures, so every decision on it is a
/// decision about taps. **Only the tracking number is required.** A driver
/// standing in an agency at 07:00 must not be stopped by a field, and a parcel
/// with no customer yet is enterable even though it is not deliverable.
///
/// The company is a header, not a field: it is chosen once per batch and never
/// per order. There is no date field either — the batch carries the service
/// date, derived from the 04:00 cutoff, and choosing it is a batch screen's job
/// in M2.
class OrderEntryScreen extends ConsumerStatefulWidget {
  const OrderEntryScreen({super.key, this.scannedTracking});

  /// Pre-filled from a scan, when the driver arrived that way.
  final String? scannedTracking;

  static const String path = '/orders/new';

  @override
  ConsumerState<OrderEntryScreen> createState() => _OrderEntryScreenState();
}

class _OrderEntryScreenState extends ConsumerState<OrderEntryScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _tracking = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _cod = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  /// Focused after a save, so the loop is scan, phone, save, scan.
  final FocusNode _phoneFocus = FocusNode();

  Commune? _commune;
  DeliveryType _deliveryType = DeliveryType.home;
  bool _saving = false;

  /// Every company the driver could file this parcel under.
  ///
  /// Held so the screen can tell two states apart that look the same from the
  /// selection alone: nobody has any companies yet, and nobody has chosen
  /// between the several that exist. The first needs a way in; the second needs
  /// a list.
  List<Company> _companies = const <Company>[];
  bool _resolving = true;

  /// The parcel already carrying this tracking number, when there is one.
  Order? _duplicate;

  @override
  void initState() {
    super.initState();
    _tracking.text = widget.scannedTracking ?? '';
    _resolveCompany();
  }

  Future<void> _resolveCompany() async {
    // Picks the only company there is, so a driver with one never sees a
    // chooser. With several it stays null and the chooser appears, because
    // guessing would be guessing about which batch the parcel joins.
    await ref.read(selectedCompanyProvider.notifier).resolve();
    final List<Company> found =
        await ref.read(companyRepositoryProvider)?.selectable() ??
        const <Company>[];

    if (!mounted) {
      return;
    }
    setState(() {
      _companies = found;
      _resolving = false;
    });
  }

  @override
  void dispose() {
    _tracking.dispose();
    _phone.dispose();
    _name.dispose();
    _address.dispose();
    _cod.dispose();
    _notes.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController field) {
    final String text = field.text.trim();
    return text.isEmpty ? null : text;
  }

  /// Whole dinars to centimes.
  ///
  /// The field accepts digits only, so there is nothing here to round and no
  /// place a fraction of a dinar could be silently dropped. Invariant 1: money
  /// is `int` centimes, and this is the one door it comes in by.
  Centimes get _codAmount {
    final int? dinars = int.tryParse(_cod.text.trim());
    return dinars == null ? Centimes.zero : Centimes.fromDinars(dinars);
  }

  Future<void> _save({required bool thenScan}) async {
    if (!(_form.currentState?.validate() ?? false) || _saving) {
      return;
    }
    final Company? company = ref.read(selectedCompanyProvider);
    if (company == null) {
      return;
    }

    setState(() {
      _saving = true;
      _duplicate = null;
    });

    final OrderEntryResult result = await ref
        .read(orderEntryControllerProvider)
        .submit(
          OrderDraft(
            companyId: company.id,
            trackingNumber: _tracking.text,
            phone: _phone.text,
            customerName: _name.text,
            wilayaCode: _commune?.wilayaCode,
            communeId: _commune?.id,
            addressDetail: _address.text,
            codAmount: _codAmount,
            deliveryType: _deliveryType,
            notes: _optional(_notes),
          ),
        );

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    switch (result) {
      case OrderEntryDuplicate(:final Order existing):
        setState(() => _duplicate = existing);
      case OrderEntryUnavailable():
        // Nothing was written and nothing pretends otherwise.
        return;
      case OrderEntrySaved():
        _afterSave(thenScan: thenScan);
    }
  }

  void _afterSave({required bool thenScan}) {
    final AppL10n l10n = AppL10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText(l10n.orderSaved, AppTextStyle.body)),
    );

    if (!thenScan) {
      context.pop();
      return;
    }

    // Straight back to the camera, with the form cleared but the company and
    // the delivery type kept. Those two are properties of the batch and of the
    // manifest, not of the parcel, and re-choosing them per parcel is the tax
    // the four-minute gate cannot afford.
    _clearForNext();
    unawaited(_rescan());
  }

  void _clearForNext() {
    _tracking.clear();
    _phone.clear();
    _name.clear();
    _address.clear();
    _cod.clear();
    _notes.clear();
    ref.read(customerLookupProvider.notifier).onPhoneChanged('');
    setState(() => _commune = null);
  }

  Future<void> _rescan() async {
    final String? scanned = await context.push<String>(ScannerScreen.path);
    if (!mounted) {
      return;
    }
    setState(() => _tracking.text = scanned ?? '');
    _phoneFocus.requestFocus();
  }

  Future<void> _pickCommune() async {
    final Commune? chosen = await CommunePickerSheet.show(context);
    if (chosen != null && mounted) {
      setState(() => _commune = chosen);
    }
  }

  Future<void> _addCompany() async {
    final Company? created = await context.push<Company>(
      CompanyFormScreen.newPath,
    );
    if (created == null || !mounted) {
      return;
    }
    ref.read(selectedCompanyProvider.notifier).select(created);
    setState(() => _companies = <Company>[..._companies, created]);
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final Company? company = ref.watch(selectedCompanyProvider);
    final CustomerLookup lookup = ref.watch(customerLookupProvider);
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: AppText(l10n.orderNewTitle, AppTextStyle.title)),
      body: _resolving
          ? const SizedBox.expand()
          : company == null
          ? (_companies.isEmpty
                ? _NoCompany(onAdd: _addCompany)
                : _CompanyChooser(
                    companies: _companies,
                    onPick: (Company c) =>
                        ref.read(selectedCompanyProvider.notifier).select(c),
                    onAdd: _addCompany,
                  ))
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(SpaceTokens.space16),
                children: <Widget>[
                  _CompanyHeader(company: company),

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('orderEntry.tracking'),
                    controller: _tracking,
                    decoration: InputDecoration(
                      labelText: l10n.orderFieldTracking,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? v) => (v ?? '').trim().isEmpty
                        ? l10n.orderTrackingRequired
                        : null,
                  ),

                  if (_duplicate != null) ...<Widget>[
                    const SizedBox(height: SpaceTokens.space8),
                    _Notice(
                      key: const Key('orderEntry.duplicate'),
                      text: l10n.orderDuplicateTracking,
                    ),
                  ],

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('orderEntry.phone'),
                    controller: _phone,
                    focusNode: _phoneFocus,
                    autofocus: widget.scannedTracking != null,
                    keyboardType: TextInputType.phone,
                    onChanged: (String v) {
                      ref
                          .read(customerLookupProvider.notifier)
                          .onPhoneChanged(v);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: l10n.orderFieldPhone,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  ...switch (lookup) {
                    LookupIdle() ||
                    LookupSearching() ||
                    LookupNew() => const <Widget>[],

                    // Not a validation error. It does not block saving and it
                    // says what will happen rather than refusing.
                    LookupUnrecognized() => <Widget>[
                      const SizedBox(height: SpaceTokens.space8),
                      _Notice(
                        key: const Key('orderEntry.unrecognized'),
                        text: l10n.customerPhoneUnrecognized,
                      ),
                    ],

                    LookupExisting() => <Widget>[
                      const SizedBox(height: SpaceTokens.space8),
                      _Notice(
                        key: const Key('orderEntry.existing'),
                        text: l10n.customerLookupExisting,
                      ),
                    ],
                  },

                  // Hidden once the number belongs to somebody: an existing
                  // customer is recognised, not retyped.
                  if (lookup is! LookupExisting) ...<Widget>[
                    const SizedBox(height: SpaceTokens.space16),
                    TextFormField(
                      key: const Key('orderEntry.name'),
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.orderFieldName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: SpaceTokens.space16),
                  _CommuneField(
                    commune: _commune,
                    arabic: arabic,
                    onTap: _pickCommune,
                  ),

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('orderEntry.address'),
                    controller: _address,
                    decoration: InputDecoration(
                      labelText: l10n.orderFieldAddress,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('orderEntry.cod'),
                    controller: _cod,
                    // Digits only, so there is no fraction of a dinar to round
                    // away and no decimal separator to disagree about.
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.orderFieldCod,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: SpaceTokens.space24),
                  AppText(l10n.orderFieldDelivery, AppTextStyle.label),
                  const SizedBox(height: SpaceTokens.space8),
                  _DeliveryTypeToggle(
                    value: _deliveryType,
                    onChanged: (DeliveryType v) =>
                        setState(() => _deliveryType = v),
                  ),

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('orderEntry.notes'),
                    controller: _notes,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.orderFieldNotes,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: SpaceTokens.space32),
                  SizedBox(
                    // The largest thing on the screen, because it is the loop
                    // the four-minute gate measures.
                    height: 64,
                    child: FilledButton.icon(
                      key: const Key('orderEntry.saveAndScan'),
                      onPressed: _saving ? null : () => _save(thenScan: true),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: AppText(l10n.orderSaveAndNext, AppTextStyle.label),
                    ),
                  ),

                  const SizedBox(height: SpaceTokens.space8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      key: const Key('orderEntry.save'),
                      onPressed: _saving ? null : () => _save(thenScan: false),
                      child: AppText(l10n.orderSave, AppTextStyle.label),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Choose between the companies that exist.
///
/// Shown only when there are several and none is selected. One company is
/// selected without asking, because a picker with a single row is a tap that
/// answers a question the driver was not asked.
class _CompanyChooser extends StatelessWidget {
  const _CompanyChooser({
    required this.companies,
    required this.onPick,
    required this.onAdd,
  });

  final List<Company> companies;
  final ValueChanged<Company> onPick;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(SpaceTokens.space16),
      children: <Widget>[
        AppText(l10n.orderCompanyLabel, AppTextStyle.label),
        const SizedBox(height: SpaceTokens.space8),
        for (final Company company in companies)
          SizedBox(
            height: 56,
            child: OutlinedButton(
              key: Key('orderEntry.pickCompany.\${company.id}'),
              onPressed: () => onPick(company),
              child: AppText(company.name, AppTextStyle.body),
            ),
          ),
        const SizedBox(height: SpaceTokens.space16),
        SizedBox(
          height: 48,
          child: TextButton(
            key: const Key('orderEntry.addCompany'),
            onPressed: onAdd,
            child: AppText(l10n.orderNoCompanyAction, AppTextStyle.label),
          ),
        ),
      ],
    );
  }
}

/// Which company today's parcels came from.
///
/// A header rather than a field, because it is chosen once per batch. Reading
/// it is the point: a driver working two companies in one morning has to be
/// able to see, without tapping, which batch this parcel is joining.
class _CompanyHeader extends ConsumerWidget {
  const _CompanyHeader({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Container(
      key: const Key('orderEntry.company'),
      padding: const EdgeInsets.all(SpaceTokens.space12),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(RadiusTokens.small),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText(
                  l10n.orderCompanyLabel,
                  AppTextStyle.caption,
                  color: colors.textSecondary,
                ),
                AppText(company.name, AppTextStyle.body),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: TextButton(
              key: const Key('orderEntry.changeCompany'),
              onPressed: () =>
                  ref.read(selectedCompanyProvider.notifier).clear(),
              child: AppText(l10n.orderCompanyChange, AppTextStyle.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// The commune, opened as a sheet rather than typed into.
class _CommuneField extends StatelessWidget {
  const _CommuneField({
    required this.commune,
    required this.arabic,
    required this.onTap,
  });

  final Commune? commune;
  final bool arabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final Commune? chosen = commune;

    return InkWell(
      key: const Key('orderEntry.commune'),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.orderFieldCommune,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.search),
        ),
        child: SizedBox(
          // 48dp even when it holds nothing: an empty field a driver has to
          // hit one-handed is the same target as a full one.
          height: 24,
          child: AppText(
            chosen == null ? '' : (arabic ? chosen.nameAr : chosen.nameFr),
            AppTextStyle.body,
          ),
        ),
      ),
    );
  }
}

/// Home or stop desk.
///
/// Two states and one tap, not a dropdown. Roughly half of Algerian COD volume
/// is stop desk, it cannot be derived from anything else — it comes off the
/// label — and a stop-desk parcel must never enter the optimized route. The
/// cost is one tap on a minority of parcels; without it M4 sends the driver to
/// a customer's house for a parcel waiting at an agency.
class _DeliveryTypeToggle extends StatelessWidget {
  const _DeliveryTypeToggle({required this.value, required this.onChanged});

  final DeliveryType value;
  final ValueChanged<DeliveryType> onChanged;

  String _label(AppL10n l10n, DeliveryType type) => switch (type) {
    DeliveryType.home => l10n.orderDeliveryHome,
    DeliveryType.stopdesk => l10n.orderDeliveryStopdesk,
  };

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return SizedBox(
      height: 48,
      child: SegmentedButton<DeliveryType>(
        key: const Key('orderEntry.deliveryType'),
        segments: <ButtonSegment<DeliveryType>>[
          for (final DeliveryType type in DeliveryType.values)
            ButtonSegment<DeliveryType>(
              value: type,
              label: AppText(_label(l10n, type), AppTextStyle.caption),
            ),
        ],
        selected: <DeliveryType>{value},
        showSelectedIcon: false,
        onSelectionChanged: (Set<DeliveryType> s) => onChanged(s.first),
      ),
    );
  }
}

/// Before any company exists.
///
/// Nothing is seeded to avoid this state: an invented company would end up in
/// a settlement. So the first morning starts here, once.
class _NoCompany extends StatelessWidget {
  const _NoCompany({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpaceTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppText(l10n.orderNoCompanyTitle, AppTextStyle.title),
            const SizedBox(height: SpaceTokens.space8),
            AppText(
              l10n.orderNoCompanyBody,
              AppTextStyle.body,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpaceTokens.space24),
            SizedBox(
              height: 56,
              child: FilledButton(
                key: const Key('orderEntry.addCompany'),
                onPressed: onAdd,
                child: AppText(l10n.orderNoCompanyAction, AppTextStyle.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A calm inline message. Not an error style — none of these is the driver's
/// fault and each has a next step rather than a refusal.
class _Notice extends StatelessWidget {
  const _Notice({super.key, required this.text});

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/value_objects/customer_risk_flag.dart';
import '../../../domain/value_objects/phone_e164.dart';
import '../../../shared/widgets/app_text.dart';
import '../controllers/customer_list_controller.dart';

/// Create or edit a customer.
///
/// **A number that will not parse does not block saving.** A driver standing in
/// an agency at 07:00 cannot be stopped because our validator disagrees with a
/// real landline — Algeria closed its numbering plan in 2008 and older formats
/// are shorter than the nine digits `PhoneE164` expects. The form says what
/// will happen and saves the string verbatim, flagged for correction later.
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  /// Null when creating.
  final String? customerId;

  static const String newPath = '/customers/new';
  static const String editPathPattern = '/customers/:id';

  static String editPath(String id) => '/customers/$id';

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  CustomerRiskFlag _risk = CustomerRiskFlag.none;
  Customer? _existing;
  bool _loading = true;
  bool _saving = false;

  /// The customer already holding the number, when there is one.
  Customer? _duplicate;

  bool get _isNew => widget.customerId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isNew) {
      setState(() => _loading = false);
      return;
    }
    final CustomerRepository? repo = ref.read(customerRepositoryProvider);
    final List<Customer> all = await repo?.all() ?? const <Customer>[];
    final Customer? found = all
        .where((Customer c) => c.id == widget.customerId)
        .firstOrNull;

    if (!mounted) {
      return;
    }
    setState(() {
      _existing = found;
      _loading = false;
      if (found != null) {
        _name.text = found.displayName;
        _phone.text = found.phone?.e164 ?? found.phoneRaw ?? '';
        _notes.text = found.notes ?? '';
        _risk = found.riskFlag;
      }
    });
  }

  /// Whether the number as typed would be kept verbatim rather than normalized.
  bool get _phoneUnrecognized {
    final String raw = _phone.text.trim();
    return raw.isNotEmpty && PhoneE164.tryParse(raw) == null;
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false) || _saving) {
      return;
    }
    final CustomerRepository? repo = ref.read(customerRepositoryProvider);
    if (repo == null) {
      return;
    }

    setState(() {
      _saving = true;
      _duplicate = null;
    });

    final String rawPhone = _phone.text.trim();
    final PhoneE164? parsed = PhoneE164.tryParse(rawPhone);
    final String? notes = _notes.text.trim().isEmpty
        ? null
        : _notes.text.trim();

    try {
      if (_isNew) {
        if (parsed != null) {
          await repo.create(
            phone: parsed,
            displayName: _name.text.trim(),
            notes: notes,
            riskFlag: _risk,
          );
        } else {
          await repo.createUnparsed(
            rawPhone: rawPhone,
            displayName: _name.text.trim(),
            notes: notes,
          );
        }
      } else {
        final Customer current = _existing!;
        // Correcting an unparsed number is its own operation, because it also
        // clears the raw string and takes the customer off the review list.
        if (parsed != null && current.needsPhoneReview) {
          await repo.resolvePhone(current: current, phone: parsed);
        }
        await repo.edit(
          current: current,
          displayName: _name.text.trim(),
          notes: notes,
          riskFlag: _risk,
        );
      }
    } on DuplicatePhoneException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _duplicate = e.existing;
      });
      return;
    }

    ref.invalidate(customerListProvider);
    if (mounted) {
      // Navigator rather than context.pop(): dismissing a pushed form needs no
      // router-specific behaviour, and depending on one would make this screen
      // untestable outside a full router.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          _isNew ? l10n.customersNew : l10n.customerFormEditTitle,
          AppTextStyle.title,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(SpaceTokens.space16),
                children: <Widget>[
                  TextFormField(
                    key: const Key('customerForm.name'),
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.customerFieldName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? v) => (v ?? '').trim().isEmpty
                        ? l10n.customerNameRequired
                        : null,
                  ),
                  const SizedBox(height: SpaceTokens.space16),

                  TextFormField(
                    key: const Key('customerForm.phone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.customerFieldPhone,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? v) => (v ?? '').trim().isEmpty
                        ? l10n.customerPhoneRequired
                        : null,
                  ),

                  // Not a validation error: it does not block saving, and it is
                  // phrased as what will happen rather than as a refusal.
                  if (_phoneUnrecognized) ...<Widget>[
                    const SizedBox(height: SpaceTokens.space8),
                    _Notice(
                      key: const Key('customerForm.unrecognized'),
                      text: l10n.customerPhoneUnrecognized,
                    ),
                  ],

                  if (_duplicate != null) ...<Widget>[
                    const SizedBox(height: SpaceTokens.space8),
                    _Notice(
                      key: const Key('customerForm.duplicate'),
                      text: l10n.customerDuplicate(_duplicate!.displayName),
                      action: l10n.customerDuplicateOpen,
                      onAction: () => context.pushReplacement(
                        CustomerFormScreen.editPath(_duplicate!.id),
                      ),
                    ),
                  ],

                  const SizedBox(height: SpaceTokens.space16),
                  TextFormField(
                    key: const Key('customerForm.notes'),
                    controller: _notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.customerFieldNotes,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: SpaceTokens.space24),
                  AppText(l10n.customerFieldRisk, AppTextStyle.label),
                  const SizedBox(height: SpaceTokens.space8),
                  _RiskPicker(
                    value: _risk,
                    onChanged: (CustomerRiskFlag v) =>
                        setState(() => _risk = v),
                  ),

                  const SizedBox(height: SpaceTokens.space32),
                  SizedBox(
                    // The next action is the largest tappable thing on screen.
                    height: 56,
                    child: FilledButton(
                      key: const Key('customerForm.save'),
                      onPressed: _saving ? null : _save,
                      child: AppText(l10n.customerSave, AppTextStyle.label),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// A calm inline message. Not an error style — neither case is the driver's
/// fault, and both have a next step rather than a refusal.
class _Notice extends StatelessWidget {
  const _Notice({super.key, required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(SpaceTokens.space12),
      decoration: BoxDecoration(
        color: colors.statusNeutralBg,
        borderRadius: BorderRadius.circular(RadiusTokens.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText(text, AppTextStyle.bodySmall, color: colors.statusNeutralFg),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: SpaceTokens.space4),
              child: SizedBox(
                height: 48,
                child: TextButton(
                  key: const Key('customerForm.duplicateOpen'),
                  onPressed: onAction,
                  child: AppText(action!, AppTextStyle.label),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RiskPicker extends StatelessWidget {
  const _RiskPicker({required this.value, required this.onChanged});

  final CustomerRiskFlag value;
  final ValueChanged<CustomerRiskFlag> onChanged;

  String _label(AppL10n l10n, CustomerRiskFlag flag) => switch (flag) {
    CustomerRiskFlag.none => l10n.customerRiskNone,
    CustomerRiskFlag.watch => l10n.customerRiskWatch,
    CustomerRiskFlag.problem => l10n.customerRiskProblem,
  };

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return SegmentedButton<CustomerRiskFlag>(
      segments: <ButtonSegment<CustomerRiskFlag>>[
        for (final CustomerRiskFlag flag in CustomerRiskFlag.values)
          ButtonSegment<CustomerRiskFlag>(
            value: flag,
            label: AppText(_label(l10n, flag), AppTextStyle.caption),
          ),
      ],
      selected: <CustomerRiskFlag>{value},
      showSelectedIcon: false,
      onSelectionChanged: (Set<CustomerRiskFlag> s) => onChanged(s.first),
    );
  }
}

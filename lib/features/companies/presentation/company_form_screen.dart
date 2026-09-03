import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/company.dart';
import '../../../domain/repositories/company_repository.dart';
import '../../../shared/widgets/app_text.dart';

/// Create a company.
///
/// Three fields, and only the name is required. A company is chosen once per
/// batch and never per order, so this screen is opened rarely — usually once,
/// on the first morning, out of the entry form's empty state.
///
/// Pops the created [Company] so a caller that needed one can carry straight
/// on. Nothing is seeded anywhere: an invented company would end up in a
/// settlement.
class CompanyFormScreen extends ConsumerStatefulWidget {
  const CompanyFormScreen({super.key});

  static const String newPath = '/companies/new';

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController field) {
    final String text = field.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false) || _saving) {
      return;
    }
    final CompanyRepository? repo = ref.read(companyRepositoryProvider);
    if (repo == null) {
      return;
    }

    setState(() => _saving = true);
    final Company created = await repo.create(
      name: _name.text.trim(),
      contactPhone: _optional(_phone),
      notes: _optional(_notes),
    );

    if (!mounted) {
      return;
    }
    // Popped rather than dropped: the entry form sent the driver here because
    // it had no company, and it can select this one without a second tap.
    context.pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: AppText(l10n.companyNewTitle, AppTextStyle.title)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(SpaceTokens.space16),
          children: <Widget>[
            TextFormField(
              key: const Key('companyForm.name'),
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.companyFieldName,
                border: const OutlineInputBorder(),
              ),
              validator: (String? v) =>
                  (v ?? '').trim().isEmpty ? l10n.companyNameRequired : null,
            ),

            const SizedBox(height: SpaceTokens.space16),
            TextFormField(
              key: const Key('companyForm.phone'),
              controller: _phone,
              // Free text, not a validated number: an agency hands out a mobile
              // and a landline together and both are useful to a driver.
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.companyFieldPhone,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: SpaceTokens.space16),
            TextFormField(
              key: const Key('companyForm.notes'),
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.companyFieldNotes,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: SpaceTokens.space32),
            SizedBox(
              // The next action is the largest tappable thing on screen.
              height: 56,
              child: FilledButton(
                key: const Key('companyForm.save'),
                onPressed: _saving ? null : _save,
                child: AppText(l10n.companySave, AppTextStyle.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

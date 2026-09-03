import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/routes.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/company.dart';
import '../../../domain/repositories/company_repository.dart';
import '../../../shared/widgets/app_text.dart';
import 'company_form_screen.dart';

/// The companies the driver works for, reached from More.
///
/// A short list — a driver has three, not thirty — so it is a plain list with
/// no search. Ordered by name rather than by recency, because a list that
/// reorders itself under the thumb is worse than one that does not.
class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  List<Company> _companies = const <Company>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final CompanyRepository? repo = ref.read(companyRepositoryProvider);
    final List<Company> found = await repo?.selectable() ?? const <Company>[];
    if (!mounted) {
      return;
    }
    setState(() {
      _companies = found;
      _loading = false;
    });
  }

  Future<void> _add() async {
    await context.push<Company>(CompanyFormScreen.newPath);
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText(MoreEntry.companies.label(l10n), AppTextStyle.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('companies.new'),
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: AppText(l10n.companiesNew, AppTextStyle.label),
      ),
      body: _loading
          ? const SizedBox.expand()
          : _companies.isEmpty
          ? const _Empty()
          : ListView.builder(
              itemCount: _companies.length,
              itemBuilder: (BuildContext context, int index) {
                final Company company = _companies[index];
                return ListTile(
                  key: Key('companies.row.${company.id}'),
                  // 48dp minimum: the driver is tapping one-handed.
                  minTileHeight: 56,
                  title: AppText(company.name, AppTextStyle.body),
                  subtitle: company.contactPhone == null
                      ? null
                      : AppText(company.contactPhone!, AppTextStyle.caption),
                );
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpaceTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppText(l10n.companiesEmptyTitle, AppTextStyle.title),
            const SizedBox(height: SpaceTokens.space8),
            AppText(
              l10n.companiesEmptyBody,
              AppTextStyle.body,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../shared/widgets/app_text.dart';

/// Placeholder for the customers screen, reached from More.
///
/// Pushed onto the root navigator, so it covers the bottom bar rather than
/// nesting inside a tab.
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          MoreEntry.customers.label(AppL10n.of(context)),
          AppTextStyle.title,
        ),
      ),
      body: const SizedBox.expand(),
    );
  }
}

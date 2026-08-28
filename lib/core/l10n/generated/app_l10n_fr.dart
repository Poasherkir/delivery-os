// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Delivery OS';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Automatique';
}

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

  @override
  String get navHome => 'Accueil';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navRoute => 'Itinéraire';

  @override
  String get navMoney => 'Finances';

  @override
  String get navMore => 'Plus';

  @override
  String get navCustomers => 'Clients';

  @override
  String get navCompanies => 'Sociétés';

  @override
  String get navHistory => 'Historique';

  @override
  String get navSettings => 'Paramètres';
}

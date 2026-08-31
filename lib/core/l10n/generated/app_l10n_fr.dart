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

  @override
  String get dbErrorTitle => 'Impossible d\'ouvrir vos données';

  @override
  String get dbErrorStillTrue =>
      'Vos colis et le travail d\'aujourd\'hui ne sont pas perdus. L\'entreprise garde sa propre trace du lot. Ce qui manque, c\'est la copie de l\'application — pas votre argent.';

  @override
  String get dbErrorReconcile =>
      'Avant toute autre chose, comparez l\'argent encaissé aujourd\'hui avec le bordereau de l\'entreprise.';

  @override
  String get dbErrorStep1 => 'Réessayez.';

  @override
  String get dbErrorStep2 => 'Redémarrez le téléphone, puis réessayez.';

  @override
  String get dbErrorRetry => 'Réessayer';

  @override
  String get dbErrorWhyLabel => 'Pourquoi ?';

  @override
  String get dbErrorWhyBody =>
      'Cela peut arriver après la restauration d\'un téléphone depuis une sauvegarde, ou après le passage à un nouvel appareil : les données peuvent être copiées, mais pas ce qui permet de les ouvrir.';
}

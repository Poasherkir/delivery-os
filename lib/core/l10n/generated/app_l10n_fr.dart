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

  @override
  String get dbErrorOtherOptions => 'Autres options';

  @override
  String get dbErrorResetFailed =>
      'La réinitialisation ne s\'est pas terminée.';

  @override
  String get resetTitle => 'Effacer les données et recommencer';

  @override
  String get resetLosesIntro =>
      'Ceci supprime définitivement ce que l\'application a enregistré sur ce téléphone :';

  @override
  String get resetLosesDeliveries => 'les livraisons et leur historique';

  @override
  String get resetLosesCustomers =>
      'les clients et leurs adresses enregistrées';

  @override
  String get resetLosesMoney => 'les encaissements et les règlements';

  @override
  String get resetIrreversible => 'Rien de tout cela ne peut être récupéré.';

  @override
  String get resetReconcileFirst =>
      'Si ce n\'est pas déjà fait, comparez d\'abord l\'argent encaissé avec le bordereau de l\'entreprise. C\'est le dernier moment pour le faire.';

  @override
  String get resetCancel => 'Annuler';

  @override
  String get resetContinue => 'Continuer';

  @override
  String get resetHoldTitle => 'Maintenez pour supprimer';

  @override
  String get resetHoldInstruction => 'Appuyez et maintenez pendant 3 secondes.';

  @override
  String get resetHoldAction => 'Maintenir pour supprimer définitivement';

  @override
  String get resetDoneTitle => 'L\'application a redémarré à zéro';

  @override
  String get resetDoneBody =>
      'Les anciennes données ont été supprimées. Vous pouvez commencer une nouvelle journée.';

  @override
  String get resetDoneAction => 'Commencer';

  @override
  String get customersSearchHint => 'Rechercher un client';

  @override
  String get customersEmptyTitle => 'Aucun client';

  @override
  String get customersEmptyBody =>
      'Les clients apparaissent ici dès la première commande saisie.';

  @override
  String get customersNoResults => 'Aucun résultat pour cette recherche.';

  @override
  String get customersNew => 'Nouveau client';

  @override
  String get customerNeedsPhoneReview => 'Numéro à vérifier';

  @override
  String get customerFormEditTitle => 'Modifier le client';

  @override
  String get customerFieldName => 'Nom';

  @override
  String get customerFieldPhone => 'Téléphone';

  @override
  String get customerFieldPhoneAlt => 'Autre numéro';

  @override
  String get customerFieldNotes => 'Notes';

  @override
  String get customerFieldRisk => 'Signalement';

  @override
  String get customerRiskNone => 'Aucun';

  @override
  String get customerRiskWatch => 'Appeler avant de partir';

  @override
  String get customerRiskProblem => 'Client à problème';

  @override
  String get customerSave => 'Enregistrer';

  @override
  String get customerNameRequired => 'Le nom est obligatoire.';

  @override
  String get customerPhoneRequired => 'Le numéro est obligatoire.';

  @override
  String get customerPhoneUnrecognized =>
      'Numéro non reconnu. Il sera enregistré tel quel, à corriger plus tard.';

  @override
  String customerDuplicate(String name) {
    return 'Ce numéro appartient déjà à $name.';
  }

  @override
  String get customerDuplicateOpen => 'Ouvrir sa fiche';

  @override
  String get customerDelete => 'Supprimer ce client';

  @override
  String get customerDeleted => 'Client supprimé.';

  @override
  String get customerLookupExisting => 'Vous avez déjà ce client';

  @override
  String customerLookupOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: 'Aucune commande',
    );
    return '$_temp0';
  }

  @override
  String get customerLookupUse => 'Utiliser ce client';

  @override
  String get scannerTitle => 'Scanner le colis';

  @override
  String get scannerAim => 'Cadrez le code-barres';

  @override
  String get scannerTorch => 'Lumière';

  @override
  String get scannerManualEntry => 'Saisir à la main';

  @override
  String get scannerPermissionTitle => 'Appareil photo non autorisé';

  @override
  String get scannerPermissionBody =>
      'L\'appareil photo est nécessaire pour scanner. Vous pouvez saisir le numéro à la main, ou autoriser l\'accès dans les réglages du téléphone.';

  @override
  String get scannerUnavailableTitle => 'Appareil photo indisponible';

  @override
  String get scannerUnavailableBody =>
      'Le scanner n\'a pas pu démarrer. Saisissez le numéro à la main pour continuer.';

  @override
  String get orderNewTitle => 'Nouveau colis';

  @override
  String get orderFieldTracking => 'N° de suivi';

  @override
  String get orderFieldPhone => 'Téléphone';

  @override
  String get orderFieldName => 'Nom';

  @override
  String get orderFieldCommune => 'Commune';

  @override
  String get orderFieldAddress => 'Adresse';

  @override
  String get orderFieldCod => 'À encaisser';

  @override
  String get orderFieldNotes => 'Remarque';

  @override
  String get orderFieldDelivery => 'Livraison';

  @override
  String get orderDeliveryHome => 'À domicile';

  @override
  String get orderDeliveryStopdesk => 'Point relais';

  @override
  String get orderSave => 'Enregistrer';

  @override
  String get orderSaveAndNext => 'Enregistrer et scanner';

  @override
  String get orderSaved => 'Colis enregistré.';

  @override
  String get orderTrackingRequired => 'Le n° de suivi est obligatoire.';

  @override
  String get orderDuplicateTracking => 'Ce colis est déjà dans la tournée.';

  @override
  String get orderDuplicateOpen => 'Voir le colis';

  @override
  String get orderCompanyLabel => 'Société';

  @override
  String get orderCompanyChange => 'Changer';

  @override
  String get orderNoCompanyTitle => 'Aucune société';

  @override
  String get orderNoCompanyBody =>
      'Ajoutez la société qui vous a remis ces colis.';

  @override
  String get orderNoCompanyAction => 'Ajouter une société';

  @override
  String get orderCommuneSearchHint => 'Chercher une commune';

  @override
  String get orderCommuneNoResults => 'Aucune commune ne correspond.';

  @override
  String get companyNewTitle => 'Nouvelle société';

  @override
  String get companyFieldName => 'Nom';

  @override
  String get companyFieldPhone => 'Téléphone';

  @override
  String get companyFieldNotes => 'Remarque';

  @override
  String get companySave => 'Enregistrer';

  @override
  String get companyNameRequired => 'Le nom est obligatoire.';

  @override
  String get companiesEmptyTitle => 'Aucune société';

  @override
  String get companiesEmptyBody =>
      'Ajoutez les sociétés dont vous livrez les colis.';

  @override
  String get companiesNew => 'Nouvelle société';
}

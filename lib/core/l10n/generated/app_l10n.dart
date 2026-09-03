import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_ar.dart';
import 'app_l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// Product name. Shown as the Android launcher label and the task-switcher title. A brand name, so it is not translated — the entry exists so the mechanism is in place and a future rename reaches both locales.
  ///
  /// In fr, this message translates to:
  /// **'Delivery OS'**
  String get appTitle;

  /// Label for the language selector.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// Language option meaning: follow the device setting. This is the default state, when the driver has never chosen explicitly.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get languageSystem;

  /// Bottom-nav destination and screen title: the daily dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// Bottom-nav destination and screen title: today's orders. The batch is a grouping inside this screen, not its own destination.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// Bottom-nav destination and screen title: the optimized route.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get navRoute;

  /// Bottom-nav destination and screen title: settlement, expenses, remittance, cash on hand.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get navMoney;

  /// Bottom-nav destination and screen title: a plain list linking to the screens that do not earn a tab.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// Screen title, reached from More: the customer database.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get navCustomers;

  /// Screen title, reached from More: the delivery companies the driver works for.
  ///
  /// In fr, this message translates to:
  /// **'Sociétés'**
  String get navCompanies;

  /// Screen title, reached from More: past days, drilled down by date.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get navHistory;

  /// Screen title, reached from More: app settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// Title of the screen shown when the encrypted database cannot be opened. States the fact, never the cause: a keystore wipe, a device restore, a corrupted file and an OEM security reset all arrive as the same exception, and a guessed cause sends the driver off to fix something that is not broken. Never names encryption, keys or databases — that is our vocabulary, not his.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir vos données'**
  String get dbErrorTitle;

  /// The most important string on this screen, and the reason it is long. It is the difference between a driver who continues his day and one who stops. Three jobs: the parcels in his hand are still real, the company still holds its own record of the batch, and what was lost is the app's copy of the history rather than his work or his money. Do not shorten by dropping a clause; split into more sentences instead.
  ///
  /// In fr, this message translates to:
  /// **'Vos colis et le travail d\'aujourd\'hui ne sont pas perdus. L\'entreprise garde sa propre trace du lot. Ce qui manque, c\'est la copie de l\'application — pas votre argent.'**
  String get dbErrorStillTrue;

  /// TODO(bordereau): the Arabic rendering of "bordereau" is unresolved. Shipping as وصل الشركة, which is understandable and safe, but this is trade vocabulary and belongs to a real manifest rather than to a guess. If drivers say البوردورو, that is the answer. Resolved by the same trip that settles the wilaya structure and the failure-reason taxonomy. Emphasised, and deliberately NOT a numbered troubleshooting step. It fixes nothing, so listing it after 'retry' would read as what you do once the other steps fail. It is what the driver does first, and it stays true even if retry succeeds: if his money records are gone, the company's bordereau is the surviving source.
  ///
  /// In fr, this message translates to:
  /// **'Avant toute autre chose, comparez l\'argent encaissé aujourd\'hui avec le bordereau de l\'entreprise.'**
  String get dbErrorReconcile;

  /// First troubleshooting step. Least destructive first.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez.'**
  String get dbErrorStep1;

  /// Second troubleshooting step.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrez le téléphone, puis réessayez.'**
  String get dbErrorStep2;

  /// The only action visible at first view. Re-attempts the database open, which is worth keeping because a transient keystore failure can clear on relaunch — the one case where this screen is recoverable.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get dbErrorRetry;

  /// Expands the secondary disclosure below.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi ?'**
  String get dbErrorWhyLabel;

  /// Phrased as 'this can happen after', never 'this happened because'. We cannot determine the cause, and a wrong explanation on the worst day costs more trust than no explanation.
  ///
  /// In fr, this message translates to:
  /// **'Cela peut arriver après la restauration d\'un téléphone depuis une sauvegarde, ou après le passage à un nouvel appareil : les données peuvent être copiées, mais pas ce qui permet de les ouvrir.'**
  String get dbErrorWhyBody;

  /// Secondary path on the failure screen, leading to the destructive reset. Never a peer of the retry button: a driver who has just read that his data will not open must not be one panicked tap from destroying it.
  ///
  /// In fr, this message translates to:
  /// **'Autres options'**
  String get dbErrorOtherOptions;

  /// Shown on the failure screen when a reset attempt did not complete. Deliberately says nothing about whether the data survived — the delete may have succeeded before the key regeneration failed, so any claim either way could be false. It is one line added to the existing screen rather than a new error state: the driver has now had two things fail, and composing a second error on top of the first makes the screen read as though the app is confused about which.
  ///
  /// In fr, this message translates to:
  /// **'La réinitialisation ne s\'est pas terminée.'**
  String get dbErrorResetFailed;

  /// Title of the first reset step. Names the action plainly — not 'Réinitialiser', which sounds reversible.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les données et recommencer'**
  String get resetTitle;

  /// Introduces the loss list. Categories rather than counts, because the database is unreadable and we cannot count what is in it.
  ///
  /// In fr, this message translates to:
  /// **'Ceci supprime définitivement ce que l\'application a enregistré sur ce téléphone :'**
  String get resetLosesIntro;

  /// First loss category.
  ///
  /// In fr, this message translates to:
  /// **'les livraisons et leur historique'**
  String get resetLosesDeliveries;

  /// Second loss category. 'Adresses enregistrées' covers the learned pins, which are the most expensive thing to rebuild.
  ///
  /// In fr, this message translates to:
  /// **'les clients et leurs adresses enregistrées'**
  String get resetLosesCustomers;

  /// Third loss category, and the one with financial consequence.
  ///
  /// In fr, this message translates to:
  /// **'les encaissements et les règlements'**
  String get resetLosesMoney;

  /// Stated as its own sentence. No backup exists, and promising recovery would be a lie.
  ///
  /// In fr, this message translates to:
  /// **'Rien de tout cela ne peut être récupéré.'**
  String get resetIrreversible;

  /// Repeats the reconcile instruction from the failure screen, because this is genuinely the last moment it is useful. TODO(bordereau): see the note on dbErrorReconcile.
  ///
  /// In fr, this message translates to:
  /// **'Si ce n\'est pas déjà fait, comparez d\'abord l\'argent encaissé avec le bordereau de l\'entreprise. C\'est le dernier moment pour le faire.'**
  String get resetReconcileFirst;

  /// Backs out of the reset. Must land on the failure screen, never a blank route.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get resetCancel;

  /// Advances to the hold-to-confirm step. Not the destructive action itself.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get resetContinue;

  /// Title of the second reset step.
  ///
  /// In fr, this message translates to:
  /// **'Maintenez pour supprimer'**
  String get resetHoldTitle;

  /// A press-and-hold rather than a typed confirmation word. Typing a word on a phone keyboard, in a second script, one-handed, while holding a parcel is the wrong interaction here. A hold is language-neutral, impossible to trigger by muscle memory, and works with one thumb.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez et maintenez pendant 3 secondes.'**
  String get resetHoldInstruction;

  /// The confirm control says what it does. Never 'OK' or 'Confirmer' — the label is the last thing between the driver and permanent loss.
  ///
  /// In fr, this message translates to:
  /// **'Maintenir pour supprimer définitivement'**
  String get resetHoldAction;

  /// Shown after a completed reset. Dropping silently into an empty app would read as another failure.
  ///
  /// In fr, this message translates to:
  /// **'L\'application a redémarré à zéro'**
  String get resetDoneTitle;

  /// Confirms what happened and that the app is usable.
  ///
  /// In fr, this message translates to:
  /// **'Les anciennes données ont été supprimées. Vous pouvez commencer une nouvelle journée.'**
  String get resetDoneBody;

  /// Leaves the reset flow into normal startup. The only way off this screen — the reset flow behind it is cleared, since returning would offer to destroy data that no longer exists.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get resetDoneAction;

  /// Placeholder in the customer search field. Searches name and number, including a number that never parsed.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client'**
  String get customersSearchHint;

  /// Empty state on the Customers screen, when none exist at all. Distinct from a search that matched nothing.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client'**
  String get customersEmptyTitle;

  /// Says where customers come from. A driver does not create customers directly; they arrive with order entry.
  ///
  /// In fr, this message translates to:
  /// **'Les clients apparaissent ici dès la première commande saisie.'**
  String get customersEmptyBody;

  /// A search matched nothing. Deliberately different from customersEmptyTitle: one means try another word, the other means there is nothing yet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour cette recherche.'**
  String get customersNoResults;

  /// Action that opens the create form. Also the create form's own title.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get customersNew;

  /// Badge on a customer whose number never parsed and was kept verbatim. Not an error the driver caused — the number is probably a pre-2008 landline our validator does not know.
  ///
  /// In fr, this message translates to:
  /// **'Numéro à vérifier'**
  String get customerNeedsPhoneReview;

  /// Title of the form when editing an existing customer.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le client'**
  String get customerFormEditTitle;

  /// Form field label.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get customerFieldName;

  /// Form field label for the identity number.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get customerFieldPhone;

  /// Form field label for the secondary number, which is dial-and-display only and is not part of the identity.
  ///
  /// In fr, this message translates to:
  /// **'Autre numéro'**
  String get customerFieldPhoneAlt;

  /// Form field label. Free text about the customer, such as which floor or when they are home.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get customerFieldNotes;

  /// Form field label for the risk flag. Only ever set by a human — nothing in the app infers it from delivery history.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get customerFieldRisk;

  /// Risk flag: the default, most customers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get customerRiskNone;

  /// Risk flag: worth a phone call before setting out. Written as the action to take rather than as a label, because that is what the driver does with it.
  ///
  /// In fr, this message translates to:
  /// **'Appeler avant de partir'**
  String get customerRiskWatch;

  /// Risk flag: repeated refusals or abuse.
  ///
  /// In fr, this message translates to:
  /// **'Client à problème'**
  String get customerRiskProblem;

  /// Primary action on the customer form.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get customerSave;

  /// Validation message.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get customerNameRequired;

  /// Validation message. A customer with no number at all cannot be found again.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro est obligatoire.'**
  String get customerPhoneRequired;

  /// Shown when the number does not parse. Deliberately NOT an error: it does not block saving. A driver in an agency at 07:00 must not be stopped because our validator disagrees with a real landline. States what will happen rather than refusing.
  ///
  /// In fr, this message translates to:
  /// **'Numéro non reconnu. Il sera enregistré tel quel, à corriger plus tard.'**
  String get customerPhoneUnrecognized;

  /// The number is taken by a live customer. Names them, so the driver can recognise the record rather than going to search for it.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro appartient déjà à {name}.'**
  String customerDuplicate(String name);

  /// Action beside customerDuplicate. Opens the existing customer instead of creating a second one.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir sa fiche'**
  String get customerDuplicateOpen;

  /// Soft-deletes the customer. Their orders stay readable, and the number can be added again afterwards.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce client'**
  String get customerDelete;

  /// Confirmation after a soft delete.
  ///
  /// In fr, this message translates to:
  /// **'Client supprimé.'**
  String get customerDeleted;

  /// Heading on the card shown when the number typed already belongs to someone. Phrased as a fact the driver owns rather than as a warning — finding an existing customer is the good outcome, because it saves retyping a name and an address.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà ce client'**
  String get customerLookupExisting;

  /// Order count on the existing-customer card. It is the fastest way for a driver to recognise whether this is the person they mean.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune commande} =1{1 commande} other{{count} commandes}}'**
  String customerLookupOrders(int count);

  /// One tap to reuse the existing customer instead of creating a second record for the same person.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce client'**
  String get customerLookupUse;

  /// Title of the barcode scanner screen. Names the object the driver is holding, not the technology.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le colis'**
  String get scannerTitle;

  /// Instruction over the camera preview. Short because it is read at arm's length while holding a parcel.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez le code-barres'**
  String get scannerAim;

  /// Toggles the camera flash. Named for what it does for the driver — a stairwell at 07:00 is dark — rather than 'flash' or 'torch mode'.
  ///
  /// In fr, this message translates to:
  /// **'Lumière'**
  String get scannerTorch;

  /// Skips the scan and opens the order form directly. Always available, not only after a failure: a damaged or missing label is ordinary, and a scanner that traps the driver is worse than no scanner.
  ///
  /// In fr, this message translates to:
  /// **'Saisir à la main'**
  String get scannerManualEntry;

  /// Shown when camera permission was refused. States the fact without blaming — refusing a permission is a reasonable thing to have done.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo non autorisé'**
  String get scannerPermissionTitle;

  /// Offers manual entry FIRST and settings second. A driver who declined at 07:00 in an agency needs to enter the order now, not navigate Android settings; the entry form works without a scan. Same reasoning as an unparseable phone not blocking order creation.
  ///
  /// In fr, this message translates to:
  /// **'L\'appareil photo est nécessaire pour scanner. Vous pouvez saisir le numéro à la main, ou autoriser l\'accès dans les réglages du téléphone.'**
  String get scannerPermissionBody;

  /// Shown when the camera cannot start for any reason other than permission — hardware in use by another app, or a device fault.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo indisponible'**
  String get scannerUnavailableTitle;

  /// Deliberately does not guess the cause. The driver's next step is the same whatever it was.
  ///
  /// In fr, this message translates to:
  /// **'Le scanner n\'a pas pu démarrer. Saisissez le numéro à la main pour continuer.'**
  String get scannerUnavailableBody;

  /// Title of the order entry screen. `colis`, not `commande`: a commande is what the customer placed on a website, a colis is the object in the driver's hand with the tracking number printed on it, and it is the unit counted at the agency in the morning. The entity stays `Order` in code; the screen uses the driver's word.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau colis'**
  String get orderNewTitle;

  /// The tracking number, pre-filled from a scan. The only field this form requires.
  ///
  /// In fr, this message translates to:
  /// **'N° de suivi'**
  String get orderFieldTracking;

  /// The customer's number, and the first field focused. Typing it looks the customer up as it goes, which is what saves retyping a name and an address.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get orderFieldPhone;

  /// The customer's name. Shown only when the number belongs to nobody yet — an existing customer is a card, not a set of fields to retype.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get orderFieldName;

  /// The commune of the delivery address. Opens a searchable list; a driver reading a French label and a driver typing Arabic must find the same commune.
  ///
  /// In fr, this message translates to:
  /// **'Commune'**
  String get orderFieldCommune;

  /// Free text under the commune: the cité, the block, the floor — what a driver actually uses to find a door. Without it a new customer's order has only a commune centroid, which is confidence tier 1 and clusters as a zone stop rather than routing to an address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get orderFieldAddress;

  /// The cash to collect at the door, in dinars. The driver's phrase for the money in their hand rather than the manifest's 'montant COD'.
  ///
  /// In fr, this message translates to:
  /// **'À encaisser'**
  String get orderFieldCod;

  /// Anything the driver wants to remember about this parcel. Optional and last.
  ///
  /// In fr, this message translates to:
  /// **'Remarque'**
  String get orderFieldNotes;

  /// Label above the home / stop-desk toggle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get orderFieldDelivery;

  /// Delivered to the customer's address. The default, and the majority of parcels.
  ///
  /// In fr, this message translates to:
  /// **'À domicile'**
  String get orderDeliveryHome;

  /// Collected by the customer from an agency desk. Roughly half of Algerian COD volume, it cannot be derived from anything else — it comes off the label — and it must never enter the optimized route. One tap, on a minority of parcels.
  ///
  /// In fr, this message translates to:
  /// **'Point relais'**
  String get orderDeliveryStopdesk;

  /// Saves the parcel and closes the form.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get orderSave;

  /// Saves and reopens the scanner for the next parcel. The largest thing on the screen, because it is the loop the four-minute gate measures.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et scanner'**
  String get orderSaveAndNext;

  /// Confirmation after a save. `colis` for the same reason as the title.
  ///
  /// In fr, this message translates to:
  /// **'Colis enregistré.'**
  String get orderSaved;

  /// The only blocking validation on this form. Everything else is optional on purpose: a driver standing in an agency at 07:00 must not be stopped by a field, and a parcel with no customer yet is enterable even though it is not deliverable.
  ///
  /// In fr, this message translates to:
  /// **'Le n° de suivi est obligatoire.'**
  String get orderTrackingRequired;

  /// Shown when the tracking number is already in this company's orders. Stated as a fact, not an error — scanning the same parcel twice is the ordinary way this happens on a screen the driver hits fifteen times a morning, and no wording blames them for it.
  ///
  /// In fr, this message translates to:
  /// **'Ce colis est déjà dans la tournée.'**
  String get orderDuplicateTracking;

  /// One tap to the parcel that already carries the number, instead of making the driver go and look for it.
  ///
  /// In fr, this message translates to:
  /// **'Voir le colis'**
  String get orderDuplicateOpen;

  /// Names the company today's parcels came from. Chosen once per batch and never per order, so it is a header on this form rather than a field in it.
  ///
  /// In fr, this message translates to:
  /// **'Société'**
  String get orderCompanyLabel;

  /// Switches the company, which switches the batch. A driver working two companies in one day has two batches and one route.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get orderCompanyChange;

  /// Empty state on the first launch, before any company exists. Nothing is seeded — an invented company would end up in a settlement.
  ///
  /// In fr, this message translates to:
  /// **'Aucune société'**
  String get orderNoCompanyTitle;

  /// Says what a company is in the driver's terms — the agency that handed over the parcels — rather than defining a database entity.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la société qui vous a remis ces colis.'**
  String get orderNoCompanyBody;

  /// Leads out of the empty state into company creation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une société'**
  String get orderNoCompanyAction;

  /// Search field at the top of the commune picker. Matches either name, so the French label on a parcel and an Arabic spelling find the same commune.
  ///
  /// In fr, this message translates to:
  /// **'Chercher une commune'**
  String get orderCommuneSearchHint;

  /// Shown when a commune search matches nothing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commune ne correspond.'**
  String get orderCommuneNoResults;

  /// Title of the company form.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle société'**
  String get companyNewTitle;

  /// The company's name, and the only thing a driver has to type.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get companyFieldName;

  /// Free text, not a validated number: agencies hand out a mobile and a landline together, which is useful to a driver and is not a phone number.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get companyFieldPhone;

  /// Anything worth remembering about this company.
  ///
  /// In fr, this message translates to:
  /// **'Remarque'**
  String get companyFieldNotes;

  /// Saves the company and returns to whatever needed it.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get companySave;

  /// The only validation on the company form.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get companyNameRequired;

  /// Empty state on the companies screen.
  ///
  /// In fr, this message translates to:
  /// **'Aucune société'**
  String get companiesEmptyTitle;

  /// Explains what belongs on this screen in the driver's terms.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les sociétés dont vous livrez les colis.'**
  String get companiesEmptyBody;

  /// Opens the company form from the companies screen.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle société'**
  String get companiesNew;

  /// The currency abbreviation appended after a formatted amount, via MoneyFormat.withCurrency. Read as the same word in both scripts — passed in rather than decided by MoneyFormat itself, which is locale-independent by design (see money_format.dart).
  ///
  /// In fr, this message translates to:
  /// **'DA'**
  String get moneyCurrency;

  /// Empty state on the orders list before anything has been scanned or entered today.
  ///
  /// In fr, this message translates to:
  /// **'Aucun colis aujourd\'hui'**
  String get ordersEmptyTitle;

  /// Points at the scan FAB, which is the only way into the list.
  ///
  /// In fr, this message translates to:
  /// **'Scannez un colis pour commencer.'**
  String get ordersEmptyBody;

  /// Badge on a list row for a parcel entered with no phone number, in the same neutral register as customerNeedsPhoneReview — this is an ordinary state a manifest produces, not a mistake.
  ///
  /// In fr, this message translates to:
  /// **'Client à ajouter'**
  String get orderListNeedsCustomer;

  /// Badge on a list row for a parcel with a customer but no commune. A driver doing end-of-morning cleanup uses this to find what still needs an address before a route can be built.
  ///
  /// In fr, this message translates to:
  /// **'Adresse à ajouter'**
  String get orderListNeedsAddress;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'fr':
      return AppL10nFr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

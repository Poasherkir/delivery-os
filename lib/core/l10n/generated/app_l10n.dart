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

  /// Emphasised, and deliberately NOT a numbered troubleshooting step. It fixes nothing, so listing it after 'retry' would read as what you do once the other steps fail. It is what the driver does first, and it stays true even if retry succeeds: if his money records are gone, the company's bordereau is the surviving source.
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

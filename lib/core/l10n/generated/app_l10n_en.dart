// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Delivery OS';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Automatic';

  @override
  String get navHome => 'Home';

  @override
  String get navOrders => 'Parcels';

  @override
  String get navRoute => 'Route';

  @override
  String get navMoney => 'Money';

  @override
  String get navMore => 'More';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navCompanies => 'Companies';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get dbErrorTitle => 'Your data cannot be opened';

  @override
  String get dbErrorStillTrue =>
      'Your parcels and today\'s work are not lost. The company keeps its own record of the batch. What is missing is the app\'s copy — not your money.';

  @override
  String get dbErrorReconcile =>
      'Before anything else, check today\'s collected cash against the company\'s manifest.';

  @override
  String get dbErrorStep1 => 'Try again.';

  @override
  String get dbErrorStep2 => 'Restart the phone, then try again.';

  @override
  String get dbErrorRetry => 'Try again';

  @override
  String get dbErrorWhyLabel => 'Why does this happen?';

  @override
  String get dbErrorWhyBody =>
      'This can happen after restoring a phone from a backup, or after moving to a new device: the data can be copied, but what opens it cannot.';

  @override
  String get dbErrorOtherOptions => 'Other options';

  @override
  String get dbErrorResetFailed => 'The reset did not finish.';

  @override
  String get resetTitle => 'Erase data and start over';

  @override
  String get resetLosesIntro =>
      'This permanently deletes what the app has recorded on this phone:';

  @override
  String get resetLosesDeliveries => 'deliveries and their history';

  @override
  String get resetLosesCustomers => 'customers and their saved addresses';

  @override
  String get resetLosesMoney => 'collected cash and settlements';

  @override
  String get resetIrreversible => 'None of this can be recovered.';

  @override
  String get resetReconcileFirst =>
      'If you have not already, first check the collected cash against the company\'s manifest. This is the last moment to do it.';

  @override
  String get resetCancel => 'Cancel';

  @override
  String get resetContinue => 'Continue';

  @override
  String get resetHoldTitle => 'Hold to delete';

  @override
  String get resetHoldInstruction => 'Press and hold for 3 seconds.';

  @override
  String get resetHoldAction => 'Hold to delete permanently';

  @override
  String get resetDoneTitle => 'The app has started fresh';

  @override
  String get resetDoneBody =>
      'The old data has been deleted. You can start a new day.';

  @override
  String get resetDoneAction => 'Start';

  @override
  String get customersSearchHint => 'Search for a customer';

  @override
  String get customersEmptyTitle => 'No customers';

  @override
  String get customersEmptyBody =>
      'Customers appear here as soon as the first parcel is entered.';

  @override
  String get customersNoResults => 'No results for this search.';

  @override
  String get customersNew => 'New customer';

  @override
  String get customerNeedsPhoneReview => 'Number to check';

  @override
  String get customerFormEditTitle => 'Edit customer';

  @override
  String get customerFieldName => 'Name';

  @override
  String get customerFieldPhone => 'Phone';

  @override
  String get customerFieldPhoneAlt => 'Another number';

  @override
  String get customerFieldNotes => 'Notes';

  @override
  String get customerFieldRisk => 'Flag';

  @override
  String get customerRiskNone => 'None';

  @override
  String get customerRiskWatch => 'Call before going';

  @override
  String get customerRiskProblem => 'Difficult customer';

  @override
  String get customerSave => 'Save';

  @override
  String get customerNameRequired => 'The name is required.';

  @override
  String get customerPhoneRequired => 'The number is required.';

  @override
  String get customerPhoneUnrecognized =>
      'Number not recognised. It will be saved as typed, to correct later.';

  @override
  String customerDuplicate(String name) {
    return 'This number already belongs to $name.';
  }

  @override
  String get customerDuplicateOpen => 'Open their record';

  @override
  String get customerDelete => 'Delete this customer';

  @override
  String get customerDeleted => 'Customer deleted.';

  @override
  String get customerLookupExisting => 'You already have this customer';

  @override
  String customerLookupOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parcels',
      one: '1 parcel',
      zero: 'No parcels',
    );
    return '$_temp0';
  }

  @override
  String get customerLookupUse => 'Use this customer';

  @override
  String get scannerTitle => 'Scan the parcel';

  @override
  String get scannerAim => 'Frame the barcode';

  @override
  String get scannerTorch => 'Light';

  @override
  String get scannerManualEntry => 'Enter by hand';

  @override
  String get scannerPermissionTitle => 'Camera not allowed';

  @override
  String get scannerPermissionBody =>
      'The camera is needed to scan. You can enter the number by hand, or allow access in the phone\'s settings.';

  @override
  String get scannerUnavailableTitle => 'Camera unavailable';

  @override
  String get scannerUnavailableBody =>
      'The scanner could not start. Enter the number by hand to continue.';

  @override
  String get orderNewTitle => 'New parcel';

  @override
  String get orderFieldTracking => 'Tracking no.';

  @override
  String get orderFieldPhone => 'Phone';

  @override
  String get orderFieldName => 'Name';

  @override
  String get orderFieldCommune => 'Commune';

  @override
  String get orderFieldAddress => 'Address';

  @override
  String get orderFieldCod => 'To collect';

  @override
  String get orderFieldNotes => 'Note';

  @override
  String get orderFieldDelivery => 'Delivery';

  @override
  String get orderDeliveryHome => 'To the door';

  @override
  String get orderDeliveryStopdesk => 'Pickup point';

  @override
  String get orderSave => 'Save';

  @override
  String get orderSaveAndNext => 'Save and scan';

  @override
  String get orderSaved => 'Parcel saved.';

  @override
  String get orderTrackingRequired => 'The tracking no. is required.';

  @override
  String get orderDuplicateTracking =>
      'This parcel is already in today\'s round.';

  @override
  String get orderDuplicateOpen => 'See the parcel';

  @override
  String get orderCompanyLabel => 'Company';

  @override
  String get orderCompanyChange => 'Change';

  @override
  String get orderNoCompanyTitle => 'No company';

  @override
  String get orderNoCompanyBody =>
      'Add the company that gave you these parcels.';

  @override
  String get orderNoCompanyAction => 'Add a company';

  @override
  String get orderCommuneSearchHint => 'Search for a commune';

  @override
  String get orderCommuneNoResults => 'No commune matches.';

  @override
  String get companyNewTitle => 'New company';

  @override
  String get companyFieldName => 'Name';

  @override
  String get companyFieldPhone => 'Phone';

  @override
  String get companyFieldNotes => 'Note';

  @override
  String get companySave => 'Save';

  @override
  String get companyNameRequired => 'The name is required.';

  @override
  String get companiesEmptyTitle => 'No companies';

  @override
  String get companiesEmptyBody =>
      'Add the companies whose parcels you deliver.';

  @override
  String get companiesNew => 'New company';

  @override
  String get moneyCurrency => 'DA';

  @override
  String get ordersEmptyTitle => 'No parcels today';

  @override
  String get ordersEmptyBody => 'Scan a parcel to start.';

  @override
  String get orderListNeedsCustomer => 'Customer to add';

  @override
  String get orderListNeedsAddress => 'Address to add';

  @override
  String get customerProfileTitle => 'Customer record';

  @override
  String get customerActionCall => 'Call';

  @override
  String get customerActionWhatsApp => 'WhatsApp';

  @override
  String get customerActionUnavailable => 'No app can open this link.';

  @override
  String get customerAddressesTitle => 'Addresses';

  @override
  String get customerAddressesEmpty => 'No address saved.';

  @override
  String get customerAddressPrimary => 'Main';

  @override
  String get customerHistoryTitle => 'Parcels';

  @override
  String get customerHistoryEmpty => 'No parcels for this customer.';

  @override
  String customerHistoryShowingSome(int shown, int total) {
    return '$shown of $total parcels';
  }

  @override
  String get customerHistoryShowAll => 'Show all';

  @override
  String get customerPhoneNeedsReview =>
      'This number could not be read. Correct it to be able to call.';

  @override
  String get customerEdit => 'Edit';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';
}

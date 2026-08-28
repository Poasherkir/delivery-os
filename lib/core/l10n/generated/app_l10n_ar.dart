// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Delivery OS';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'تلقائي';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navRoute => 'المسار';

  @override
  String get navMoney => 'المالية';

  @override
  String get navMore => 'المزيد';

  @override
  String get navCustomers => 'الزبائن';

  @override
  String get navCompanies => 'الشركات';

  @override
  String get navHistory => 'السجل';

  @override
  String get navSettings => 'الإعدادات';
}

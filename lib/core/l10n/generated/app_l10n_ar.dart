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

  @override
  String get dbErrorTitle => 'لا يمكن فتح بياناتك';

  @override
  String get dbErrorStillTrue =>
      'طرودك ما زالت معك، وعمل اليوم لم يضع. الشركة تحتفظ بسجلّها الخاص للدفعة. ما ضاع هو نسخة التطبيق وحدها، وليس مالك.';

  @override
  String get dbErrorReconcile =>
      'قبل أي شيء آخر، قارن المال المحصَّل اليوم مع وصل الشركة.';

  @override
  String get dbErrorStep1 => 'أعد المحاولة.';

  @override
  String get dbErrorStep2 => 'أعد تشغيل الهاتف ثم أعد المحاولة.';

  @override
  String get dbErrorRetry => 'إعادة المحاولة';

  @override
  String get dbErrorWhyLabel => 'لماذا يحدث هذا؟';

  @override
  String get dbErrorWhyBody =>
      'قد يحدث هذا بعد استعادة الهاتف من نسخة احتياطية أو بعد الانتقال إلى هاتف جديد: البيانات تُنقل، لكن ما يفتحها لا يُنقل معها.';
}

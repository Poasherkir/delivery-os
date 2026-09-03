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

  @override
  String get dbErrorOtherOptions => 'خيارات أخرى';

  @override
  String get dbErrorResetFailed => 'لم تكتمل عملية المسح.';

  @override
  String get resetTitle => 'مسح البيانات والبدء من جديد';

  @override
  String get resetLosesIntro =>
      'هذا يحذف نهائيًا ما سجّله التطبيق على هذا الهاتف:';

  @override
  String get resetLosesDeliveries => 'التوصيلات وسجلّها';

  @override
  String get resetLosesCustomers => 'الزبائن وعناوينهم المحفوظة';

  @override
  String get resetLosesMoney => 'المبالغ المحصَّلة والتسويات';

  @override
  String get resetIrreversible => 'لا يمكن استرجاع أي من هذا.';

  @override
  String get resetReconcileFirst =>
      'إن لم تكن قد فعلت، قارن أولًا المال المحصَّل مع وصل الشركة. هذه آخر فرصة.';

  @override
  String get resetCancel => 'إلغاء';

  @override
  String get resetContinue => 'متابعة';

  @override
  String get resetHoldTitle => 'اضغط مطوّلًا للحذف';

  @override
  String get resetHoldInstruction => 'اضغط مع الاستمرار لمدة 3 ثوانٍ.';

  @override
  String get resetHoldAction => 'استمر بالضغط للحذف النهائي';

  @override
  String get resetDoneTitle => 'التطبيق بدأ من جديد';

  @override
  String get resetDoneBody => 'تم حذف البيانات القديمة. يمكنك بدء يوم جديد.';

  @override
  String get resetDoneAction => 'ابدأ';

  @override
  String get customersSearchHint => 'ابحث عن زبون';

  @override
  String get customersEmptyTitle => 'لا يوجد زبائن';

  @override
  String get customersEmptyBody =>
      'تظهر بطاقات الزبائن هنا بمجرد تسجيل أول طلب.';

  @override
  String get customersNoResults => 'لا توجد نتائج لهذا البحث.';

  @override
  String get customersNew => 'زبون جديد';

  @override
  String get customerNeedsPhoneReview => 'رقم يحتاج مراجعة';

  @override
  String get customerFormEditTitle => 'تعديل الزبون';

  @override
  String get customerFieldName => 'الاسم';

  @override
  String get customerFieldPhone => 'الهاتف';

  @override
  String get customerFieldPhoneAlt => 'رقم آخر';

  @override
  String get customerFieldNotes => 'ملاحظات';

  @override
  String get customerFieldRisk => 'تنبيه';

  @override
  String get customerRiskNone => 'بدون';

  @override
  String get customerRiskWatch => 'اتصل قبل الذهاب';

  @override
  String get customerRiskProblem => 'زبون مشكل';

  @override
  String get customerSave => 'حفظ';

  @override
  String get customerNameRequired => 'الاسم إجباري.';

  @override
  String get customerPhoneRequired => 'الرقم إجباري.';

  @override
  String get customerPhoneUnrecognized =>
      'الرقم غير معروف. سيُحفظ كما هو لتصحيحه لاحقًا.';

  @override
  String customerDuplicate(String name) {
    return 'هذا الرقم يخص $name بالفعل.';
  }

  @override
  String get customerDuplicateOpen => 'افتح بطاقته';

  @override
  String get customerDelete => 'حذف هذا الزبون';

  @override
  String get customerDeleted => 'تم حذف الزبون.';

  @override
  String get customerLookupExisting => 'هذا الزبون موجود عندك';

  @override
  String customerLookupOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      many: '$count طلبًا',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String get customerLookupUse => 'استخدم هذا الزبون';

  @override
  String get scannerTitle => 'مسح الطرد';

  @override
  String get scannerAim => 'وجّه الكاميرا نحو الرمز';

  @override
  String get scannerTorch => 'الإضاءة';

  @override
  String get scannerManualEntry => 'إدخال يدوي';

  @override
  String get scannerPermissionTitle => 'الكاميرا غير مسموح بها';

  @override
  String get scannerPermissionBody =>
      'الكاميرا ضرورية للمسح. يمكنك إدخال الرقم يدويًا، أو السماح بالوصول من إعدادات الهاتف.';

  @override
  String get scannerUnavailableTitle => 'الكاميرا غير متاحة';

  @override
  String get scannerUnavailableBody =>
      'لم يبدأ الماسح. أدخل الرقم يدويًا للمتابعة.';
}

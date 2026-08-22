// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إسطبلاتي';

  @override
  String get splashTagline => 'كل حصان، وكل ملاحظة، في مكان واحد.';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول إلى إسطبلاتك.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get show => 'إظهار';

  @override
  String get hide => 'إخفاء';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get continueWithApple => 'المتابعة عبر Apple';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get newHere => 'جديد هنا؟ ';

  @override
  String get createAnAccount => 'أنشئ حسابًا';

  @override
  String get haveInviteCode => 'لديّ رمز دعوة';

  @override
  String get back => 'رجوع';

  @override
  String get yourDetails => 'بياناتك';

  @override
  String get step1of3 => 'الخطوة ١ من ٣ — عنك.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '٨ أحرف أو أكثر';

  @override
  String get sendMeCode => 'أرسل لي رمزًا';

  @override
  String get termsPrefix => 'بالمتابعة فإنك توافق على ';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get termsAnd => ' و';

  @override
  String get privacyNotice => 'إشعار الخصوصية';

  @override
  String get checkYourPhone => 'تحقّق من هاتفك';

  @override
  String codeSentTo(String phone) {
    return 'أرسلنا رمزًا من ست خانات إلى $phone.';
  }

  @override
  String resendIn(String time) {
    return 'إعادة الإرسال خلال $time';
  }

  @override
  String get verify => 'تحقّق';

  @override
  String get yourStable => 'إسطبلك';

  @override
  String get step3of3 => 'الخطوة ٣ من ٣ — ابدأ واحدًا أو انضمّ إلى واحد.';

  @override
  String get createStable => 'أنشئ إسطبلًا';

  @override
  String get roleAdmin => 'مشرف';

  @override
  String get createStableDesc =>
      'أنت تديره، وتدعو الفرسان والمُلّاك والموظفين.';

  @override
  String get joinStable => 'انضمّ إلى إسطبل';

  @override
  String get joinStableDesc =>
      'استخدم رمزًا أو رابط دعوة، أو امسح رمز QR الخاص بالإسطبل.';

  @override
  String get stableName => 'اسم الإسطبل';

  @override
  String get location => 'الموقع';

  @override
  String get pinItOnMap => 'حدّده على الخريطة';

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get inviteCodeHint => 'BRAM-42';

  @override
  String get createStableCta => 'إنشاء الإسطبل';

  @override
  String get joinStableCta => 'الانضمام إلى الإسطبل';

  @override
  String get createLegal =>
      'بصفتك مشرفًا فأنت تحتفظ بسجلات الآخرين. إنشاء إسطبل يعني قبول اتفاقية الإسطبل.';

  @override
  String get joinLegal =>
      'الانضمام يتيح للمشرفين رؤية الخيول التي تحتفظ بها هنا، ولا شيء غير ذلك.';

  @override
  String get language => 'اللغة';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get langUrdu => 'اردو';

  @override
  String get langBengali => 'বাংলা';

  @override
  String get langNepali => 'नेपाली';
}

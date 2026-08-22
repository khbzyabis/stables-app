// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppL10nUr extends AppL10n {
  AppL10nUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'مائی اسٹیبلز';

  @override
  String get splashTagline => 'ہر گھوڑا، ہر نوٹ، ایک ہی جگہ۔';

  @override
  String get welcomeBack => 'واپسی پر خوش آمدید';

  @override
  String get signInSubtitle => 'اپنے اصطبل میں سائن اِن کریں۔';

  @override
  String get email => 'ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get show => 'دکھائیں';

  @override
  String get hide => 'چھپائیں';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get signIn => 'سائن اِن';

  @override
  String get orDivider => 'یا';

  @override
  String get continueWithApple => 'Apple کے ساتھ جاری رکھیں';

  @override
  String get continueWithGoogle => 'Google کے ساتھ جاری رکھیں';

  @override
  String get newHere => 'یہاں نئے ہیں؟ ';

  @override
  String get createAnAccount => 'اکاؤنٹ بنائیں';

  @override
  String get haveInviteCode => 'میرے پاس دعوتی کوڈ ہے';

  @override
  String get back => 'واپس';

  @override
  String get yourDetails => 'آپ کی تفصیلات';

  @override
  String get step1of3 => 'مرحلہ ۱ از ۳ — آپ کے بارے میں۔';

  @override
  String get fullName => 'پورا نام';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'فون';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '۸ حروف یا اس سے زیادہ';

  @override
  String get sendMeCode => 'مجھے کوڈ بھیجیں';

  @override
  String get termsPrefix => 'By continuing you agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get checkYourPhone => 'اپنا فون دیکھیں';

  @override
  String codeSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verify => 'تصدیق کریں';

  @override
  String get yourStable => 'آپ کا اصطبل';

  @override
  String get step3of3 => 'Step 3 of 3 — start one or join one.';

  @override
  String get createStable => 'اصطبل بنائیں';

  @override
  String get roleAdmin => 'ایڈمن';

  @override
  String get createStableDesc =>
      'You run it, and invite riders, owners and staff.';

  @override
  String get joinStable => 'اصطبل میں شامل ہوں';

  @override
  String get joinStableDesc =>
      'Use a code, an invite link, or scan the stable’s QR.';

  @override
  String get stableName => 'Stable name';

  @override
  String get location => 'Location';

  @override
  String get pinItOnMap => 'Pin it on the map';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get inviteCodeHint => 'BRAM-42';

  @override
  String get createStableCta => 'اصطبل بنائیں';

  @override
  String get joinStableCta => 'اصطبل میں شامل ہوں';

  @override
  String get createLegal =>
      'As admin you hold other people’s records. Creating a stable accepts the stable agreement.';

  @override
  String get joinLegal =>
      'Joining lets the admins see the horses you keep here, and nothing else.';

  @override
  String get language => 'زبان';

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

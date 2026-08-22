// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppL10nHi extends AppL10n {
  AppL10nHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'माय स्टेबल्स';

  @override
  String get splashTagline => 'हर घोड़ा, हर नोट, एक ही जगह।';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get signInSubtitle => 'अपने अस्तबल में साइन इन करें।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get show => 'दिखाएँ';

  @override
  String get hide => 'छिपाएँ';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get signIn => 'साइन इन';

  @override
  String get orDivider => 'या';

  @override
  String get continueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get newHere => 'यहाँ नए हैं? ';

  @override
  String get createAnAccount => 'खाता बनाएँ';

  @override
  String get haveInviteCode => 'मेरे पास आमंत्रण कोड है';

  @override
  String get back => 'पीछे';

  @override
  String get yourDetails => 'आपका विवरण';

  @override
  String get step1of3 => 'चरण 1 / 3 — आपके बारे में।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'फ़ोन';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '8 अक्षर या उससे अधिक';

  @override
  String get sendMeCode => 'मुझे कोड भेजें';

  @override
  String get termsPrefix => 'By continuing you agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get checkYourPhone => 'अपना फ़ोन देखें';

  @override
  String codeSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get yourStable => 'आपका अस्तबल';

  @override
  String get step3of3 => 'Step 3 of 3 — start one or join one.';

  @override
  String get createStable => 'अस्तबल बनाएँ';

  @override
  String get roleAdmin => 'एडमिन';

  @override
  String get createStableDesc =>
      'You run it, and invite riders, owners and staff.';

  @override
  String get joinStable => 'अस्तबल से जुड़ें';

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
  String get createStableCta => 'अस्तबल बनाएँ';

  @override
  String get joinStableCta => 'अस्तबल से जुड़ें';

  @override
  String get createLegal =>
      'As admin you hold other people’s records. Creating a stable accepts the stable agreement.';

  @override
  String get joinLegal =>
      'Joining lets the admins see the horses you keep here, and nothing else.';

  @override
  String get language => 'भाषा';

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

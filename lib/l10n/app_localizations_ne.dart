// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppL10nNe extends AppL10n {
  AppL10nNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'माई स्टेबल्स';

  @override
  String get splashTagline => 'हरेक घोडा, हरेक टिपोट, एकै ठाउँमा।';

  @override
  String get welcomeBack => 'पुनः स्वागत छ';

  @override
  String get signInSubtitle => 'आफ्नो अस्तबलमा साइन इन गर्नुहोस्।';

  @override
  String get email => 'इमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get show => 'देखाउनुहोस्';

  @override
  String get hide => 'लुकाउनुहोस्';

  @override
  String get forgotPassword => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get signIn => 'साइन इन';

  @override
  String get orDivider => 'वा';

  @override
  String get continueWithApple => 'Apple मार्फत जारी राख्नुहोस्';

  @override
  String get continueWithGoogle => 'Google मार्फत जारी राख्नुहोस्';

  @override
  String get newHere => 'यहाँ नयाँ हुनुहुन्छ? ';

  @override
  String get createAnAccount => 'खाता बनाउनुहोस्';

  @override
  String get haveInviteCode => 'मसँग निमन्त्रणा कोड छ';

  @override
  String get back => 'पछाडि';

  @override
  String get yourDetails => 'तपाईंको विवरण';

  @override
  String get step1of3 => 'चरण १ / ३ — तपाईंको बारेमा।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'फोन';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '८ वर्ण वा बढी';

  @override
  String get sendMeCode => 'मलाई कोड पठाउनुहोस्';

  @override
  String get termsPrefix => 'By continuing you agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get checkYourPhone => 'आफ्नो फोन हेर्नुहोस्';

  @override
  String codeSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verify => 'प्रमाणित गर्नुहोस्';

  @override
  String get yourStable => 'तपाईंको अस्तबल';

  @override
  String get step3of3 => 'Step 3 of 3 — start one or join one.';

  @override
  String get createStable => 'अस्तबल बनाउनुहोस्';

  @override
  String get roleAdmin => 'एडमिन';

  @override
  String get createStableDesc =>
      'You run it, and invite riders, owners and staff.';

  @override
  String get joinStable => 'अस्तबलमा सामेल हुनुहोस्';

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
  String get createStableCta => 'अस्तबल बनाउनुहोस्';

  @override
  String get joinStableCta => 'अस्तबलमा सामेल हुनुहोस्';

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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppL10nBn extends AppL10n {
  AppL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'মাই স্টেবলস';

  @override
  String get splashTagline => 'প্রতিটি ঘোড়া, প্রতিটি নোট, এক জায়গায়।';

  @override
  String get welcomeBack => 'ফিরে আসায় স্বাগতম';

  @override
  String get signInSubtitle => 'আপনার আস্তাবলে সাইন ইন করুন।';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get show => 'দেখান';

  @override
  String get hide => 'লুকান';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get orDivider => 'অথবা';

  @override
  String get continueWithApple => 'Apple দিয়ে চালিয়ে যান';

  @override
  String get continueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get newHere => 'নতুন এসেছেন? ';

  @override
  String get createAnAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get haveInviteCode => 'আমার কাছে আমন্ত্রণ কোড আছে';

  @override
  String get back => 'পিছনে';

  @override
  String get yourDetails => 'আপনার তথ্য';

  @override
  String get step1of3 => 'ধাপ ১ / ৩ — আপনার সম্পর্কে।';

  @override
  String get fullName => 'পুরো নাম';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'ফোন';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '৮টি অক্ষর বা তার বেশি';

  @override
  String get sendMeCode => 'আমাকে কোড পাঠান';

  @override
  String get termsPrefix => 'By continuing you agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get checkYourPhone => 'আপনার ফোন দেখুন';

  @override
  String codeSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verify => 'যাচাই করুন';

  @override
  String get yourStable => 'আপনার আস্তাবল';

  @override
  String get step3of3 => 'Step 3 of 3 — start one or join one.';

  @override
  String get createStable => 'আস্তাবল তৈরি করুন';

  @override
  String get roleAdmin => 'অ্যাডমিন';

  @override
  String get createStableDesc =>
      'You run it, and invite riders, owners and staff.';

  @override
  String get joinStable => 'আস্তাবলে যোগ দিন';

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
  String get createStableCta => 'আস্তাবল তৈরি করুন';

  @override
  String get joinStableCta => 'আস্তাবলে যোগ দিন';

  @override
  String get createLegal =>
      'As admin you hold other people’s records. Creating a stable accepts the stable agreement.';

  @override
  String get joinLegal =>
      'Joining lets the admins see the horses you keep here, and nothing else.';

  @override
  String get language => 'ভাষা';

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

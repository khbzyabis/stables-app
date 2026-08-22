// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My Stables';

  @override
  String get splashTagline => 'Every horse, every note, in one place.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your stables.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get newHere => 'New here? ';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get haveInviteCode => 'I have an invite code';

  @override
  String get back => 'Back';

  @override
  String get yourDetails => 'Your details';

  @override
  String get step1of3 => 'Step 1 of 3 — about you.';

  @override
  String get fullName => 'Full name';

  @override
  String get emailHint => 'you@stables.ae';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => '+971 50 123 4567';

  @override
  String get passwordHint => '8 characters or more';

  @override
  String get sendMeCode => 'Send me a code';

  @override
  String get termsPrefix => 'By continuing you agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get checkYourPhone => 'Check your phone';

  @override
  String codeSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verify => 'Verify';

  @override
  String get yourStable => 'Your stable';

  @override
  String get step3of3 => 'Step 3 of 3 — start one or join one.';

  @override
  String get createStable => 'Create a stable';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get createStableDesc =>
      'You run it, and invite riders, owners and staff.';

  @override
  String get joinStable => 'Join a stable';

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
  String get createStableCta => 'Create stable';

  @override
  String get joinStableCta => 'Join stable';

  @override
  String get createLegal =>
      'As admin you hold other people’s records. Creating a stable accepts the stable agreement.';

  @override
  String get joinLegal =>
      'Joining lets the admins see the horses you keep here, and nothing else.';

  @override
  String get language => 'Language';

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

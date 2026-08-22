import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('ne'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'My Stables'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Every horse, every note, in one place.'**
  String get splashTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your stables.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get newHere;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @haveInviteCode.
  ///
  /// In en, this message translates to:
  /// **'I have an invite code'**
  String get haveInviteCode;

  /// No description provided for @navHorses.
  ///
  /// In en, this message translates to:
  /// **'Horses'**
  String get navHorses;

  /// No description provided for @navBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get navBoard;

  /// No description provided for @navStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get navStable;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @titleMyHorses.
  ///
  /// In en, this message translates to:
  /// **'My horses'**
  String get titleMyHorses;

  /// No description provided for @titleNoticeboard.
  ///
  /// In en, this message translates to:
  /// **'Noticeboard'**
  String get titleNoticeboard;

  /// No description provided for @titleTheStable.
  ///
  /// In en, this message translates to:
  /// **'The stable'**
  String get titleTheStable;

  /// No description provided for @titleYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get titleYou;

  /// No description provided for @stableAndDay.
  ///
  /// In en, this message translates to:
  /// **'{stable} · {day}'**
  String stableAndDay(String stable, String day);

  /// No description provided for @addAHorse.
  ///
  /// In en, this message translates to:
  /// **'Add a horse'**
  String get addAHorse;

  /// No description provided for @postANotice.
  ///
  /// In en, this message translates to:
  /// **'Post a notice'**
  String get postANotice;

  /// No description provided for @statusWell.
  ///
  /// In en, this message translates to:
  /// **'Well'**
  String get statusWell;

  /// No description provided for @statusWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get statusWatch;

  /// No description provided for @addedToday.
  ///
  /// In en, this message translates to:
  /// **'Added today'**
  String get addedToday;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @stableTabHint.
  ///
  /// In en, this message translates to:
  /// **'The yard, schedule and people live here — coming next.'**
  String get stableTabHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addHorseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A name is all we need. Add the rest whenever you like.'**
  String get addHorseSubtitle;

  /// No description provided for @addAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addAPhoto;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Willow'**
  String get nameHint;

  /// No description provided for @detailsIfYouWant.
  ///
  /// In en, this message translates to:
  /// **'Details, if you want them'**
  String get detailsIfYouWant;

  /// No description provided for @saveHorse.
  ///
  /// In en, this message translates to:
  /// **'Save horse'**
  String get saveHorse;

  /// No description provided for @fillLater.
  ///
  /// In en, this message translates to:
  /// **'You can fill anything in later from the profile.'**
  String get fillLater;

  /// No description provided for @detailAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get detailAge;

  /// No description provided for @detailAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9 years'**
  String get detailAgeHint;

  /// No description provided for @detailBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get detailBreed;

  /// No description provided for @detailBreedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Arabian'**
  String get detailBreedHint;

  /// No description provided for @detailSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get detailSex;

  /// No description provided for @detailSexHint.
  ///
  /// In en, this message translates to:
  /// **'Mare, gelding, stallion'**
  String get detailSexHint;

  /// No description provided for @detailHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// No description provided for @detailHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15.2 hh'**
  String get detailHeightHint;

  /// No description provided for @detailBox.
  ///
  /// In en, this message translates to:
  /// **'Box number'**
  String get detailBox;

  /// No description provided for @detailBoxHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Box 7'**
  String get detailBoxHint;

  /// No description provided for @detailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailNotes;

  /// No description provided for @detailNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering'**
  String get detailNotesHint;

  /// No description provided for @profileNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No age, breed or notes yet. That is fine — add them when you know them.'**
  String get profileNoDetails;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get addDetails;

  /// No description provided for @sectionHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get sectionHealth;

  /// No description provided for @healthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged. First entry starts the record.'**
  String get healthEmpty;

  /// No description provided for @sectionTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get sectionTraining;

  /// No description provided for @trainingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.'**
  String get trainingEmpty;

  /// No description provided for @logSomething.
  ///
  /// In en, this message translates to:
  /// **'Log something'**
  String get logSomething;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @step1of3.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3 — about you.'**
  String get step1of3;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@stables.ae'**
  String get emailHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+971 50 123 4567'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'8 characters or more'**
  String get passwordHint;

  /// No description provided for @sendMeCode.
  ///
  /// In en, this message translates to:
  /// **'Send me a code'**
  String get sendMeCode;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the '**
  String get termsPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'terms of use'**
  String get termsOfUse;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get termsAnd;

  /// No description provided for @privacyNotice.
  ///
  /// In en, this message translates to:
  /// **'privacy notice'**
  String get privacyNotice;

  /// No description provided for @checkYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Check your phone'**
  String get checkYourPhone;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit code to {phone}.'**
  String codeSentTo(String phone);

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @yourStable.
  ///
  /// In en, this message translates to:
  /// **'Your stable'**
  String get yourStable;

  /// No description provided for @step3of3.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3 — start one or join one.'**
  String get step3of3;

  /// No description provided for @createStable.
  ///
  /// In en, this message translates to:
  /// **'Create a stable'**
  String get createStable;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @createStableDesc.
  ///
  /// In en, this message translates to:
  /// **'You run it, and invite riders, owners and staff.'**
  String get createStableDesc;

  /// No description provided for @joinStable.
  ///
  /// In en, this message translates to:
  /// **'Join a stable'**
  String get joinStable;

  /// No description provided for @joinStableDesc.
  ///
  /// In en, this message translates to:
  /// **'Use a code, an invite link, or scan the stable’s QR.'**
  String get joinStableDesc;

  /// No description provided for @stableName.
  ///
  /// In en, this message translates to:
  /// **'Stable name'**
  String get stableName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @pinItOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pin it on the map'**
  String get pinItOnMap;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'BRAM-42'**
  String get inviteCodeHint;

  /// No description provided for @createStableCta.
  ///
  /// In en, this message translates to:
  /// **'Create stable'**
  String get createStableCta;

  /// No description provided for @joinStableCta.
  ///
  /// In en, this message translates to:
  /// **'Join stable'**
  String get joinStableCta;

  /// No description provided for @createLegal.
  ///
  /// In en, this message translates to:
  /// **'As admin you hold other people’s records. Creating a stable accepts the stable agreement.'**
  String get createLegal;

  /// No description provided for @joinLegal.
  ///
  /// In en, this message translates to:
  /// **'Joining lets the admins see the horses you keep here, and nothing else.'**
  String get joinLegal;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get langHindi;

  /// No description provided for @langUrdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get langUrdu;

  /// No description provided for @langBengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get langBengali;

  /// No description provided for @langNepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get langNepali;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'hi',
    'ne',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'bn':
      return AppL10nBn();
    case 'en':
      return AppL10nEn();
    case 'hi':
      return AppL10nHi();
    case 'ne':
      return AppL10nNe();
    case 'ur':
      return AppL10nUr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

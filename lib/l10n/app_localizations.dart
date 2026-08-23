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

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthView;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekView;

  /// No description provided for @addToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add to the schedule'**
  String get addToSchedule;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @quietStable.
  ///
  /// In en, this message translates to:
  /// **'Nothing of that kind today. A quiet stable is allowed.'**
  String get quietStable;

  /// No description provided for @nothingBooked.
  ///
  /// In en, this message translates to:
  /// **'Nothing booked.'**
  String get nothingBooked;

  /// No description provided for @whatIsHappening.
  ///
  /// In en, this message translates to:
  /// **'What is happening?'**
  String get whatIsHappening;

  /// No description provided for @whichHorse.
  ///
  /// In en, this message translates to:
  /// **'Which horse'**
  String get whichHorse;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @forDuration.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forDuration;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @noteIfAny.
  ///
  /// In en, this message translates to:
  /// **'Note, if any'**
  String get noteIfAny;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @openSchedule.
  ///
  /// In en, this message translates to:
  /// **'The schedule'**
  String get openSchedule;

  /// No description provided for @scheduleSub.
  ///
  /// In en, this message translates to:
  /// **'Everything the stable does — lessons, farrier, vet, transport.'**
  String get scheduleSub;

  /// No description provided for @yourTasks.
  ///
  /// In en, this message translates to:
  /// **'Your tasks'**
  String get yourTasks;

  /// No description provided for @taskProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · {left} left'**
  String taskProgress(int done, int total, int left);

  /// No description provided for @ticksVisible.
  ///
  /// In en, this message translates to:
  /// **'Ticks are visible to Ahmad and Layal straight away.'**
  String get ticksVisible;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @whatNeedsDoing.
  ///
  /// In en, this message translates to:
  /// **'What needs doing'**
  String get whatNeedsDoing;

  /// No description provided for @who.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get who;

  /// No description provided for @byTime.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get byTime;

  /// No description provided for @noteForThem.
  ///
  /// In en, this message translates to:
  /// **'Note for them'**
  String get noteForThem;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @tasksToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks today'**
  String get tasksToday;

  /// No description provided for @stillOpen.
  ///
  /// In en, this message translates to:
  /// **'Still open'**
  String get stillOpen;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @openTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get openTasks;

  /// No description provided for @tasksSub.
  ///
  /// In en, this message translates to:
  /// **'Set tasks and see who has done what.'**
  String get tasksSub;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @marketSub.
  ///
  /// In en, this message translates to:
  /// **'Feed, tack, hoofcare, rugs and services — approved sellers.'**
  String get marketSub;

  /// No description provided for @deliversTo.
  ///
  /// In en, this message translates to:
  /// **'Delivers to {stable}'**
  String deliversTo(String stable);

  /// No description provided for @everyApproved.
  ///
  /// In en, this message translates to:
  /// **'Every seller here has been approved by My Stables.'**
  String get everyApproved;

  /// No description provided for @basket.
  ///
  /// In en, this message translates to:
  /// **'Basket'**
  String get basket;

  /// No description provided for @addToBasketSize.
  ///
  /// In en, this message translates to:
  /// **'Add to basket · {size}'**
  String addToBasketSize(String size);

  /// No description provided for @inYourBasket.
  ///
  /// In en, this message translates to:
  /// **'In your basket'**
  String get inYourBasket;

  /// No description provided for @askTheSeller.
  ///
  /// In en, this message translates to:
  /// **'Ask the seller'**
  String get askTheSeller;

  /// No description provided for @basketWithCount.
  ///
  /// In en, this message translates to:
  /// **'Basket · {count}'**
  String basketWithCount(int count);

  /// No description provided for @askForPrice.
  ///
  /// In en, this message translates to:
  /// **'Ask for a price'**
  String get askForPrice;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get totalItems;

  /// No description provided for @totalDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery · two sellers, two vans'**
  String get totalDelivery;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get toPay;

  /// No description provided for @basketTerms.
  ///
  /// In en, this message translates to:
  /// **'You pay My Stables, not the sellers. If something is wrong, we hold the money until it is sorted.'**
  String get basketTerms;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something is wrong with this order'**
  String get somethingWrong;

  /// No description provided for @buyAgain.
  ///
  /// In en, this message translates to:
  /// **'Buy these again'**
  String get buyAgain;

  /// No description provided for @whatIsWrong.
  ///
  /// In en, this message translates to:
  /// **'What is wrong'**
  String get whatIsWrong;

  /// No description provided for @sendToMyStables.
  ///
  /// In en, this message translates to:
  /// **'Send to My Stables'**
  String get sendToMyStables;

  /// No description provided for @sellerAnswersFirst.
  ///
  /// In en, this message translates to:
  /// **'The seller answers first. If you still disagree, My Stables decides.'**
  String get sellerAnswersFirst;

  /// No description provided for @askSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick who to ask. They answer with a range and it expires in three days.'**
  String get askSubtitle;

  /// No description provided for @whatFor.
  ///
  /// In en, this message translates to:
  /// **'What for'**
  String get whatFor;

  /// No description provided for @whichHorses.
  ///
  /// In en, this message translates to:
  /// **'Which horses'**
  String get whichHorses;

  /// No description provided for @whenNeeded.
  ///
  /// In en, this message translates to:
  /// **'When you need it'**
  String get whenNeeded;

  /// No description provided for @whoToAsk.
  ///
  /// In en, this message translates to:
  /// **'Who to ask'**
  String get whoToAsk;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send the request'**
  String get sendRequest;

  /// No description provided for @othersAskedNote.
  ///
  /// In en, this message translates to:
  /// **'They can see how many others you asked, not who.'**
  String get othersAskedNote;

  /// No description provided for @acceptQuote.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptQuote;

  /// No description provided for @notThisTime.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get notThisTime;

  /// No description provided for @quoteBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked · the others have lapsed'**
  String get quoteBooked;

  /// No description provided for @askedFarriers.
  ///
  /// In en, this message translates to:
  /// **'Asked three farriers on Monday.'**
  String get askedFarriers;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @transportSub.
  ///
  /// In en, this message translates to:
  /// **'Move a horse to a show, a clinic or a new yard.'**
  String get transportSub;

  /// No description provided for @pickUpDeliver.
  ///
  /// In en, this message translates to:
  /// **'Pick up and deliver'**
  String get pickUpDeliver;

  /// No description provided for @transportIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask a few companies. They answer with a price and what they are insured for.'**
  String get transportIntro;

  /// No description provided for @fieldFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fieldFrom;

  /// No description provided for @fieldTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get fieldTo;

  /// No description provided for @fieldDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get fieldDay;

  /// No description provided for @thereBy.
  ///
  /// In en, this message translates to:
  /// **'There by'**
  String get thereBy;

  /// No description provided for @whatToKnow.
  ///
  /// In en, this message translates to:
  /// **'What they need to know'**
  String get whatToKnow;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call the driver'**
  String get callDriver;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @sentWithBooking.
  ///
  /// In en, this message translates to:
  /// **'Sent with the booking'**
  String get sentWithBooking;

  /// No description provided for @onYardSchedule.
  ///
  /// In en, this message translates to:
  /// **'On the yard schedule · everyone can see it'**
  String get onYardSchedule;

  /// No description provided for @addReturnJourney.
  ///
  /// In en, this message translates to:
  /// **'Add the return journey'**
  String get addReturnJourney;

  /// No description provided for @cancelFree.
  ///
  /// In en, this message translates to:
  /// **'Cancel · free until Thursday noon'**
  String get cancelFree;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get askQuestion;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @paymentsSub.
  ///
  /// In en, this message translates to:
  /// **'Everything you\'ve paid for.'**
  String get paymentsSub;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @notSettledYet.
  ///
  /// In en, this message translates to:
  /// **'Not settled yet'**
  String get notSettledYet;

  /// No description provided for @filterShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get filterShop;

  /// No description provided for @filterServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get filterServices;

  /// No description provided for @filterTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get filterTransport;

  /// No description provided for @statePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statePaid;

  /// No description provided for @stateNotCharged.
  ///
  /// In en, this message translates to:
  /// **'Not yet charged'**
  String get stateNotCharged;

  /// No description provided for @stateRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get stateRefunded;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @sendReceiptPdf.
  ///
  /// In en, this message translates to:
  /// **'Send this receipt as a PDF'**
  String get sendReceiptPdf;

  /// No description provided for @seeOrderDelivery.
  ///
  /// In en, this message translates to:
  /// **'See the order and its delivery'**
  String get seeOrderDelivery;

  /// No description provided for @somethingWrongPayment.
  ///
  /// In en, this message translates to:
  /// **'Something is wrong with this payment'**
  String get somethingWrongPayment;

  /// No description provided for @receiptSellersNote.
  ///
  /// In en, this message translates to:
  /// **'One payment, but each seller is separate behind it: their own delivery, their own charge, their own return window. My Stables holds the money and pays each of them in turn.'**
  String get receiptSellersNote;

  /// No description provided for @cardDeclined.
  ///
  /// In en, this message translates to:
  /// **'The card was declined'**
  String get cardDeclined;

  /// No description provided for @cardDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'Your bank refused it, so nothing was taken. Your basket is exactly as you left it.'**
  String get cardDeclinedBody;

  /// No description provided for @tryAnotherCard.
  ///
  /// In en, this message translates to:
  /// **'Try another card'**
  String get tryAnotherCard;

  /// No description provided for @backToBasket.
  ///
  /// In en, this message translates to:
  /// **'Back to the basket'**
  String get backToBasket;

  /// No description provided for @declinedHeld.
  ///
  /// In en, this message translates to:
  /// **'Both sellers still have the items held for two hours. After that the snaffle goes back on sale — there are six of them.'**
  String get declinedHeld;

  /// No description provided for @nobodyTold.
  ///
  /// In en, this message translates to:
  /// **'Nothing was sent to the yard board, and nobody has been told.'**
  String get nobodyTold;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @peopleNavSub.
  ///
  /// In en, this message translates to:
  /// **'Members, roles, invites and approvals.'**
  String get peopleNavSub;

  /// No description provided for @peopleIntro.
  ///
  /// In en, this message translates to:
  /// **'Two admins keep the stable running when one of you is away.'**
  String get peopleIntro;

  /// No description provided for @roleInThisStable.
  ///
  /// In en, this message translates to:
  /// **'Role in this stable'**
  String get roleInThisStable;

  /// No description provided for @removeFromStable.
  ///
  /// In en, this message translates to:
  /// **'Remove from stable'**
  String get removeFromStable;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeone;

  /// No description provided for @whatEachRole.
  ///
  /// In en, this message translates to:
  /// **'What each role can do'**
  String get whatEachRole;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @rolesIntro.
  ///
  /// In en, this message translates to:
  /// **'Admin and manager sit above the rest. Only admins can change these.'**
  String get rolesIntro;

  /// No description provided for @fullControl.
  ///
  /// In en, this message translates to:
  /// **'Full control'**
  String get fullControl;

  /// No description provided for @youChoose.
  ///
  /// In en, this message translates to:
  /// **'You choose'**
  String get youChoose;

  /// No description provided for @inviteToStable.
  ///
  /// In en, this message translates to:
  /// **'Invite to the stable'**
  String get inviteToStable;

  /// No description provided for @roleTravels.
  ///
  /// In en, this message translates to:
  /// **'The role travels with the invite. You can change it later.'**
  String get roleTravels;

  /// No description provided for @shareAs.
  ///
  /// In en, this message translates to:
  /// **'Share as'**
  String get shareAs;

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get inviteLink;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @scanAtStable.
  ///
  /// In en, this message translates to:
  /// **'Scan at the stable'**
  String get scanAtStable;

  /// No description provided for @sixCharCode.
  ///
  /// In en, this message translates to:
  /// **'Six-character code'**
  String get sixCharCode;

  /// No description provided for @waitingOnThem.
  ///
  /// In en, this message translates to:
  /// **'Waiting on them'**
  String get waitingOnThem;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @needsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get needsYou;

  /// No description provided for @nothingJoins.
  ///
  /// In en, this message translates to:
  /// **'Nothing joins the stable until you say yes.'**
  String get nothingJoins;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @myStables.
  ///
  /// In en, this message translates to:
  /// **'My stables'**
  String get myStables;

  /// No description provided for @rolePerStable.
  ///
  /// In en, this message translates to:
  /// **'Your role is per stable, not per account.'**
  String get rolePerStable;

  /// No description provided for @createAnotherStable.
  ///
  /// In en, this message translates to:
  /// **'Create another stable'**
  String get createAnotherStable;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join one with a code or link'**
  String get joinWithCode;

  /// No description provided for @adminNoRights.
  ///
  /// In en, this message translates to:
  /// **'Being admin of one stable does not give you rights in another.'**
  String get adminNoRights;

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

  /// No description provided for @detailName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get detailName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetails;

  /// No description provided for @moveHorse.
  ///
  /// In en, this message translates to:
  /// **'Move to another stable'**
  String get moveHorse;

  /// No description provided for @tack.
  ///
  /// In en, this message translates to:
  /// **'Tack'**
  String get tack;

  /// No description provided for @setups.
  ///
  /// In en, this message translates to:
  /// **'Setups'**
  String get setups;

  /// No description provided for @feedChart.
  ///
  /// In en, this message translates to:
  /// **'Feed chart'**
  String get feedChart;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @tackBox.
  ///
  /// In en, this message translates to:
  /// **'Tack box'**
  String get tackBox;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @nameIt.
  ///
  /// In en, this message translates to:
  /// **'Name it'**
  String get nameIt;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @howItIsGoing.
  ///
  /// In en, this message translates to:
  /// **'How it is going'**
  String get howItIsGoing;

  /// No description provided for @logHealth.
  ///
  /// In en, this message translates to:
  /// **'Log health'**
  String get logHealth;

  /// No description provided for @logSession.
  ///
  /// In en, this message translates to:
  /// **'Log a session'**
  String get logSession;

  /// No description provided for @editHorse.
  ///
  /// In en, this message translates to:
  /// **'Edit horse'**
  String get editHorse;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @whichStable.
  ///
  /// In en, this message translates to:
  /// **'Which stable'**
  String get whichStable;

  /// No description provided for @askStable.
  ///
  /// In en, this message translates to:
  /// **'Ask the stable'**
  String get askStable;

  /// No description provided for @keepHer.
  ///
  /// In en, this message translates to:
  /// **'Keep her here'**
  String get keepHer;

  /// No description provided for @waitingBothAdmins.
  ///
  /// In en, this message translates to:
  /// **'Waiting on both admins'**
  String get waitingBothAdmins;

  /// No description provided for @moveSentBody.
  ///
  /// In en, this message translates to:
  /// **'Both admins have to agree. Until they do, she stays here and nothing changes.'**
  String get moveSentBody;

  /// No description provided for @buildSetup.
  ///
  /// In en, this message translates to:
  /// **'Build a horse\'s setup'**
  String get buildSetup;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @theDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get theDefault;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @makeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make this the default'**
  String get makeDefault;

  /// No description provided for @seeWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'See what changed last time'**
  String get seeWhatChanged;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add a document'**
  String get addDocument;

  /// No description provided for @editChart.
  ///
  /// In en, this message translates to:
  /// **'Edit chart'**
  String get editChart;

  /// No description provided for @tackBoxIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything in here can be named on a schedule, so the groom tacks up the right kit.'**
  String get tackBoxIntro;

  /// No description provided for @setupsIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick an activity and the usual kit for it fills in.'**
  String get setupsIntro;

  /// No description provided for @setupDirtyNote.
  ///
  /// In en, this message translates to:
  /// **'You have changed this from the default. Make it the new default, or undo.'**
  String get setupDirtyNote;

  /// No description provided for @saveToTackBox.
  ///
  /// In en, this message translates to:
  /// **'Save to tack box'**
  String get saveToTackBox;

  /// No description provided for @setupChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Kiki\'s flatwork kit was not the default'**
  String get setupChangedTitle;

  /// No description provided for @setupChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Toni changed two things during the session. Keep the default, or make his version the new one.'**
  String get setupChangedBody;

  /// No description provided for @makeFlatworkDefault.
  ///
  /// In en, this message translates to:
  /// **'Make this the flatwork default'**
  String get makeFlatworkDefault;

  /// No description provided for @keepOldDefault.
  ///
  /// In en, this message translates to:
  /// **'Keep the old default'**
  String get keepOldDefault;

  /// No description provided for @nowTheDefault.
  ///
  /// In en, this message translates to:
  /// **'Now the default'**
  String get nowTheDefault;

  /// No description provided for @keptOldDefault.
  ///
  /// In en, this message translates to:
  /// **'Kept the old default'**
  String get keptOldDefault;

  /// No description provided for @backToSetups.
  ///
  /// In en, this message translates to:
  /// **'Back to setups'**
  String get backToSetups;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markRead;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'replies'**
  String get replies;

  /// No description provided for @newNotice.
  ///
  /// In en, this message translates to:
  /// **'New notice'**
  String get newNotice;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @whoSeesIt.
  ///
  /// In en, this message translates to:
  /// **'Who sees it'**
  String get whoSeesIt;

  /// No description provided for @pinToTop.
  ///
  /// In en, this message translates to:
  /// **'Pin to the top'**
  String get pinToTop;

  /// No description provided for @askConfirmRead.
  ///
  /// In en, this message translates to:
  /// **'Ask people to confirm they read it'**
  String get askConfirmRead;

  /// No description provided for @postNotice.
  ///
  /// In en, this message translates to:
  /// **'Post notice'**
  String get postNotice;

  /// No description provided for @notices.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get notices;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add a contact'**
  String get addContact;

  /// No description provided for @leaveStable.
  ///
  /// In en, this message translates to:
  /// **'Leave this stable'**
  String get leaveStable;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @youHaveLeft.
  ///
  /// In en, this message translates to:
  /// **'You have left'**
  String get youHaveLeft;

  /// No description provided for @backToMyStables.
  ///
  /// In en, this message translates to:
  /// **'Back to my stables'**
  String get backToMyStables;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @stableLanguage.
  ///
  /// In en, this message translates to:
  /// **'Stable language'**
  String get stableLanguage;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get whatHappened;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @whereIsStable.
  ///
  /// In en, this message translates to:
  /// **'Where is the stable?'**
  String get whereIsStable;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get saveLocation;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @stableSettings.
  ///
  /// In en, this message translates to:
  /// **'Stable settings'**
  String get stableSettings;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @shows.
  ///
  /// In en, this message translates to:
  /// **'Shows'**
  String get shows;

  /// No description provided for @pickAClass.
  ///
  /// In en, this message translates to:
  /// **'Pick a class'**
  String get pickAClass;

  /// No description provided for @seeReceipt.
  ///
  /// In en, this message translates to:
  /// **'See the receipt'**
  String get seeReceipt;

  /// No description provided for @backToMarket.
  ///
  /// In en, this message translates to:
  /// **'Back to the market'**
  String get backToMarket;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @deleteActivity.
  ///
  /// In en, this message translates to:
  /// **'Delete this activity'**
  String get deleteActivity;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;
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

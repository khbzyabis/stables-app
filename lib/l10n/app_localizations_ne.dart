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
  String get navHorses => 'Horses';

  @override
  String get navBoard => 'Board';

  @override
  String get navStable => 'Stable';

  @override
  String get navYou => 'You';

  @override
  String get titleMyHorses => 'My horses';

  @override
  String get titleNoticeboard => 'Noticeboard';

  @override
  String get titleTheStable => 'The stable';

  @override
  String get titleYou => 'You';

  @override
  String stableAndDay(String stable, String day) {
    return '$stable · $day';
  }

  @override
  String get addAHorse => 'Add a horse';

  @override
  String get postANotice => 'Post a notice';

  @override
  String get statusWell => 'Well';

  @override
  String get statusWatch => 'Watch';

  @override
  String get addedToday => 'Added today';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get stableTabHint =>
      'The yard, schedule and people live here — coming next.';

  @override
  String get cancel => 'Cancel';

  @override
  String get addHorseSubtitle =>
      'A name is all we need. Add the rest whenever you like.';

  @override
  String get addAPhoto => 'Add a photo';

  @override
  String get optional => 'Optional';

  @override
  String get labelName => 'Name';

  @override
  String get nameHint => 'Willow';

  @override
  String get detailsIfYouWant => 'Details, if you want them';

  @override
  String get saveHorse => 'Save horse';

  @override
  String get fillLater => 'You can fill anything in later from the profile.';

  @override
  String get detailAge => 'Age';

  @override
  String get detailAgeHint => 'e.g. 9 years';

  @override
  String get detailBreed => 'Breed';

  @override
  String get detailBreedHint => 'e.g. Arabian';

  @override
  String get detailSex => 'Sex';

  @override
  String get detailSexHint => 'Mare, gelding, stallion';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailHeightHint => 'e.g. 15.2 hh';

  @override
  String get detailBox => 'Box number';

  @override
  String get detailBoxHint => 'e.g. Box 7';

  @override
  String get detailNotes => 'Notes';

  @override
  String get detailNotesHint => 'Anything worth remembering';

  @override
  String get profileNoDetails =>
      'No age, breed or notes yet. That is fine — add them when you know them.';

  @override
  String get addDetails => 'Add details';

  @override
  String get sectionHealth => 'Health';

  @override
  String get healthEmpty => 'Nothing logged. First entry starts the record.';

  @override
  String get sectionTraining => 'Training';

  @override
  String get trainingEmpty => 'No sessions yet.';

  @override
  String get logSomething => 'Log something';

  @override
  String get schedule => 'Schedule';

  @override
  String get monthView => 'Month';

  @override
  String get weekView => 'Week';

  @override
  String get addToSchedule => 'Add to the schedule';

  @override
  String get filterAll => 'All';

  @override
  String get quietStable =>
      'Nothing of that kind today. A quiet stable is allowed.';

  @override
  String get nothingBooked => 'Nothing booked.';

  @override
  String get whatIsHappening => 'What is happening?';

  @override
  String get whichHorse => 'Which horse';

  @override
  String get starts => 'Starts';

  @override
  String get forDuration => 'For';

  @override
  String get repeats => 'Repeats';

  @override
  String get noteIfAny => 'Note, if any';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String get openSchedule => 'The schedule';

  @override
  String get scheduleSub =>
      'Everything the stable does — lessons, farrier, vet, transport.';

  @override
  String get yourTasks => 'Your tasks';

  @override
  String taskProgress(int done, int total, int left) {
    return '$done of $total done · $left left';
  }

  @override
  String get ticksVisible =>
      'Ticks are visible to Ahmad and Layal straight away.';

  @override
  String get newTask => 'New task';

  @override
  String get whatNeedsDoing => 'What needs doing';

  @override
  String get who => 'Who';

  @override
  String get byTime => 'By';

  @override
  String get noteForThem => 'Note for them';

  @override
  String get assign => 'Assign';

  @override
  String get tasksToday => 'Tasks today';

  @override
  String get stillOpen => 'Still open';

  @override
  String get statusLate => 'Late';

  @override
  String get statusOpen => 'Open';

  @override
  String get openTasks => 'Tasks';

  @override
  String get tasksSub => 'Set tasks and see who has done what.';

  @override
  String get market => 'Market';

  @override
  String get marketSub =>
      'Feed, tack, hoofcare, rugs and services — approved sellers.';

  @override
  String deliversTo(String stable) {
    return 'Delivers to $stable';
  }

  @override
  String get everyApproved =>
      'Every seller here has been approved by My Stables.';

  @override
  String get basket => 'Basket';

  @override
  String addToBasketSize(String size) {
    return 'Add to basket · $size';
  }

  @override
  String get inYourBasket => 'In your basket';

  @override
  String get askTheSeller => 'Ask the seller';

  @override
  String basketWithCount(int count) {
    return 'Basket · $count';
  }

  @override
  String get askForPrice => 'Ask for a price';

  @override
  String get payWith => 'Pay with';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get totalItems => 'Items';

  @override
  String get totalDelivery => 'Delivery · two sellers, two vans';

  @override
  String get toPay => 'To pay';

  @override
  String get basketTerms =>
      'You pay My Stables, not the sellers. If something is wrong, we hold the money until it is sorted.';

  @override
  String get orders => 'Orders';

  @override
  String get somethingWrong => 'Something is wrong with this order';

  @override
  String get buyAgain => 'Buy these again';

  @override
  String get whatIsWrong => 'What is wrong';

  @override
  String get sendToMyStables => 'Send to My Stables';

  @override
  String get sellerAnswersFirst =>
      'The seller answers first. If you still disagree, My Stables decides.';

  @override
  String get askSubtitle =>
      'Pick who to ask. They answer with a range and it expires in three days.';

  @override
  String get whatFor => 'What for';

  @override
  String get whichHorses => 'Which horses';

  @override
  String get whenNeeded => 'When you need it';

  @override
  String get whoToAsk => 'Who to ask';

  @override
  String get sendRequest => 'Send the request';

  @override
  String get othersAskedNote =>
      'They can see how many others you asked, not who.';

  @override
  String get acceptQuote => 'Accept';

  @override
  String get notThisTime => 'Not this time';

  @override
  String get quoteBooked => 'Booked · the others have lapsed';

  @override
  String get askedFarriers => 'Asked three farriers on Monday.';

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

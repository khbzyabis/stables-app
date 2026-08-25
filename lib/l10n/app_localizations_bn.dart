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
  String get transport => 'Transport';

  @override
  String get transportSub => 'Move a horse to a show, a clinic or a new yard.';

  @override
  String get pickUpDeliver => 'Pick up and deliver';

  @override
  String get transportIntro =>
      'Ask a few companies. They answer with a price and what they are insured for.';

  @override
  String get fieldFrom => 'From';

  @override
  String get fieldTo => 'To';

  @override
  String get fieldDay => 'Day';

  @override
  String get thereBy => 'There by';

  @override
  String get whatToKnow => 'What they need to know';

  @override
  String get callDriver => 'Call the driver';

  @override
  String get messageLabel => 'Message';

  @override
  String get sentWithBooking => 'Sent with the booking';

  @override
  String get onYardSchedule => 'On the yard schedule · everyone can see it';

  @override
  String get addReturnJourney => 'Add the return journey';

  @override
  String get cancelFree => 'Cancel · free until Thursday noon';

  @override
  String get askQuestion => 'Ask a question';

  @override
  String get payments => 'Payments';

  @override
  String get paymentsSub => 'Everything you\'ve paid for.';

  @override
  String get thisMonth => 'This month';

  @override
  String get notSettledYet => 'Not settled yet';

  @override
  String get filterShop => 'Shop';

  @override
  String get filterServices => 'Services';

  @override
  String get filterTransport => 'Transport';

  @override
  String get statePaid => 'Paid';

  @override
  String get stateNotCharged => 'Not yet charged';

  @override
  String get stateRefunded => 'Refunded';

  @override
  String get receipt => 'Receipt';

  @override
  String get sendReceiptPdf => 'Send this receipt as a PDF';

  @override
  String get seeOrderDelivery => 'See the order and its delivery';

  @override
  String get somethingWrongPayment => 'Something is wrong with this payment';

  @override
  String get receiptSellersNote =>
      'One payment, but each seller is separate behind it: their own delivery, their own charge, their own return window. My Stables holds the money and pays each of them in turn.';

  @override
  String get cardDeclined => 'The card was declined';

  @override
  String get cardDeclinedBody =>
      'Your bank refused it, so nothing was taken. Your basket is exactly as you left it.';

  @override
  String get tryAnotherCard => 'Try another card';

  @override
  String get backToBasket => 'Back to the basket';

  @override
  String get declinedHeld =>
      'Both sellers still have the items held for two hours. After that the snaffle goes back on sale — there are six of them.';

  @override
  String get nobodyTold =>
      'Nothing was sent to the yard board, and nobody has been told.';

  @override
  String get people => 'People';

  @override
  String get peopleNavSub => 'Members, roles, invites and approvals.';

  @override
  String get peopleIntro =>
      'Two admins keep the stable running when one of you is away.';

  @override
  String get roleInThisStable => 'Role in this stable';

  @override
  String get removeFromStable => 'Remove from stable';

  @override
  String get inviteSomeone => 'Invite someone';

  @override
  String get whatEachRole => 'What each role can do';

  @override
  String get roles => 'Roles';

  @override
  String get rolesIntro =>
      'Admin and manager sit above the rest. Only admins can change these.';

  @override
  String get fullControl => 'Full control';

  @override
  String get youChoose => 'You choose';

  @override
  String get inviteToStable => 'Invite to the stable';

  @override
  String get roleTravels =>
      'The role travels with the invite. You can change it later.';

  @override
  String get shareAs => 'Share as';

  @override
  String get inviteLink => 'Invite link';

  @override
  String get copy => 'Copy';

  @override
  String get scanAtStable => 'Scan at the stable';

  @override
  String get sixCharCode => 'Six-character code';

  @override
  String get waitingOnThem => 'Waiting on them';

  @override
  String get pending => 'Pending';

  @override
  String get needsYou => 'Needs you';

  @override
  String get nothingJoins => 'Nothing joins the stable until you say yes.';

  @override
  String get approve => 'Approve';

  @override
  String get decline => 'Decline';

  @override
  String get approved => 'Approved';

  @override
  String get declined => 'Declined';

  @override
  String get myStables => 'My stables';

  @override
  String get rolePerStable => 'Your role is per stable, not per account.';

  @override
  String get createAnotherStable => 'Create another stable';

  @override
  String get joinWithCode => 'Join one with a code or link';

  @override
  String get adminNoRights =>
      'Being admin of one stable does not give you rights in another.';

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

  @override
  String get detailName => 'Name';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get history => 'History';

  @override
  String get editDetails => 'Edit details';

  @override
  String get moveHorse => 'Move to another stable';

  @override
  String get tack => 'Tack';

  @override
  String get setups => 'Setups';

  @override
  String get feedChart => 'Feed chart';

  @override
  String get documents => 'Documents';

  @override
  String get tackBox => 'Tack box';

  @override
  String get addItem => 'Add item';

  @override
  String get newItem => 'New item';

  @override
  String get group => 'Group';

  @override
  String get nameIt => 'Name it';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get howItIsGoing => 'How it is going';

  @override
  String get logHealth => 'Log health';

  @override
  String get logSession => 'Log a session';

  @override
  String get editHorse => 'Edit horse';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get whichStable => 'Which stable';

  @override
  String get askStable => 'Ask the stable';

  @override
  String get keepHer => 'Keep her here';

  @override
  String get waitingBothAdmins => 'Waiting on both admins';

  @override
  String get moveSentBody =>
      'Both admins have to agree. Until they do, she stays here and nothing changes.';

  @override
  String get buildSetup => 'Build a horse\'s setup';

  @override
  String get edited => 'Edited';

  @override
  String get theDefault => 'Default';

  @override
  String get undo => 'Undo';

  @override
  String get makeDefault => 'Make this the default';

  @override
  String get seeWhatChanged => 'See what changed last time';

  @override
  String get addDocument => 'Add a document';

  @override
  String get editChart => 'Edit chart';

  @override
  String get tackBoxIntro =>
      'Everything in here can be named on a schedule, so the groom tacks up the right kit.';

  @override
  String get setupsIntro =>
      'Pick an activity and the usual kit for it fills in.';

  @override
  String get setupDirtyNote =>
      'You have changed this from the default. Make it the new default, or undo.';

  @override
  String get saveToTackBox => 'Save to tack box';

  @override
  String get setupChangedTitle => 'Kiki\'s flatwork kit was not the default';

  @override
  String get setupChangedBody =>
      'Toni changed two things during the session. Keep the default, or make his version the new one.';

  @override
  String get makeFlatworkDefault => 'Make this the flatwork default';

  @override
  String get keepOldDefault => 'Keep the old default';

  @override
  String get nowTheDefault => 'Now the default';

  @override
  String get keptOldDefault => 'Kept the old default';

  @override
  String get backToSetups => 'Back to setups';

  @override
  String get doneLabel => 'Done';

  @override
  String get post => 'Post';

  @override
  String get read => 'Read';

  @override
  String get markRead => 'Mark read';

  @override
  String get replies => 'replies';

  @override
  String get newNotice => 'New notice';

  @override
  String get notice => 'Notice';

  @override
  String get whoSeesIt => 'Who sees it';

  @override
  String get pinToTop => 'Pin to the top';

  @override
  String get askConfirmRead => 'Ask people to confirm they read it';

  @override
  String get postNotice => 'Post notice';

  @override
  String get notices => 'Notices';

  @override
  String get pinned => 'Pinned';

  @override
  String get contacts => 'Contacts';

  @override
  String get addContact => 'Add a contact';

  @override
  String get leaveStable => 'Leave this stable';

  @override
  String get leave => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get youHaveLeft => 'You have left';

  @override
  String get backToMyStables => 'Back to my stables';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get stableLanguage => 'Stable language';

  @override
  String get help => 'Help';

  @override
  String get whatHappened => 'What happened';

  @override
  String get send => 'Send';

  @override
  String get sent => 'Sent';

  @override
  String get whereIsStable => 'Where is the stable?';

  @override
  String get saveLocation => 'Save location';

  @override
  String get directions => 'Directions';

  @override
  String get stableSettings => 'Stable settings';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get shows => 'Shows';

  @override
  String get pickAClass => 'Pick a class';

  @override
  String get seeReceipt => 'See the receipt';

  @override
  String get backToMarket => 'Back to the market';

  @override
  String get notNow => 'Not now';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteActivity => 'Delete this activity';

  @override
  String get delete => 'Delete';

  @override
  String get keepIt => 'Keep it';

  @override
  String saStepOf(int n) {
    return 'STEP $n OF 3';
  }

  @override
  String get saWhatDoYouDo => 'What do you do?';

  @override
  String get saWhatSub =>
      'Pick everything that applies. Each one is checked separately.';

  @override
  String get saTradingName => 'Trading name';

  @override
  String get saWhereYouWork => 'Where you work';

  @override
  String get saPickWhat => 'Pick what you do';

  @override
  String saContinueTrades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trades',
      one: '1 trade',
    );
    return 'Continue · $_temp0';
  }

  @override
  String get saVerifiedNote =>
      'Most of this is verified against the licence register.';

  @override
  String get saBack => 'Back';

  @override
  String get saYourPapers => 'Your papers';

  @override
  String get saPapersSub =>
      'Photograph them. We read the licence number and the expiry.';

  @override
  String get saUploaded => 'Uploaded';

  @override
  String get saDoneTag => 'DONE';

  @override
  String get saNeededTag => 'NEEDED';

  @override
  String get saAcceptPre => 'I accept the ';

  @override
  String get saSellerAgreement => 'seller agreement';

  @override
  String get saAgreementSub =>
      'Our cut, when you are paid, and that My Stables decides disputes.';

  @override
  String get saSend => 'Send application';

  @override
  String get saAcceptToSend => 'Accept the seller agreement to send this.';

  @override
  String get saUploadAllToSend => 'Upload every required paper to send this.';

  @override
  String get saWithMyStables => 'With My Stables';

  @override
  String get saSentBody =>
      'Sent. Most applications are answered within two working days. Nothing goes in front of a rider until you\'re approved.';

  @override
  String get saInMeantime => 'IN THE MEANTIME';

  @override
  String get saMeantimeBody =>
      'You can set your prices and add your first items now. They stay hidden until you are approved.';

  @override
  String get saSetUpShop => 'Set up my shop';

  @override
  String get saBackToShops => 'Back to my shops';

  @override
  String saCouldntUpload(String error) {
    return 'Couldn\'t upload: $error';
  }

  @override
  String saCouldntSend(String error) {
    return 'Couldn\'t send: $error';
  }

  @override
  String get sellOnTheMarket => 'Sell on the market';

  @override
  String get paTabToday => 'Today';

  @override
  String get paTabRequests => 'Requests';

  @override
  String get paTabOrders => 'Orders';

  @override
  String get paTabChat => 'Chat';

  @override
  String get paTabMoney => 'Money';

  @override
  String get paBooked => 'Booked';

  @override
  String get paToAnswer => 'To answer';

  @override
  String paNRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get paNoJobs => 'No jobs booked yet. Accepted requests land here.';

  @override
  String get paWhenIWork => 'When I work';

  @override
  String get paDoneTag => 'Done';

  @override
  String get paTodayTag => 'Today';

  @override
  String get paBookedTag => 'Booked';

  @override
  String get paTransport => 'Transport';

  @override
  String get paVisit => 'Visit';

  @override
  String get paWhen => 'When';

  @override
  String get paSetADay => 'Set a day';

  @override
  String get paNoteForStable => 'NOTE FOR THE STABLE';

  @override
  String get paNoteHint =>
      'Heels were low. I would bring him back in five weeks.';

  @override
  String get paNoNote => 'No note left.';

  @override
  String get paCompletedTag => 'Completed';

  @override
  String get paMarkDone => 'Mark the job done';

  @override
  String get paFinishNote =>
      'Marking it done tells the stable and settles the visit. Services are paid the day they are finished.';

  @override
  String get paNoRequests =>
      'Nothing waiting. New requests from stables show here.';

  @override
  String get paQuotedTag => 'Quoted';

  @override
  String get paNewTag => 'New';

  @override
  String get paServiceRequest => 'Service request';

  @override
  String get paFactStable => 'Stable';

  @override
  String get paFactFrom => 'From';

  @override
  String get paFactTo => 'To';

  @override
  String get paFactDay => 'Day';

  @override
  String get paFactHorses => 'Horses';

  @override
  String get paYourPrice => 'YOUR PRICE (AED)';

  @override
  String get paSendPrice => 'Send this price';

  @override
  String get paCannotTake => 'Cannot take it';

  @override
  String get paEnterPrice => 'Enter a price first.';

  @override
  String get paQuoteSentTag => 'Quote sent';

  @override
  String get paDeclinedTag => 'Declined';

  @override
  String get paQuoteSentNote =>
      'The stable will see your price and can accept it.';

  @override
  String get paDeclinedNote => 'The stable has been told you cannot take it.';

  @override
  String get paPriceFootnote =>
      'A price you can stand by — the stable accepts it as the fee.';

  @override
  String get paToPack => 'To pack';

  @override
  String get paToPackSub => 'Mark it packed and the stable is told.';

  @override
  String get paNoPack => 'Nothing to pack. New orders appear here.';

  @override
  String get paAcceptedTag => 'Accepted';

  @override
  String get paAcceptOrder => 'Accept the order';

  @override
  String get paMarkPacked => 'Mark packed';

  @override
  String get paNoChat =>
      'No conversations yet. Stables you work with appear here.';

  @override
  String get paSayHello => 'Say hello';

  @override
  String get paNoMessages => 'No messages yet.';

  @override
  String paMessageStable(String stable) {
    return 'Message $stable';
  }

  @override
  String get paNextPayout => 'NEXT PAYOUT';

  @override
  String get paPayoutNote =>
      'Paid on the 1st or the 15th, less our commission.';

  @override
  String get paHeldRow => 'Held (return windows open)';

  @override
  String get paReadyRow => 'Ready to pay out';

  @override
  String get paServicesRow => 'Services settled';

  @override
  String get paPaidRow => 'Paid out so far';

  @override
  String get paMoneyFootnote =>
      'This is the phone summary. The full ledger, payouts and disputes live on the web Seller Dashboard.';

  @override
  String get paWhenSub =>
      'Nobody can book you outside this. Change it whenever.';

  @override
  String get paWorking => 'Working';

  @override
  String get paOff => 'Off';

  @override
  String get paHorsesPerDay => 'HOW MANY HORSES A DAY';

  @override
  String get paCapNote => 'A cap keeps your day realistic.';

  @override
  String get paAway => 'AWAY';

  @override
  String get paAwaySub => 'Nobody can request these days';

  @override
  String get paAddAway => '+ Add time away';

  @override
  String get paRemove => 'Remove';

  @override
  String get bItems => 'Items';

  @override
  String get bDelivery => 'Delivery';

  @override
  String bDeliverySellers(int count) {
    return 'Delivery ($count sellers)';
  }

  @override
  String get bFree => 'Free';

  @override
  String get bCheckoutNote =>
      'You pay My Stables, not the seller. Goods sit in a 14-day return window before the seller is paid. Each seller adds their own AED 25 delivery, free over AED 300. VAT is included.';

  @override
  String get bPaymentReceived =>
      'Payment received. The seller will pack your order.';

  @override
  String get bPaymentCouldnt => 'Payment could not be taken.';

  @override
  String bCheckoutFailed(String error) {
    return 'Couldn\'t complete checkout: $error';
  }

  @override
  String get oYouPaid => 'You paid';

  @override
  String oVat(String vat) {
    return 'VAT $vat% included';
  }

  @override
  String oVatTrn(String vat, String trn) {
    return 'VAT $vat% included · TRN $trn';
  }

  @override
  String get oReportProblem => 'Report a problem';

  @override
  String get oReportBody =>
      'Tell us what went wrong. My Stables holds the seller\'s money while we look into it.';

  @override
  String get oReportHint => 'e.g. Bag split in transit';

  @override
  String get oSend => 'Send';

  @override
  String get oCancel => 'Cancel';

  @override
  String get oProblemSent => 'Sent. My Stables will look into it.';

  @override
  String oCouldntSend(String error) {
    return 'Couldn\'t send: $error';
  }

  @override
  String get oInfoDispute =>
      'A problem has been reported. My Stables is holding the seller\'s money while we look into it.';

  @override
  String get oInfoCanReturn =>
      'Delivered. You have until the return window closes to report a problem; after that the seller is paid.';

  @override
  String get oInfoDefault => 'You pay My Stables, not the seller.';

  @override
  String oCouldntCancel(String error) {
    return 'Couldn\'t cancel: $error';
  }

  @override
  String get oStatusPending => 'Pending';

  @override
  String get oStatusAccepted => 'Accepted';

  @override
  String get oStatusDelivered => 'Delivered';

  @override
  String get oStatusCancelled => 'Cancelled';

  @override
  String get oCancelOrder => 'Cancel this order';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get sdOverview => 'Overview';

  @override
  String get sdOrders => 'Orders';

  @override
  String get sdListings => 'Listings';

  @override
  String get sdRequests => 'Requests';

  @override
  String get sdMoney => 'Money';

  @override
  String get sdAccount => 'Account';

  @override
  String get sdYourShop => 'Your shop';

  @override
  String get sdSeller => 'SELLER';

  @override
  String get sdHeld => 'Held';

  @override
  String get sdPayable => 'Payable';

  @override
  String get sdInReview => 'In review — not yet visible to buyers';

  @override
  String get sdHowMoney => 'How money reaches you';

  @override
  String get sdBullet1 => 'A buyer pays My Stables — never you directly.';

  @override
  String get sdBullet2 =>
      'Goods sit in a 14-day return window; services settle the day they are done.';

  @override
  String get sdBullet3 =>
      'Your balance moves from Held to Payable when the window closes.';

  @override
  String get sdBullet4 => 'Payouts run twice a month, on the 1st and the 15th.';

  @override
  String get sdOverviewFootnote => 'Orders and listings below are live.';

  @override
  String get sdNoOrders => 'No orders yet.';

  @override
  String get sdTagPayable => 'Payable';

  @override
  String get sdTagPaid => 'Paid out';

  @override
  String get sdTagRefunded => 'Refunded';

  @override
  String get sdTagDisputed => 'Disputed';

  @override
  String get sdTagCancelled => 'Cancelled';

  @override
  String get sdTagHeld => 'Held';

  @override
  String get sdLineDelivered => 'Delivered · in the return window';

  @override
  String get sdLineHeldUntil => 'Held until delivered';

  @override
  String get sdLineClears => 'Clears on the next payout';

  @override
  String get sdLinePaid => 'Paid out';

  @override
  String get sdLineRefunded => 'Refunded to the buyer';

  @override
  String get sdLineReturn => 'A return has been raised';

  @override
  String get sdBuyerPaid => 'buyer paid';

  @override
  String get sdFee => 'fee';

  @override
  String get sdAccept => 'Accept';

  @override
  String get sdMarkDelivered => 'Mark delivered';

  @override
  String get sdRespond => 'Respond';

  @override
  String get sdYourSide => 'Your side';

  @override
  String get sdWhatHappened => 'What happened';

  @override
  String get sdAddProduct => 'Add a product';

  @override
  String get sdYouReceive => 'you receive';

  @override
  String sdAfterPct(String rate) {
    return 'after $rate%';
  }

  @override
  String get sdNewProduct => 'New product';

  @override
  String get sdAddPhoto => 'Add photo';

  @override
  String get sdChangePhoto => 'Change photo';

  @override
  String get sdName => 'Name';

  @override
  String get sdPriceAed => 'Price (AED)';

  @override
  String get sdUnit => 'Unit';

  @override
  String get sdAddProductBtn => 'Add product';

  @override
  String get sdNamePriceNeeded => 'A name and valid price are needed.';

  @override
  String get sdNoRequests => 'No requests yet.';

  @override
  String get sdServiceRequest => 'Service request';

  @override
  String get sdYourQuote => 'Your quote';

  @override
  String get sdSendQuote => 'Send a quote';

  @override
  String get sdAccepted => 'Accepted';

  @override
  String get sdQuoted => 'Quoted';

  @override
  String get sdNote => 'Note';

  @override
  String get sdPayableNow => 'Payable now';

  @override
  String get sdHowPayout => 'How a payout works';

  @override
  String get sdPayoutBody =>
      'Money is Held while the buyer can still return an item (14 days). When the window closes it becomes Payable, and lands in your bank on the next run — the 1st or the 15th, whatever cleared by then, less our commission. Services settle the day they are done.';

  @override
  String get sdPayouts => 'PAYOUTS';

  @override
  String get sdNoPayouts =>
      'No payouts yet. Your first one lands after a return window closes.';

  @override
  String get sdPaid => 'Paid';

  @override
  String get sdDue => 'Due';

  @override
  String get sdRefunds => 'refunds';

  @override
  String get sdApprovedLive => 'Approved — live in the market';

  @override
  String get sdInReviewShort => 'In review';

  @override
  String get sdApprovedFor => 'APPROVED FOR';

  @override
  String get sdNoTrades => 'No trades recorded.';

  @override
  String get sdOnTheRoad => 'On the road?';

  @override
  String get sdOnRoadBody =>
      'The provider phone app is the light view for out in the field — today\'s jobs, requests, orders to pack, chat and your money.';

  @override
  String get sdOpenProviderApp => 'Open the provider app';

  @override
  String get sdTransport => 'Transport';

  @override
  String get cnOverview => 'Overview';

  @override
  String get cnApplications => 'Applications';

  @override
  String get cnSellers => 'Sellers';

  @override
  String get cnStables => 'Stables';

  @override
  String get cnDisputes => 'Disputes';

  @override
  String get cnPayouts => 'Payouts';

  @override
  String get cnFees => 'Fees';

  @override
  String get cnAnnouncements => 'Announcements';

  @override
  String get cnOperator => 'OPERATOR';

  @override
  String get cnBackToApp => 'Back to app';

  @override
  String get cnNoData => 'No data — or this account is not an operator.';

  @override
  String get cnKpiStables => 'Stables';

  @override
  String get cnKpiPeople => 'People';

  @override
  String get cnKpiHorses => 'Horses';

  @override
  String get cnKpiAppsWaiting => 'Applications waiting';

  @override
  String get cnKpiLiveSellers => 'Live sellers';

  @override
  String get cnKpiOpenOrders => 'Open orders';

  @override
  String get cnNoApps => 'No applications waiting.';

  @override
  String get cnApprovedShopLive => 'Approved — shop is live.';

  @override
  String get cnRejected => 'Rejected.';

  @override
  String get cnPapers => 'PAPERS';

  @override
  String get cnNoPapers => 'No papers uploaded.';

  @override
  String get cnView => 'View';

  @override
  String get cnApprove => 'Approve';

  @override
  String get cnReject => 'Reject';

  @override
  String get cnApplicant => 'Applicant';

  @override
  String get cnNoSellers => 'No sellers yet.';

  @override
  String cnProductsN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get cnLive => 'Live';

  @override
  String get cnInReview => 'In review';

  @override
  String get cnSuspend => 'Suspend';

  @override
  String get cnNoStables => 'No stables yet.';

  @override
  String cnHorsesN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horses',
      one: '1 horse',
    );
    return '$_temp0';
  }

  @override
  String cnPeopleN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get cnNoDisputes => 'No disputes. A quiet marketplace.';

  @override
  String get cnArbitrates =>
      'My Stables arbitrates · services cannot be returned';

  @override
  String get cnWaitingOnYou => 'WAITING ON YOU';

  @override
  String get cnDecided => 'DECIDED';

  @override
  String get cnDecisionRecorded => 'Decision recorded.';

  @override
  String get cnDispute => 'Dispute';

  @override
  String get cnPaidSeller => 'Paid the seller';

  @override
  String get cnRefundedBuyer => 'Refunded the buyer';

  @override
  String get cnSplitIt => 'Split it';

  @override
  String get cnWaitingTag => 'Waiting on you';

  @override
  String get cnSellerNet => 'seller net';

  @override
  String get cnRefundBuyer => 'Refund the buyer';

  @override
  String get cnPaySeller => 'Pay the seller';

  @override
  String get cnBuyer => 'Buyer';

  @override
  String get cnSeller => 'Seller';

  @override
  String get cnRunPayoutsTitle => 'Run the payouts?';

  @override
  String get cnRunPayoutsBody =>
      'This closes the current cycle: every payable order is swept into a batch per seller and marked paid. This cannot be undone.';

  @override
  String get cnRunPayouts => 'Run payouts';

  @override
  String cnPaidSellersN(int count, String net) {
    return 'Paid $count sellers · AED $net.';
  }

  @override
  String get cnPayoutsNote =>
      'Paid twice a month, on the 1st and the 15th. Held money is still inside a return window and is not swept.';

  @override
  String cnPayableAcrossN(int count) {
    return 'Payable now, across $count sellers';
  }

  @override
  String get cnNothingDue =>
      'Nothing due. Money still in a return window appears when its window closes.';

  @override
  String get cnFee => 'fee';

  @override
  String get cnRefunds => 'refunds';

  @override
  String get cnHeld => 'held';

  @override
  String get cnCommission => 'COMMISSION';

  @override
  String get cnCommissionIntro =>
      'What My Stables keeps. A change is told to sellers before the period it applies to; money already held pays out at the old rate.';

  @override
  String cnCommissionOf(String label) {
    return '$label commission';
  }

  @override
  String get cnRatePct => 'Rate (%)';

  @override
  String get cnRateUpdated => 'Rate updated.';

  @override
  String get cnEdit => 'Edit';

  @override
  String get cnPayments => 'Payments';

  @override
  String get cnPaymentsSub =>
      'How buyers pay. The provider is a seam — money flows through the same held → payable → payout ledger whichever you pick.';

  @override
  String get cnProvTest => 'Test (no real money)';

  @override
  String get cnProvTelr => 'Telr (UAE)';

  @override
  String cnProviderWarn(String provider) {
    return '$provider is selected but takes no money until its Edge Function and secret keys are deployed. Buyers cannot check out until then — switch back to Test to keep trading.';
  }

  @override
  String cnProviderSelected(String provider) {
    return '$provider selected — deploy its Edge Function and keys to take real money.';
  }

  @override
  String get cnTrnOnReceipts => 'TRN on receipts';

  @override
  String get cnNotSet => 'Not set';

  @override
  String get cnEditTrn => 'Edit TRN';

  @override
  String get cnOperatorTrn => 'Operator TRN';

  @override
  String get cnTrnField => 'TRN (shown on receipts)';

  @override
  String get cnSave => 'Save';

  @override
  String get cnPostAnnouncement => 'Post an announcement';

  @override
  String get cnLiveState => 'Live';

  @override
  String get cnHidden => 'Hidden';

  @override
  String get cnNewAnnouncement => 'New announcement';

  @override
  String get cnTitle => 'Title';

  @override
  String get cnMessage => 'Message';

  @override
  String get cnKindUpdate => 'Update';

  @override
  String get cnKindShow => 'Show';

  @override
  String get cnKindAdvert => 'Advert';

  @override
  String get cnPinTop => 'Pin to the top';

  @override
  String get cnTitleMsgNeeded => 'A title and a message are needed.';
}

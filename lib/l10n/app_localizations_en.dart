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
}

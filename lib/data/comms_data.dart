// Static content for the communication and settings screens — the yard
// noticeboard, the My Stables board, contacts, help and the settings links.

class Notice {
  const Notice({
    required this.id,
    required this.pinned,
    required this.byline,
    this.title,
    required this.body,
    required this.acks,
    required this.replies,
  });
  final String id;
  final bool pinned;
  final String byline;
  final String? title;
  final String body;
  final int acks;
  final List<NoticeReply> replies;
}

class NoticeReply {
  const NoticeReply(this.who, this.text);
  final String who;
  final String text;
}

/// A post on the My Stables board (platform notices and paid placements).
class BoardPost {
  const BoardPost({
    required this.kind, // Shows / App / Advert
    required this.pinned,
    required this.when,
    required this.title,
    required this.body,
    required this.reach,
    this.hasImage = false,
  });
  final String kind;
  final bool pinned;
  final String when;
  final String title;
  final String body;
  final String reach;
  final bool hasImage;
}

class Contact {
  const Contact(this.name, this.role, this.phone, this.next);
  final String name;
  final String role;
  final String phone;
  final String next;
}

class HelpItem {
  const HelpItem(this.question, this.answer);
  final String question;
  final String answer;
}

class SettingLink {
  const SettingLink(this.route, this.label, this.meta);
  final String? route;
  final String label;
  final String meta;
}

class PersonLang {
  const PersonLang(this.name, this.role, this.lang);
  final String name;
  final String role;
  final String lang;
}

abstract final class CommsData {
  static const notices = <Notice>[
    Notice(
      id: 'n1',
      pinned: true,
      byline: 'Layal, stable manager · Monday',
      title: 'Arena closed Friday morning',
      body: 'Surface being levelled from 8 until noon. Turnout as normal.',
      acks: 9,
      replies: [
        NoticeReply('Toni', 'Can I move my 9am lesson to Saturday?'),
        NoticeReply('Layal', 'Done — 11am Saturday, indoor.'),
      ],
    ),
    Notice(
      id: 'n2',
      pinned: false,
      byline: 'Toni · 2 hours ago',
      body: 'Anyone lost a navy headcollar? It is on the tack room hook.',
      acks: 2,
      replies: [NoticeReply('Layal', 'That is Ghazal’s, thank you.')],
    ),
    Notice(
      id: 'n3',
      pinned: false,
      byline: 'Layal · yesterday',
      title: 'Hay delivery Wednesday',
      body:
          'Please keep the top gateway clear from 7am. Rasil will need a hand unloading.',
      acks: 6,
      replies: [NoticeReply('Rasil', 'I can start at 6:45.')],
    ),
    Notice(
      id: 'n4',
      pinned: false,
      byline: 'Toni · Sunday',
      body:
          'Clinic on Saturday the 29th, four places left. Reply here to take one.',
      acks: 4,
      replies: [
        NoticeReply('Ahmad', 'One for me and Kiki.'),
        NoticeReply('Layal', 'Me too please.'),
      ],
    ),
  ];

  static const audiences = ['Everyone', 'Admins', 'Trainers', 'Grooms', 'Riders'];

  static const board = <BoardPost>[
    BoardPost(
      kind: 'Shows',
      pinned: true,
      when: 'Monday',
      title: 'Spring Tour entries open Monday',
      body:
          'Three legs at Al Qudra, entered through the app for the first time this year. One fee covers all three if you enter before the first leg closes.',
      reach: 'Everyone · 268 of 312 read',
    ),
    BoardPost(
      kind: 'Advert',
      pinned: false,
      when: '3 days ago',
      title: 'Al Qudra Equestrian · Spring Tour',
      body:
          'Three legs, one entry fee. Stabling on site for all three weekends.',
      reach: 'Paid placement · shown until 15 September',
      hasImage: true,
    ),
    BoardPost(
      kind: 'App',
      pinned: false,
      when: 'Last week',
      title: 'Six languages, and right to left',
      body:
          'Arabic, English, Hindi, Urdu, Bengali and Nepali. Each person picks their own under You, then Language.',
      reach: 'Everyone · 240 read',
    ),
    BoardPost(
      kind: 'Advert',
      pinned: false,
      when: 'Last week',
      title: 'Desert Feed Co. · hay delivery Wednesdays',
      body: 'Ten bales or more, delivered to your yard across Dubai.',
      reach: 'Paid placement · Dubai stables only',
      hasImage: true,
    ),
    BoardPost(
      kind: 'App',
      pinned: false,
      when: '14 August',
      title: 'Maintenance, Friday 03:00',
      body: 'About twenty minutes. Task ticks made offline will sync afterwards.',
      reach: 'Everyone · 199 read',
    ),
  ];

  static const boardFilters = ['All', 'Shows', 'App', 'Advert'];

  static const contacts = <Contact>[
    Contact('Hamad Al Suwaidi', 'Farrier', '+971 50 448 2210',
        'Thursday 15:30 · Comme Ci, front shoes'),
    Contact('Dr Farah Nasser', 'Vet', '+971 55 903 7741',
        'Thursday 08:00 · vaccinations, six horses'),
    Contact('Ali Rahman', 'Equine dentist', '+971 52 118 9004',
        'Nothing booked'),
    Contact('Desert Feed Co.', 'Feed merchant', '+971 4 332 0088',
        'Hay delivery Wednesday 07:00'),
    Contact('Marina Physio', 'Physiotherapist', '+971 56 227 6613',
        'Nothing booked'),
  ];

  static const help = <HelpItem>[
    HelpItem('My groom cannot see the tasks I set',
        'Tasks only reach people in the same stable. Check Rasil is listed under People and not still pending approval.'),
    HelpItem('Can I be in more than one stable?',
        'Yes, with a different role in each. One account, one password. Switch from My stables.'),
    HelpItem('Who can see my horse’s health notes?',
        'You, the stable admins, and anyone you have given trainer rights. Grooms see the task, not the record.'),
    HelpItem('I left a stable. Where did my notes go?',
        'Your horse comes with you. Training and health notes written at that stable stay in its records, as they were entered there.'),
    HelpItem('The app is in the wrong language',
        'Language is per person, not per stable. Change it under You, then Language. Arabic and Urdu mirror the whole layout.'),
  ];

  static const problemKinds = <(String, String)>[
    ('Something is broken', 'The tick did not save when I had no signal.'),
    ('I cannot get in', 'The code never arrived on my phone.'),
    ('Wrong information', 'Comme Ci is shown in the wrong box.'),
    ('Someone at my stable',
        'Tell us what happened. This goes to us, not to the stable.'),
  ];

  static const problemFacts = <(String, String)>[
    ('Stable', 'Serc'),
    ('Your role', 'Groom'),
    ('App', '1.0.4'),
    ('Phone', 'Android 14'),
  ];

  static const peopleLangs = <PersonLang>[
    PersonLang('Ahmad', 'Admin · you', 'English'),
    PersonLang('Layal', 'Admin', 'العربية'),
    PersonLang('Toni', 'Trainer', 'English'),
    PersonLang('Rasil', 'Groom', 'اردو'),
    PersonLang('Jagdib', 'Groom', 'नेपाली'),
  ];

  static const meLinks = <SettingLink>[
    SettingLink('/my-stables', 'My stables', 'Three · admin, trainer, rider'),
    SettingLink('/tack-box', 'My tack box', '9 items across 7 groups'),
    SettingLink('/payments', 'Payments and receipts',
        'Orders, visits, transport and entries'),
    SettingLink('/language', 'Language and units', 'English · hands and kilos'),
    SettingLink('/help', 'Help', 'Answers, or tell us what is wrong'),
  ];

  static const stableSettingLinks = <SettingLink>[
    SettingLink('/people', 'People and roles', '6 people · 2 admins'),
    SettingLink('/approvals', 'Approvals', '3 waiting on you'),
    SettingLink('/invite', 'Invites', '2 pending · link and QR'),
    SettingLink('/contacts', 'Contacts', 'Farrier, vet, dentist, feed merchant'),
    SettingLink('/set-location', 'Name and location', 'Serc · Al Qudra Rd, Dubai'),
    SettingLink('/stable-language', 'Stable language', 'English · people choose'),
  ];
}

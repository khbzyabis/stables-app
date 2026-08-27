// Static content for the Shows screens — the shows list, a single show with
// its classes, and a start list. Ported from the design handoff.

class ShowRow {
  const ShowRow(this.day, this.month, this.name, this.meta, this.state, this.tone);
  final String day;
  final String month;
  final String name;
  final String meta;
  final String state;
  final String tone; // sage / accent / neutral
}

class ShowLink {
  const ShowLink(this.label, this.meta);
  final String label;
  final String meta;
}

class CandHorse {
  const CandHorse(this.name, this.note, this.tag, this.well);
  final String name;
  final String note;
  final String tag;
  final bool well;
}

class ShowClass {
  const ShowClass(this.id, this.name, this.meta, this.fee);
  final String id;
  final String name;
  final String meta;
  final int fee;
}

class EntryHorse {
  const EntryHorse(this.name, this.warn);
  final String name;
  final String warn;
}

class StartEntry {
  const StartEntry(this.no, this.rider, this.horse, this.at,
      {this.me = false, this.stable = false});
  final int no;
  final String rider;
  final String horse;
  final String at;
  final bool me;
  final bool stable;
}

class PaidDelivery {
  const PaidDelivery(this.seller, this.what, this.when);
  final String seller;
  final String what;
  final String when;
}

abstract final class ShowsData {
  static const candHorses = <CandHorse>[
    CandHorse('Joy', 'Farrier Thursday', 'Well', true),
    CandHorse('Comme Ci', 'Box rest · day 3 of 10', 'Watch', false),
    CandHorse('Abby', 'Schooled yesterday · 40 min', 'Well', true),
  ];

  static const shows = <ShowRow>[
    ShowRow('29', 'Aug', 'Al Qudra Spring Tour, leg 1',
        'Al Qudra Arena · 1.10 m and 1.20 m', 'Entries open', 'sage'),
    ShowRow('05', 'Sep', 'Sharjah Autumn Open',
        'Sharjah Riding Club · dressage', 'Closes Friday', 'accent'),
    ShowRow('12', 'Sep', 'Emirates Park Novice Day',
        'Emirates Park · unaffiliated', 'Start list out', 'neutral'),
    ShowRow('26', 'Sep', 'Al Marmoom Endurance 80 km',
        'Al Marmoom · vet gate at 40 km', 'Entries open', 'sage'),
  ];

  static const showLinks = <ShowLink>[
    ShowLink('Start lists and results', 'Joy is 14th to go on Saturday'),
    ShowLink('Shops and services', 'Feed, tack, farriers, vets, physios'),
    ShowLink('Your entries', 'Two entered, one waiting on payment'),
  ];

  static const showFacts = <(String, String)>[
    ('Where', 'Al Qudra Arena · 14 km from Serc'),
    ('Entries close', 'Thursday 27 August, noon'),
    ('Vaccinations', 'Checked from each horse’s documents'),
    ('From Serc', 'Layal has entered Abby in the 90 cm'),
  ];

  static const classes = <ShowClass>[
    ShowClass('c1', '90 cm, class 1', 'Against the clock · 08:00', 150),
    ShowClass('c2', '1.10 m, class 3', 'Two phases · 09:00', 200),
    ShowClass('c3', '1.20 m, class 5', 'Table A · 11:30', 250),
    ShowClass('c4', '1.20 m Grand Prix',
        'Jump-off · 14:00 · qualifying required', 400),
  ];

  static const entryHorses = <EntryHorse>[
    EntryHorse('Joy', 'Joy jumped 1.10 m last month. Vaccinations are current.'),
    EntryHorse('Comme Ci',
        'Comme Ci came off box rest three days ago. Ask the vet before you enter him.'),
    EntryHorse('Abby',
        'Abby has not jumped above 90 cm. She is not qualified for the Grand Prix.'),
  ];

  static const startList = <StartEntry>[
    StartEntry(11, 'Noura Al Falasi', 'Bandit', '10:11'),
    StartEntry(12, 'Omar Sayegh', 'Vela', '10:14'),
    StartEntry(13, 'Layal', 'Abby', '10:22', stable: true),
    StartEntry(14, 'Ahmad', 'Joy', '10:25', me: true),
    StartEntry(15, 'Sara Haddad', 'Nimbus', '10:28'),
    StartEntry(16, 'Fatima Darwish', 'Zephyr', '10:31'),
    StartEntry(17, 'Khalid Bin Zayed', 'Onyx', '10:34'),
    StartEntry(18, 'Maya Rahman', 'Juno', '10:37'),
  ];

  static const paidDeliveries = <PaidDelivery>[
    PaidDelivery('Al Suwaidi', 'Snaffle and hoof oil · AED 320',
        'Wednesday, before noon'),
    PaidDelivery('Desert Feed Co.', 'Chaff ×2 · AED 149',
        'Wednesday, afternoon run'),
  ];
}

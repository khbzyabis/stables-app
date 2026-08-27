import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Static content for the horse-record screens — tack box, setups, health,
/// training, feed chart, documents and progress. Ported from the design
/// handoff (Joy's record). One place so a screen and its data stay together.

/// A group of tack items (Bridles, Nosebands, …).
class TackGroup {
  const TackGroup(this.name, this.items);
  final String name;
  final List<TackItem> items;
  String get summary =>
      '${items.length} item${items.length == 1 ? '' : 's'} · ${items.first.name}';
}

class TackItem {
  const TackItem(this.name, this.note);
  final String name;
  final String note;
}

/// A slot in a horse's setup (Bridle, Noseband, …) and its options.
class SetupSlot {
  const SetupSlot(this.key, this.label, this.options);
  final String key;
  final String label;
  final List<String> options;
}

/// One line in a feed chart.
class FeedRow {
  const FeedRow(this.item, this.amount, this.note);
  final String item;
  final String amount;
  final String note;
}

/// A stored document with an expiry-driven status.
class HorseDoc {
  const HorseDoc(this.name, this.ext, this.meta, this.status, this.tone);
  final String name;
  final String ext;
  final String meta;
  final String status;
  final Color tone; // dot / tag colour
}

/// A health-record entry.
class HealthEntry {
  const HealthEntry(this.date, this.kind, this.title, this.note);
  final String date;
  final String kind; // Vet / Farrier / Vaccination / Note
  final String title;
  final String note;
  Color get hue => switch (kind) {
        'Vet' => AppColors.accent700,
        'Farrier' => AppColors.accent500,
        'Vaccination' => AppColors.accent2700,
        _ => AppColors.neutral500,
      };
}

/// A training session, with how it felt.
class TrainingSession {
  const TrainingSession(this.date, this.title, this.meta, this.feel, this.detail);
  final String date;
  final String title;
  final String meta;
  final String feel; // Good / Easy / Tense
  final String detail;
  Color get feelHue => switch (feel) {
        'Tense' => AppColors.accent700,
        'Easy' => AppColors.accent2600,
        _ => AppColors.accent2700,
      };
}

/// A link on the horse-record hub.
class RecordLink {
  const RecordLink(this.route, this.label, this.meta);
  final String route;
  final String label;
  final String meta;
}

/// A bar + rows for a progress range.
class ProgressSet {
  const ProgressSet(this.bars, this.caption, this.rows, this.note);
  final List<(String, int)> bars;
  final String caption;
  final List<ProgressRow> rows;
  final String note;
}

class ProgressRow {
  const ProgressRow(this.label, this.meta, this.value);
  final String label;
  final String meta;
  final String value;
}

abstract final class HorseDetailData {
  static const tackGroups = <TackGroup>[
    TackGroup('Bridles', [
      TackItem('Brown snaffle bridle', 'Full size · everyday'),
      TackItem('Black double bridle', 'Shows only'),
    ]),
    TackGroup('Nosebands', [
      TackItem('Cavesson', 'Sits on the brown bridle'),
      TackItem('Grackle', 'For jumping'),
      TackItem('Flash', 'Spare'),
    ]),
    TackGroup('Bits', [
      TackItem('Loose ring snaffle 13.5cm', 'Default'),
      TackItem('Eggbutt French link', 'Softer mouth days'),
    ]),
    TackGroup('Reins', [
      TackItem('Rubber grip reins', 'Brown'),
      TackItem('Web reins with stops', 'Jumping'),
    ]),
    TackGroup('Saddles and girths', [
      TackItem('Dressage saddle 17.5"', 'Brown · Joy'),
      TackItem('Jump saddle 17"', 'Brown'),
      TackItem('Elastic girth 125cm', ''),
    ]),
    TackGroup('Boots and bandages', [
      TackItem('Brushing boots', 'Front pair'),
      TackItem('Open front boots', 'Jumping'),
      TackItem('Polo wraps', 'Navy · four'),
    ]),
    TackGroup('Rugs', [
      TackItem('Cooler rug', 'After work'),
      TackItem('Fly sheet', 'Summer turnout'),
    ]),
  ];

  static const slots = <SetupSlot>[
    SetupSlot('bridle', 'Bridle', ['Brown snaffle bridle', 'Black double bridle']),
    SetupSlot('noseband', 'Noseband', ['Cavesson', 'Grackle', 'Flash']),
    SetupSlot('bit', 'Bit', ['Loose ring snaffle 13.5cm', 'Eggbutt French link']),
    SetupSlot('reins', 'Reins', ['Rubber grip reins', 'Web reins with stops']),
    SetupSlot('saddle', 'Saddle', ['Dressage saddle 17.5"', 'Jump saddle 17"']),
    SetupSlot('boots', 'Boots',
        ['Brushing boots', 'Open front boots', 'Polo wraps', 'None']),
  ];

  static const activities = ['Flatwork', 'Jumping', 'Hacking', 'Lunging'];

  static const setupDefaults = <String, Map<String, String>>{
    'Flatwork': {
      'bridle': 'Brown snaffle bridle',
      'noseband': 'Cavesson',
      'bit': 'Loose ring snaffle 13.5cm',
      'reins': 'Rubber grip reins',
      'saddle': 'Dressage saddle 17.5"',
      'boots': 'Brushing boots',
    },
    'Jumping': {
      'bridle': 'Brown snaffle bridle',
      'noseband': 'Grackle',
      'bit': 'Loose ring snaffle 13.5cm',
      'reins': 'Web reins with stops',
      'saddle': 'Jump saddle 17"',
      'boots': 'Open front boots',
    },
    'Hacking': {
      'bridle': 'Brown snaffle bridle',
      'noseband': 'Cavesson',
      'bit': 'Eggbutt French link',
      'reins': 'Rubber grip reins',
      'saddle': 'Jump saddle 17"',
      'boots': 'Brushing boots',
    },
    'Lunging': {
      'bridle': 'Brown snaffle bridle',
      'noseband': 'Cavesson',
      'bit': 'Loose ring snaffle 13.5cm',
      'reins': 'None',
      'saddle': 'None',
      'boots': 'Brushing boots',
    },
  };

  static const setupUsedNotes = <String, String>{
    'Flatwork': 'Used 14 times · last Monday',
    'Jumping': 'Used 6 times · last Saturday',
    'Hacking': 'Used 3 times · last month',
    'Lunging': 'Used 9 times · Wednesday',
  };

  /// What Toni changed last time on the flatwork setup — screen 23.
  static const diff = <(String, String, String)>[
    ('Noseband', 'Cavesson', 'Grackle'),
    ('Boots', 'Brushing boots', 'Open front boots'),
  ];

  static const feedChart = <String, List<FeedRow>>{
    'Morning': [
      FeedRow('Chaff, low sugar', '1 scoop', 'The blue scoop'),
      FeedRow('Balancer pellets', '200 g', ''),
      FeedRow('Hay', '4 kg', 'Soaked on dusty days'),
    ],
    'Midday': [
      FeedRow('Hay', '3 kg', 'In the paddock'),
      FeedRow('Electrolytes', '1 sachet', 'Summer only'),
    ],
    'Evening': [
      FeedRow('Chaff, low sugar', '1 scoop', ''),
      FeedRow('Balancer pellets', '200 g', ''),
      FeedRow('Oil', '30 ml', 'Stirred through'),
      FeedRow('Hay', '5 kg', 'Largest feed of the day'),
    ],
  };

  static const documents = <HorseDoc>[
    HorseDoc('Passport', 'PDF', 'Scanned 12 Mar 2024', 'On file',
        AppColors.neutral500),
    HorseDoc('Insurance certificate', 'PDF', 'Expires 30 Sep 2026', 'Expiring',
        AppColors.accent500),
    HorseDoc('Vaccination card', 'PDF', 'Flu and tetanus · next late Sep',
        'Current', AppColors.accent2600),
    HorseDoc('Purchase agreement', 'PDF', 'Signed 4 Jan 2023', 'On file',
        AppColors.neutral500),
    HorseDoc('X-rays, left fore', 'JPG', 'Dr Farah · 11 Aug 2026', 'On file',
        AppColors.neutral500),
  ];

  static const health = <HealthEntry>[
    HealthEntry('18 Aug', 'Farrier', 'Front shoes due',
        'Hamad booked for Thursday 15:30'),
    HealthEntry('11 Aug', 'Note', 'Slight heat, left fore',
        'Cold hosed twice. Sound the next morning.'),
    HealthEntry('02 Aug', 'Vet', 'Routine check',
        'Dr Farah · teeth fine, weight good'),
    HealthEntry('24 Jul', 'Farrier', 'Full set', 'Hamad · six week cycle'),
    HealthEntry('09 Jul', 'Vaccination', 'Flu and tetanus',
        'Next due late September'),
  ];

  static const healthFilters = ['All', 'Vet', 'Farrier', 'Vaccination', 'Note'];

  static const sessions = <TrainingSession>[
    TrainingSession('17 Aug', 'Flatwork', 'Toni · 45 min · outdoor', 'Good',
        'Softer through the left rein than last week. Kept the trot work short and finished on a long rein.'),
    TrainingSession('15 Aug', 'Jumping grid', 'Toni · 40 min · indoor', 'Good',
        'Three fences at 90cm, straight and forward. Rushed the second line once, settled on the retry.'),
    TrainingSession('13 Aug', 'Hack out', 'Ahmad · 1 hr 20 · desert loop',
        'Easy', 'Mostly walk with two canters. Relaxed the whole way out.'),
    TrainingSession('11 Aug', 'Lunging', 'Rasil · 20 min · round pen', 'Tense',
        'Stiff at the start, better after ten minutes. Watch the left fore.'),
  ];

  /// Session lengths over the last fortnight (0 = rest day) — the load bars.
  static const load = <int>[3, 0, 5, 2, 0, 6, 1, 4, 0, 5, 3, 0, 4, 2];

  static const progress = <String, ProgressSet>{
    '1 month': ProgressSet(
      [('Wk1', 3), ('Wk2', 4), ('Wk3', 2), ('Wk4', 5)],
      'Sessions a week · four weeks',
      [
        ProgressRow('Ridden', '14 sessions', '9 h 20'),
        ProgressRow('Jumped', 'Three sessions', '3'),
        ProgressRow('Days off', 'Two in a row once', '6'),
        ProgressRow('Highest', 'Grid work, 18 August', '1.10 m'),
      ],
      'She is fitter than last month and settling faster in the first ten minutes.',
    ),
    '3 months': ProgressSet(
      [('Jun', 9), ('Jul', 13), ('Aug', 14), ('Sep', 4)],
      'Sessions a month · September is four days in',
      [
        ProgressRow('Ridden', '40 sessions', '27 h'),
        ProgressRow('Flatwork to jumping', 'Two flat for every jump', '2 : 1'),
        ProgressRow('Longest gap', 'Farrier and a shoe lost', '9 days'),
        ProgressRow('Highest', 'Spring Tour warm-up', '1.15 m'),
      ],
      'Transitions are cleaner than in June, and she is jumping out of a rhythm rather than off her forehand.',
    ),
    'A year': ProgressSet(
      [('Q3', 22), ('Q4', 31), ('Q1', 38), ('Q2', 34)],
      'Sessions a quarter',
      [
        ProgressRow('Ridden', '125 sessions', '84 h'),
        ProgressRow('Shows', 'Placed in four', '11'),
        ProgressRow('Off with injury', 'One abscess, one bruise', '3 weeks'),
        ProgressRow('Highest', 'Spring Tour, leg 2', '1.20 m'),
      ],
      'A year ago she would not have held a 1.20 m course. The winter of flatwork is what did it.',
    ),
  };

  static const progressRanges = ['1 month', '3 months', 'A year'];

  /// What moves and what stays when a horse leaves a stable — screen 63.
  static const moveEffects = <(String, String)>[
    ('Health and training notes written at Serc', 'Stay here'),
    ('Passport, insurance, vaccination card', 'Go with her'),
    ('Her setups and feed chart', 'Go with her'),
    ('Your tack box', 'Yours anyway'),
  ];
}

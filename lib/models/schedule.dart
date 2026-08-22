import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import '../widgets/app_tag.dart';

/// The kinds of thing that appear on a stable's schedule, each with a hue for
/// the agenda row's left border and a tag tone. Colours match the prototype.
enum EventKind {
  riding('Riding', TagTone.accent),
  lesson('Lesson', TagTone.accent),
  lunging('Lunging', TagTone.sage),
  walker('Walker', TagTone.sage),
  handWalk('Hand walk', TagTone.neutral),
  feed('Feed', TagTone.neutral),
  vet('Vet', TagTone.outline);

  const EventKind(this.label, this.tone);
  final String label;
  final TagTone tone;

  Color get hue => switch (this) {
        EventKind.riding => AppColors.accent500,
        EventKind.lesson => AppColors.accent700,
        EventKind.lunging => AppColors.accent2500,
        EventKind.walker => AppColors.accent2700,
        EventKind.handWalk => AppColors.neutral700,
        EventKind.feed => AppColors.neutral500,
        EventKind.vet => AppColors.accent700,
      };
}

/// One item on a day's agenda.
class ScheduleEvent {
  const ScheduleEvent({
    required this.time,
    required this.duration,
    required this.title,
    required this.meta,
    required this.kind,
  });

  final String time;
  final String duration;
  final String title;
  final String meta;
  final EventKind kind;
}

/// A day in the week strip.
class ScheduleDay {
  const ScheduleDay({required this.dow, required this.num, required this.load});
  final String dow;
  final int num;

  /// How busy the day is — drives the little dots under the number.
  final int load;
}

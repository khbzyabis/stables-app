import '../models/schedule.dart';

/// Sample schedule content for the foundation (in production this comes from the
/// API). Mirrors the prototype's week of August 17–23.
abstract final class ScheduleData {
  static const week = <ScheduleDay>[
    ScheduleDay(dow: 'Mon', num: 17, load: 2),
    ScheduleDay(dow: 'Tue', num: 18, load: 3),
    ScheduleDay(dow: 'Wed', num: 19, load: 1),
    ScheduleDay(dow: 'Thu', num: 20, load: 3),
    ScheduleDay(dow: 'Fri', num: 21, load: 0),
    ScheduleDay(dow: 'Sat', num: 22, load: 3),
    ScheduleDay(dow: 'Sun', num: 23, load: 1),
  ];

  static const events = <int, List<ScheduleEvent>>{
    17: [
      ScheduleEvent(time: '06:30', duration: '45 min', title: 'Morning feeds', meta: 'Rasil · all 14 horses', kind: EventKind.feed),
      ScheduleEvent(time: '17:00', duration: '1 hr', title: 'Flatwork with Kiki', meta: 'Toni · outdoor arena', kind: EventKind.riding),
    ],
    18: [
      ScheduleEvent(time: '06:30', duration: '45 min', title: 'Morning feeds', meta: 'Rasil · all 14 horses', kind: EventKind.feed),
      ScheduleEvent(time: '10:00', duration: '1 hr', title: 'Layal · lesson on Ghazal', meta: 'Toni · indoor school', kind: EventKind.lesson),
      ScheduleEvent(time: '15:30', duration: '30 min', title: 'Farrier for Comme Ci', meta: 'Front shoes · Hamad', kind: EventKind.vet),
    ],
    19: [
      ScheduleEvent(time: '06:30', duration: '45 min', title: 'Morning feeds', meta: 'Rasil · all 14 horses', kind: EventKind.feed),
      ScheduleEvent(time: '14:00', duration: '30 min', title: 'Walker · Kiki and Nour', meta: 'Rasil · two rounds', kind: EventKind.walker),
    ],
    20: [
      ScheduleEvent(time: '08:00', duration: '2 hr', title: 'Vet visit · vaccinations', meta: 'Six horses · Dr Farah', kind: EventKind.vet),
      ScheduleEvent(time: '11:00', duration: '45 min', title: 'Beginners group', meta: 'Three riders · Layal', kind: EventKind.lesson),
      ScheduleEvent(time: '18:00', duration: '20 min', title: 'Lunging Abby', meta: 'Toni · round pen', kind: EventKind.lunging),
    ],
    21: [],
    22: [
      ScheduleEvent(time: '07:00', duration: '3 hr', title: 'Desert hack', meta: 'Five riders · meet at the gate', kind: EventKind.riding),
      ScheduleEvent(time: '11:00', duration: '1 hr', title: 'Ahmad · private lesson', meta: 'Toni · indoor school', kind: EventKind.lesson),
      ScheduleEvent(time: '16:00', duration: '15 min', title: 'Hand walk Comme Ci', meta: 'Rasil · box rest, day 7', kind: EventKind.handWalk),
    ],
    23: [
      ScheduleEvent(time: '09:00', duration: '1 hr', title: 'Pony club taster', meta: 'Layal · four children', kind: EventKind.lesson),
    ],
  };
}

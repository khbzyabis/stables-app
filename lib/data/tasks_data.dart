import '../models/task.dart';

/// Sample task content for the foundation (server state in production).
abstract final class TasksData {
  static const groomDay = <StableTask>[
    StableTask(id: 'd1', title: 'Morning feeds, all 14', meta: 'Ahmad · daily', time: '06:30'),
    StableTask(id: 'd2', title: 'Turn out the front paddock six', meta: 'Ahmad · daily', time: '07:15'),
    StableTask(id: 'd3', title: 'Tack up Kiki for flatwork', meta: 'Ahmad · setup saved', time: '08:45', note: 'Cavesson, not the grackle'),
    StableTask(id: 'd4', title: "Poultice Comme Ci's left fore", meta: 'Layal · until Friday', time: '10:00', note: 'Cold hose first, ten minutes'),
    StableTask(id: 'd5', title: 'Muck out boxes 1 to 7', meta: 'Layal · daily', time: '11:00'),
    StableTask(id: 'd6', title: 'Walker: Kiki and Nour, two rounds', meta: 'Ahmad · today only', time: '14:00'),
    StableTask(id: 'd7', title: 'Evening feeds and rugs', meta: 'Ahmad · daily', time: '17:30'),
  ];

  /// Tasks already done when the groom opens the app (3 of 7).
  static const initiallyDone = {'d1', 'd2', 'd3'};

  static const staff = <StaffProgress>[
    StaffProgress(name: 'Rasil', initial: 'R', role: 'Groom', done: 4, total: 7, latest: 'Last ticked: muck out boxes 1 to 7, 11:20'),
    StaffProgress(name: 'Jagdib', initial: 'J', role: 'Groom', done: 3, total: 4, latest: 'Last ticked: feed order placed, 09:40'),
    StaffProgress(name: 'Toni', initial: 'T', role: 'Trainer', done: 2, total: 2, latest: 'All done · finished 12:10'),
  ];

  static const assignees = ['Rasil', 'Jagdib', 'Toni', 'Layal'];
}

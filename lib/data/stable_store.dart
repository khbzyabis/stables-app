import 'package:flutter/widgets.dart';

import '../models/horse.dart';

/// In-memory stable state for the foundation. In production this is server
/// state (the current stable, the person's role, the horses they can see);
/// here it is a simple [ChangeNotifier] so adding a horse updates the home
/// list immediately.
class StableStore extends ChangeNotifier {
  StableStore() {
    _horses.addAll(_seed());
  }

  final List<Horse> _horses = [];
  List<Horse> get horses => List.unmodifiable(_horses);

  String get stableName => 'Serc';

  Horse byId(String id) => _horses.firstWhere((h) => h.id == id);

  void addHorse(Horse horse) {
    _horses.insert(0, horse);
    notifyListeners();
  }

  int _counter = 0;
  String nextId() => 'h${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  static List<Horse> _seed() => [
        Horse(
          id: 'kiki',
          name: 'Kiki',
          statusLine: 'Farrier due Thursday',
          status: HorseStatus.well,
          age: '9 years',
          breed: 'Arabian',
        ),
        Horse(
          id: 'commeci',
          name: 'Comme Ci',
          statusLine: 'Box rest · day 3 of 10',
          status: HorseStatus.watch,
        ),
        Horse(
          id: 'abby',
          name: 'Abby',
          statusLine: 'Schooled yesterday · 40 min',
          status: HorseStatus.well,
        ),
      ];
}

/// Exposes the [StableStore] to the widget tree.
class StableScope extends InheritedNotifier<StableStore> {
  const StableScope({
    super.key,
    required StableStore store,
    required super.child,
  }) : super(notifier: store);

  static StableStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StableScope>();
    assert(scope != null, 'No StableScope found in context');
    return scope!.notifier!;
  }
}

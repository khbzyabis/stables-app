import 'package:flutter/widgets.dart';

import '../api/api_config.dart';
import '../api/horses_api.dart';
import '../models/horse.dart';

enum LoadStatus { loading, ready, error }

/// Stable state for the app. When an API is configured (see [ApiConfig]) it
/// reads and writes through [HorsesApi]; otherwise it runs offline with local
/// sample data so the preview and first run work without a backend.
class StableStore extends ChangeNotifier {
  StableStore({HorsesApi? api, String? stableId})
      // ignore: prefer_initializing_formals — private field can't be a named formal
      : _api = api,
        _stableId = stableId ?? ApiConfig.stableId {
    if (_api == null) {
      _horses.addAll(_seed());
      _status = LoadStatus.ready;
    } else {
      _status = LoadStatus.loading;
      // Fire-and-forget initial load; UI observes [status].
      load();
    }
  }

  final HorsesApi? _api;
  final String _stableId;

  final List<Horse> _horses = [];
  List<Horse> get horses => List.unmodifiable(_horses);

  LoadStatus _status = LoadStatus.loading;
  LoadStatus get status => _status;

  String? _error;
  String? get error => _error;

  String get stableName => 'Serc';

  bool get isOnline => _api != null;

  Horse byId(String id) => _horses.firstWhere((h) => h.id == id);

  Future<void> load() async {
    final api = _api;
    if (api == null) return;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final fetched = await api.list(_stableId);
      _horses
        ..clear()
        ..addAll(fetched);
      _status = LoadStatus.ready;
    } catch (e) {
      _error = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Adds a horse. Online: POSTs and inserts the server's row. Offline: inserts
  /// locally. Returns the created horse.
  Future<Horse> addHorse(Horse horse) async {
    final api = _api;
    if (api != null) {
      final created = await api.create(_stableId, horse);
      _horses.insert(0, created);
      notifyListeners();
      return created;
    }
    _horses.insert(0, horse);
    notifyListeners();
    return horse;
  }

  int _counter = 0;
  String nextId() => 'h${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  static List<Horse> _seed() => [
        Horse(
          id: 'kiki',
          name: 'Joy',
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

import 'package:flutter/widgets.dart';

import 'supabase_service.dart';

/// App-wide session state: which stables the signed-in person belongs to, and
/// which one is currently active. Screens read the active stable from here and
/// load their own rows (horses, notices) for it.
class AppSession extends ChangeNotifier {
  List<Map<String, dynamic>> _stables = const [];
  List<Map<String, dynamic>> _pending = const [];
  String? _activeId;
  bool _loading = false;
  Object? _error;

  List<Map<String, dynamic>> get stables => _stables;
  List<Map<String, dynamic>> get pendingRequests => _pending;
  bool get hasPending => _pending.isNotEmpty;
  bool get loading => _loading;
  Object? get error => _error;

  Map<String, dynamic>? get activeStable {
    if (_stables.isEmpty) return null;
    return _stables.firstWhere(
      (s) => s['id'] == _activeId,
      orElse: () => _stables.first,
    );
  }

  String? get activeStableId => activeStable?['id'] as String?;
  String get activeStableName =>
      (activeStable?['name'] as String?) ?? 'Your stable';
  bool get hasStable => _stables.isNotEmpty;

  void setActive(String id) {
    _activeId = id;
    notifyListeners();
  }

  /// Load the current person's stables. Safe to call repeatedly.
  Future<void> refresh() async {
    if (!SupabaseService.isSignedIn) {
      _stables = const [];
      _pending = const [];
      _activeId = null;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stables = await SupabaseService.myStables();
      _activeId ??= _stables.isNotEmpty ? _stables.first['id'] as String : null;
      // Best-effort: which stables am I still waiting to be approved for.
      try {
        _pending = await SupabaseService.myPendingRequests();
      } catch (_) {
        _pending = const [];
      }
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Create a stable, then make it the active one.
  Future<void> createStable(String name, String? city) async {
    final stable = await SupabaseService.createStable(name: name, city: city);
    _activeId = stable['id'] as String?;
    await refresh();
  }

  void clear() {
    _stables = const [];
    _pending = const [];
    _activeId = null;
    notifyListeners();
  }
}

/// Exposes the [AppSession] to the widget tree.
class SessionScope extends InheritedNotifier<AppSession> {
  const SessionScope({
    super.key,
    required AppSession session,
    required super.child,
  }) : super(notifier: session);

  static AppSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope found in context');
    return scope!.notifier!;
  }
}

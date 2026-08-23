import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over the Supabase client — auth plus the read/write calls the
/// app needs. Row Level Security on the database enforces that a person only
/// ever sees data for stables they belong to; `created_by` / `user_id` are
/// filled in by database defaults (`auth.uid()`), so the client never sets them.
class SupabaseService {
  static SupabaseClient get _db => Supabase.instance.client;

  /// The client if Supabase has been initialized, else null. Lets the app and
  /// its widget tests run even before (or without) initialization.
  static SupabaseClient? get _clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ---- Auth ------------------------------------------------------------
  static User? get currentUser => _clientOrNull?.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static String get displayName =>
      (currentUser?.userMetadata?['name'] as String?)?.trim().isNotEmpty == true
          ? currentUser!.userMetadata!['name'] as String
          : (currentUser?.email?.split('@').first ?? 'You');

  static Stream<AuthState> get authChanges =>
      _clientOrNull?.auth.onAuthStateChange ?? const Stream.empty();

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) =>
      _db.auth.signUp(email: email, password: password, data: {'name': name});

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _db.auth.signInWithPassword(email: email, password: password);

  static Future<void> resendConfirmation(String email) =>
      _db.auth.resend(type: OtpType.signup, email: email);

  static Future<void> signOut() => _db.auth.signOut();

  // ---- Stables ---------------------------------------------------------
  /// The stables the current person belongs to, each with their role.
  static Future<List<Map<String, dynamic>>> myStables() async {
    final rows = await _db
        .from('memberships')
        .select('role, stables(*)')
        .order('created_at');
    return rows
        .where((r) => r['stables'] != null)
        .map<Map<String, dynamic>>((r) => {
              ...Map<String, dynamic>.from(r['stables'] as Map),
              'role': r['role'],
            })
        .toList();
  }

  /// Create a stable and make the creator its first admin member.
  static Future<Map<String, dynamic>> createStable(
      {required String name, String? city}) async {
    final stable = await _db
        .from('stables')
        .insert({'name': name, if (city != null && city.isNotEmpty) 'city': city})
        .select()
        .single();
    await _db
        .from('memberships')
        .insert({'stable_id': stable['id'], 'role': 'Admin'});
    return stable;
  }

  // ---- Members & invites ----------------------------------------------
  /// Everyone in a stable, with their role and display name.
  static Future<List<Map<String, dynamic>>> members(String stableId) async {
    final rows = await _db
        .from('memberships')
        .select('role, user_id')
        .eq('stable_id', stableId)
        .order('created_at');
    final ids = rows.map((r) => r['user_id'] as String).toList();
    final profiles = ids.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _db.from('profiles').select('id, name, email').inFilter('id', ids);
    final byId = {for (final p in profiles) p['id'] as String: p};
    return rows.map<Map<String, dynamic>>((r) {
      final p = byId[r['user_id']];
      final name = (p?['name'] as String?)?.trim();
      final email = p?['email'] as String?;
      return {
        'user_id': r['user_id'],
        'role': r['role'],
        'name': (name != null && name.isNotEmpty)
            ? name
            : (email?.split('@').first ?? 'Member'),
        'email': email,
        'is_me': r['user_id'] == currentUser?.id,
      };
    }).toList();
  }

  /// Create a shareable invite for a stable and return its code.
  static Future<String> createInvite({
    required String stableId,
    required String role,
    required String code,
  }) async {
    await _db.from('invites').insert({
      'stable_id': stableId,
      'role': role,
      'code': code.toUpperCase(),
    });
    return code.toUpperCase();
  }

  /// Join a stable using an invite code. Returns the stable row.
  static Future<Map<String, dynamic>> redeemInvite(String code) async {
    final row = await _db.rpc('redeem_invite', params: {'invite_code': code});
    // rpc returns the stable record (a single row).
    if (row is List && row.isNotEmpty) return Map<String, dynamic>.from(row.first);
    return Map<String, dynamic>.from(row as Map);
  }

  // ---- Horses ----------------------------------------------------------
  static Future<List<Map<String, dynamic>>> horses(String stableId) => _db
      .from('horses')
      .select()
      .eq('stable_id', stableId)
      .order('created_at');

  static Future<Map<String, dynamic>> addHorse({
    required String stableId,
    required String name,
    String? age,
    String? breed,
    String? sex,
    String? height,
    String? box,
    String? notes,
  }) =>
      _db.from('horses').insert({
        'stable_id': stableId,
        'name': name,
        if (age != null && age.isNotEmpty) 'age': age,
        if (breed != null && breed.isNotEmpty) 'breed': breed,
        if (sex != null && sex.isNotEmpty) 'sex': sex,
        if (height != null && height.isNotEmpty) 'height': height,
        if (box != null && box.isNotEmpty) 'box': box,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }).select().single();

  // ---- Schedule activities --------------------------------------------
  static Future<List<Map<String, dynamic>>> activities(String stableId) => _db
      .from('activities')
      .select()
      .eq('stable_id', stableId)
      .order('on_date')
      .order('at_time');

  static Future<Map<String, dynamic>> addActivity({
    required String stableId,
    required String title,
    required String kind,
    required String onDate, // ISO yyyy-MM-dd
    String? atTime,
    String? duration,
    String? who,
    String? note,
  }) =>
      _db.from('activities').insert({
        'stable_id': stableId,
        'title': title,
        'kind': kind,
        'on_date': onDate,
        if (atTime != null && atTime.isNotEmpty) 'at_time': atTime,
        if (duration != null && duration.isNotEmpty) 'duration': duration,
        if (who != null && who.isNotEmpty) 'who': who,
        if (note != null && note.isNotEmpty) 'note': note,
      }).select().single();

  // ---- Tasks -----------------------------------------------------------
  static Future<List<Map<String, dynamic>>> tasks(String stableId) => _db
      .from('tasks')
      .select()
      .eq('stable_id', stableId)
      .order('created_at');

  static Future<Map<String, dynamic>> addTask({
    required String stableId,
    required String title,
    String? assignee,
    String? due,
    String? note,
  }) =>
      _db.from('tasks').insert({
        'stable_id': stableId,
        'title': title,
        if (assignee != null && assignee.isNotEmpty) 'assignee': assignee,
        if (due != null && due.isNotEmpty) 'due': due,
        if (note != null && note.isNotEmpty) 'note': note,
      }).select().single();

  static Future<void> setTaskDone(String id, bool done) => _db
      .from('tasks')
      .update({'done': done, 'done_by': done ? currentUser?.id : null})
      .eq('id', id);

  // ---- Health, training, feed (a horse's record) ----------------------
  static Future<List<Map<String, dynamic>>> healthEntries(String horseId) => _db
      .from('health_entries')
      .select()
      .eq('horse_id', horseId)
      .order('on_date', ascending: false);

  static Future<Map<String, dynamic>> addHealthEntry({
    required String horseId,
    required String stableId,
    required String kind,
    required String title,
    String? note,
    String? onDate,
  }) =>
      _db.from('health_entries').insert({
        'horse_id': horseId,
        'stable_id': stableId,
        'kind': kind,
        'title': title,
        if (note != null && note.isNotEmpty) 'note': note,
        if (onDate != null && onDate.isNotEmpty) 'on_date': onDate,
      }).select().single();

  static Future<List<Map<String, dynamic>>> trainingSessions(String horseId) =>
      _db
          .from('training_sessions')
          .select()
          .eq('horse_id', horseId)
          .order('on_date', ascending: false);

  static Future<Map<String, dynamic>> addTrainingSession({
    required String horseId,
    required String stableId,
    required String title,
    required String feel,
    String? meta,
    String? detail,
    String? onDate,
  }) =>
      _db.from('training_sessions').insert({
        'horse_id': horseId,
        'stable_id': stableId,
        'title': title,
        'feel': feel,
        if (meta != null && meta.isNotEmpty) 'meta': meta,
        if (detail != null && detail.isNotEmpty) 'detail': detail,
        if (onDate != null && onDate.isNotEmpty) 'on_date': onDate,
      }).select().single();

  static Future<List<Map<String, dynamic>>> feedItems(String horseId) => _db
      .from('feed_items')
      .select()
      .eq('horse_id', horseId)
      .order('created_at');

  static Future<Map<String, dynamic>> addFeedItem({
    required String horseId,
    required String stableId,
    required String timeOfDay,
    required String item,
    String? amount,
    String? note,
  }) =>
      _db.from('feed_items').insert({
        'horse_id': horseId,
        'stable_id': stableId,
        'time_of_day': timeOfDay,
        'item': item,
        if (amount != null && amount.isNotEmpty) 'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      }).select().single();

  // ---- Notices (the board) --------------------------------------------
  static Future<List<Map<String, dynamic>>> notices(String stableId) => _db
      .from('notices')
      .select()
      .eq('stable_id', stableId)
      .order('pinned', ascending: false)
      .order('created_at', ascending: false);

  static Future<Map<String, dynamic>> postNotice({
    required String stableId,
    required String body,
    String? title,
    bool pinned = false,
  }) =>
      _db.from('notices').insert({
        'stable_id': stableId,
        'body': body,
        if (title != null && title.isNotEmpty) 'title': title,
        'pinned': pinned,
        'author_name': displayName,
      }).select().single();
}

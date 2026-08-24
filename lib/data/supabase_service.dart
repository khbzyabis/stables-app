import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'analytics.dart';

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
  }) async {
    final res = await _db.auth
        .signUp(email: email, password: password, data: {'name': name});
    Analytics.capture('signed_up');
    return res;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final res =
        await _db.auth.signInWithPassword(email: email, password: password);
    Analytics.capture('signed_in');
    return res;
  }

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
        .insert({'stable_id': stable['id'], 'role': 'owner'});
    // Give the new stable a default (all-on) feature row. Best-effort.
    try {
      await _db.from('stable_features').insert({'stable_id': stable['id']});
    } catch (_) {}
    Analytics.capture('stable_created', {'stable_id': stable['id'] as String});
    return stable;
  }

  // ---- Members & invites ----------------------------------------------
  /// Everyone in a stable, with their role and display name.
  static Future<List<Map<String, dynamic>>> members(String stableId) async {
    final rows = await _db
        .from('memberships')
        .select('id, role, status, user_id')
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
        'membership_id': r['id'],
        'user_id': r['user_id'],
        'role': r['role'],
        'status': (r['status'] as String?) ?? 'active',
        'name': (name != null && name.isNotEmpty)
            ? name
            : (email?.split('@').first ?? 'Member'),
        'email': email,
        'is_me': r['user_id'] == currentUser?.id,
      };
    }).toList();
  }

  /// The roles a member can hold, lightest to fullest access.
  static const roles = <String>[
    'viewer',
    'rider',
    'groom',
    'vet',
    'manager',
    'owner',
  ];

  /// Roles you can invite someone in as (everything except owner).
  static const invitableRoles = <String>[
    'manager',
    'vet',
    'groom',
    'rider',
    'viewer',
  ];

  /// Change a member's role. Only owners/managers can (enforced by RLS).
  static Future<void> updateMemberRole(String membershipId, String role) => _db
      .from('memberships')
      .update({'role': role})
      .eq('id', membershipId);

  /// Approve a pending join (set status active). Admin-only via RLS.
  static Future<void> approveMember(String membershipId) => _db
      .from('memberships')
      .update({'status': 'active'})
      .eq('id', membershipId);

  /// Remove a member from a stable (or yourself). Admin-or-self via RLS.
  static Future<void> removeMember(String membershipId) =>
      _db.from('memberships').delete().eq('id', membershipId);

  /// People waiting to be let into the stable (status = pending).
  static Future<List<Map<String, dynamic>>> pendingMembers(
      String stableId) async {
    final all = await members(stableId);
    return all.where((m) => m['status'] == 'pending').toList();
  }

  // ---- Feature toggles -------------------------------------------------
  /// Which modules are on for a stable. Defaults everything on if no row yet.
  static Future<Map<String, bool>> stableFeatures(String stableId) async {
    final row = await _db
        .from('stable_features')
        .select()
        .eq('stable_id', stableId)
        .maybeSingle();
    return {
      'market': (row?['market'] as bool?) ?? true,
      'transport': (row?['transport'] as bool?) ?? true,
      'shows': (row?['shows'] as bool?) ?? true,
      'require_approval': (row?['require_approval'] as bool?) ?? false,
    };
  }

  /// Turn a feature on/off for a stable. Admin-only via RLS. Upserts the row.
  static Future<void> setStableFeature(
          String stableId, String feature, bool value) =>
      _db.from('stable_features').upsert(
        {'stable_id': stableId, feature: value, 'updated_at': _nowIso()},
        onConflict: 'stable_id',
      );

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();

  // ---- Stable overview (dashboard counts) ------------------------------
  /// A snapshot of a stable for the overview dashboard: how many horses and
  /// people, how many tasks are still open, and who's waiting to join.
  static Future<Map<String, int>> stableOverview(String stableId) async {
    final results = await Future.wait([
      _db.from('horses').select('id').eq('stable_id', stableId).count(),
      _db.from('memberships').select('id').eq('stable_id', stableId).count(),
      _db
          .from('memberships')
          .select('id')
          .eq('stable_id', stableId)
          .eq('status', 'pending')
          .count(),
      _db
          .from('tasks')
          .select('id')
          .eq('stable_id', stableId)
          .eq('done', false)
          .count(),
    ]);
    return {
      'horses': results[0].count,
      'people': results[1].count,
      'pending': results[2].count,
      'open_tasks': results[3].count,
    };
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
    Analytics.capture('stable_joined');
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
    String? photoUrl,
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
        'photo_url': ?photoUrl,
      }).select().single().then((row) {
        Analytics.capture('horse_added', {'stable_id': stableId});
        return row;
      });

  /// Update a horse's editable details and/or status. Only members can (RLS).
  static Future<Map<String, dynamic>> updateHorse(
    String id, {
    String? name,
    String? age,
    String? breed,
    String? sex,
    String? height,
    String? box,
    String? notes,
    String? status,
    String? photoUrl,
  }) =>
      _db.from('horses').update({
        'name': ?name,
        'age': ?age,
        'breed': ?breed,
        'sex': ?sex,
        'height': ?height,
        'box': ?box,
        'notes': ?notes,
        'status': ?status,
        'photo_url': ?photoUrl,
      }).eq('id', id).select().single();

  /// Remove a horse from the stable.
  static Future<void> deleteHorse(String id) =>
      _db.from('horses').delete().eq('id', id);

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

  static Future<void> setTaskDone(String id, bool done) async {
    await _db
        .from('tasks')
        .update({'done': done, 'done_by': done ? currentUser?.id : null})
        .eq('id', id);
    if (done) Analytics.capture('task_completed');
  }

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

  // ---- Tack box & setups ----------------------------------------------
  static Future<List<Map<String, dynamic>>> tackItems(String stableId) => _db
      .from('tack_items')
      .select()
      .eq('stable_id', stableId)
      .order('group_name')
      .order('created_at');

  static Future<Map<String, dynamic>> addTackItem({
    required String stableId,
    required String group,
    required String name,
    String? note,
  }) =>
      _db.from('tack_items').insert({
        'stable_id': stableId,
        'group_name': group,
        'name': name,
        if (note != null && note.isNotEmpty) 'note': note,
      }).select().single();

  static Future<List<Map<String, dynamic>>> horseSetups(String horseId) => _db
      .from('horse_setups')
      .select()
      .eq('horse_id', horseId);

  /// Create or update the setup for a horse + activity.
  static Future<void> saveSetup({
    required String horseId,
    required String stableId,
    required String activity,
    required Map<String, String> slots,
  }) =>
      _db.from('horse_setups').upsert({
        'horse_id': horseId,
        'stable_id': stableId,
        'activity': activity,
        'slots': slots,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'horse_id,activity');

  // ---- Contacts --------------------------------------------------------
  static Future<List<Map<String, dynamic>>> contacts(String stableId) => _db
      .from('contacts')
      .select()
      .eq('stable_id', stableId)
      .order('created_at');

  static Future<Map<String, dynamic>> addContact({
    required String stableId,
    required String name,
    String? role,
    String? phone,
    String? nextNote,
  }) =>
      _db.from('contacts').insert({
        'stable_id': stableId,
        'name': name,
        if (role != null && role.isNotEmpty) 'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (nextNote != null && nextNote.isNotEmpty) 'next_note': nextNote,
      }).select().single();

  // ---- Documents (metadata + files in the horse-docs bucket) ----------
  static const _docsBucket = 'horse-docs';

  static Future<List<Map<String, dynamic>>> documents(String horseId) => _db
      .from('documents')
      .select()
      .eq('horse_id', horseId)
      .order('created_at', ascending: false);

  /// Upload the file bytes to storage, then record the document row.
  static Future<Map<String, dynamic>> addDocument({
    required String horseId,
    required String stableId,
    required String name,
    required String fileName,
    required Uint8List bytes,
    String status = 'On file',
  }) async {
    final path =
        '$horseId/${DateTime.now().microsecondsSinceEpoch}_$fileName';
    await _db.storage.from(_docsBucket).uploadBinary(path, bytes,
        fileOptions: const FileOptions(upsert: false));
    return _db.from('documents').insert({
      'horse_id': horseId,
      'stable_id': stableId,
      'name': name,
      'status': status,
      'storage_path': path,
    }).select().single();
  }

  /// A short-lived link to open/download a stored document.
  static Future<String> documentUrl(String storagePath) =>
      _db.storage.from(_docsBucket).createSignedUrl(storagePath, 3600);

  // ---- Photos ----------------------------------------------------------
  static const _photosBucket = 'photos';

  /// Upload image bytes to the public photos bucket and return a public URL.
  /// [folder] keeps things tidy (e.g. 'horses', 'products').
  static Future<String> uploadPhoto({
    required String folder,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final safe = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$folder/${DateTime.now().microsecondsSinceEpoch}_$safe';
    await _db.storage.from(_photosBucket).uploadBinary(path, bytes,
        fileOptions: const FileOptions(upsert: false, contentType: 'image/*'));
    return _db.storage.from(_photosBucket).getPublicUrl(path);
  }

  // ---- Transport requests ---------------------------------------------
  static Future<List<Map<String, dynamic>>> transportRequests(
          String stableId) =>
      _db
          .from('transport_requests')
          .select()
          .eq('stable_id', stableId)
          .order('created_at', ascending: false);

  static Future<Map<String, dynamic>> addTransportRequest({
    required String stableId,
    String? reason,
    required String from,
    required String to,
    String? onDay,
    String? thereBy,
    required List<String> horses,
    required List<String> needs,
  }) =>
      _db.from('transport_requests').insert({
        'stable_id': stableId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'from_loc': from,
        'to_loc': to,
        if (onDay != null && onDay.isNotEmpty) 'on_day': onDay,
        if (thereBy != null && thereBy.isNotEmpty) 'there_by': thereBy,
        'horses': horses,
        'needs': needs,
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

  // ---- Marketplace: browsing (buyer side) -----------------------------
  static const marketCategories = <String>[
    'Feed',
    'Tack',
    'Hoofcare',
    'Rugs',
    'Services',
  ];

  /// Products in a category, across all approved vendors, with the seller name.
  static Future<List<Map<String, dynamic>>> marketProducts(
      String category) async {
    final rows = await _db
        .from('products')
        .select('*, vendors(name, city, kind)')
        .eq('category', category)
        .eq('in_stock', true)
        .order('created_at', ascending: false);
    return rows.map<Map<String, dynamic>>((r) {
      final v = r['vendors'] as Map?;
      return {
        ...Map<String, dynamic>.from(r),
        'vendor_name': v?['name'] ?? 'Seller',
        'vendor_city': v?['city'],
      };
    }).toList();
  }

  // ---- Marketplace: orders (buyer side) -------------------------------
  /// Place one order for a single vendor. [items] are maps with keys
  /// product_id, name, unit_price_aed, qty. Returns the created order row.
  static Future<Map<String, dynamic>> placeOrder({
    required String vendorId,
    String? stableId,
    required List<Map<String, dynamic>> items,
    String? note,
  }) async {
    final total = items.fold<double>(
        0, (t, i) => t + (i['unit_price_aed'] as num) * (i['qty'] as num));
    final order = await _db.from('orders').insert({
      'vendor_id': vendorId,
      'stable_id': ?stableId,
      'note': ?note,
      'total_aed': total,
    }).select().single();
    final orderId = order['id'] as String;
    await _db.from('order_items').insert([
      for (final i in items)
        {
          'order_id': orderId,
          'product_id': i['product_id'],
          'name': i['name'],
          'unit_price_aed': i['unit_price_aed'],
          'qty': i['qty'],
        }
    ]);
    Analytics.capture('order_placed', {'vendor_id': vendorId});
    return order;
  }

  /// The current person's orders (buyer side), newest first, with vendor names.
  static Future<List<Map<String, dynamic>>> myOrders() async {
    final rows = await _db
        .from('orders')
        .select('*, vendors(name)')
        .eq('buyer_id', currentUser?.id ?? '')
        .order('created_at', ascending: false);
    return rows.map<Map<String, dynamic>>((r) {
      final v = r['vendors'] as Map?;
      return {...Map<String, dynamic>.from(r), 'vendor_name': v?['name'] ?? 'Seller'};
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> orderItems(String orderId) => _db
      .from('order_items')
      .select()
      .eq('order_id', orderId)
      .order('name');

  /// Buyer cancels their own order.
  static Future<void> cancelOrder(String orderId) => _db
      .from('orders')
      .update({'status': 'cancelled'})
      .eq('id', orderId);

  // ---- Marketplace: provider (seller side) ----------------------------
  /// Vendors the current person owns.
  static Future<List<Map<String, dynamic>>> myVendors() => _db
      .from('vendors')
      .select()
      .eq('owner_id', currentUser?.id ?? '')
      .order('created_at');

  static Future<Map<String, dynamic>> createVendor({
    required String name,
    String? kind,
    String? city,
    String? about,
  }) =>
      _db.from('vendors').insert({
        'name': name,
        'kind': ?kind,
        'city': ?city,
        'about': ?about,
      }).select().single();

  static Future<List<Map<String, dynamic>>> vendorProducts(String vendorId) =>
      _db
          .from('products')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

  static Future<Map<String, dynamic>> addProduct({
    required String vendorId,
    required String name,
    required double priceAed,
    required String category,
    String? unit,
    String? description,
    String? imageUrl,
  }) =>
      _db.from('products').insert({
        'vendor_id': vendorId,
        'name': name,
        'price_aed': priceAed,
        'category': category,
        'unit': ?unit,
        'description': ?description,
        'image_url': ?imageUrl,
      }).select().single();

  static Future<void> setProductStock(String productId, bool inStock) => _db
      .from('products')
      .update({'in_stock': inStock})
      .eq('id', productId);

  static Future<void> deleteProduct(String productId) =>
      _db.from('products').delete().eq('id', productId);

  /// Orders placed with a vendor the current person owns, newest first.
  static Future<List<Map<String, dynamic>>> vendorOrders(String vendorId) => _db
      .from('orders')
      .select()
      .eq('vendor_id', vendorId)
      .order('created_at', ascending: false);

  /// Vendor advances an order: accepted / fulfilled / cancelled.
  static Future<void> setOrderStatus(String orderId, String status) => _db
      .from('orders')
      .update({'status': status})
      .eq('id', orderId);

  // ---- Shows ----------------------------------------------------------
  static Future<List<Map<String, dynamic>>> shows(String stableId) => _db
      .from('shows')
      .select()
      .eq('stable_id', stableId)
      .order('on_date', ascending: true);

  static Future<Map<String, dynamic>> addShow({
    required String stableId,
    required String name,
    String? venue,
    String? discipline,
    String? onDate, // ISO yyyy-MM-dd
    String? state,
  }) =>
      _db.from('shows').insert({
        'stable_id': stableId,
        'name': name,
        'venue': ?venue,
        'discipline': ?discipline,
        'on_date': ?onDate,
        'state': ?state,
      }).select().single();

  static Future<void> deleteShow(String id) =>
      _db.from('shows').delete().eq('id', id);

  /// Entries for a show, ordered as a start list (by time then created).
  static Future<List<Map<String, dynamic>>> showEntries(String showId) => _db
      .from('show_entries')
      .select()
      .eq('show_id', showId)
      .order('at_time', ascending: true, nullsFirst: false)
      .order('created_at');

  static Future<Map<String, dynamic>> addShowEntry({
    required String showId,
    required String horseName,
    String? horseId,
    String? riderName,
    String? className,
    String? atTime,
  }) =>
      _db.from('show_entries').insert({
        'show_id': showId,
        'horse_name': horseName,
        'horse_id': ?horseId,
        'rider_name': ?riderName,
        'class_name': ?className,
        'at_time': ?atTime,
      }).select().single();

  static Future<void> withdrawEntry(String id) => _db
      .from('show_entries')
      .update({'status': 'withdrawn'})
      .eq('id', id);

  // ---- Operator / admin ----------------------------------------------
  /// Is the current person a platform operator?
  static Future<bool> isAppAdmin() async {
    final id = currentUser?.id;
    if (id == null) return false;
    final row = await _db
        .from('app_admins')
        .select('user_id')
        .eq('user_id', id)
        .maybeSingle();
    return row != null;
  }

  /// Active announcements for the "From My Stables" board (everyone reads).
  static Future<List<Map<String, dynamic>>> announcements() => _db
      .from('announcements')
      .select()
      .eq('active', true)
      .order('pinned', ascending: false)
      .order('created_at', ascending: false);

  /// Every announcement (operator view, includes inactive).
  static Future<List<Map<String, dynamic>>> allAnnouncements() => _db
      .from('announcements')
      .select()
      .order('created_at', ascending: false);

  static Future<Map<String, dynamic>> addAnnouncement({
    required String title,
    required String body,
    String kind = 'Update',
    bool pinned = false,
  }) =>
      _db.from('announcements').insert({
        'title': title,
        'body': body,
        'kind': kind,
        'pinned': pinned,
      }).select().single();

  static Future<void> setAnnouncementActive(String id, bool active) => _db
      .from('announcements')
      .update({'active': active})
      .eq('id', id);

  static Future<void> deleteAnnouncement(String id) =>
      _db.from('announcements').delete().eq('id', id);

  /// Vendors awaiting operator approval.
  static Future<List<Map<String, dynamic>>> pendingVendors() => _db
      .from('vendors')
      .select()
      .eq('approved', false)
      .order('created_at');

  static Future<void> setVendorApproved(String id, bool approved) => _db
      .from('vendors')
      .update({'approved': approved})
      .eq('id', id);

  // ---- Quote requests (service & transport providers) -----------------
  /// Kinds a shop can be. Products come from Feed…Services shops; Services and
  /// Transport shops instead take quote requests.
  static const providerKinds = <String>[
    'Feed',
    'Tack',
    'Hoofcare',
    'Rugs',
    'Services',
    'Transport',
  ];

  /// Approved vendors of a given kind (e.g. 'Services', 'Transport').
  static Future<List<Map<String, dynamic>>> vendorsOfKind(String kind) => _db
      .from('vendors')
      .select()
      .eq('kind', kind)
      .eq('approved', true)
      .order('name');

  /// A stable asks a specific provider for a price.
  static Future<Map<String, dynamic>> requestQuote({
    required String kind, // 'service' | 'transport'
    required String vendorId,
    String? stableId,
    String? subject,
    String? detail,
    String? fromLoc,
    String? toLoc,
    String? onDay,
    int? horses,
  }) =>
      _db.from('quote_requests').insert({
        'kind': kind,
        'vendor_id': vendorId,
        'stable_id': ?stableId,
        'subject': ?subject,
        'detail': ?detail,
        'from_loc': ?fromLoc,
        'to_loc': ?toLoc,
        'on_day': ?onDay,
        'horses': ?horses,
      }).select().single();

  /// The current person's quote requests (buyer side). Optionally by kind.
  static Future<List<Map<String, dynamic>>> myQuoteRequests({String? kind}) async {
    var q = _db
        .from('quote_requests')
        .select('*, vendors(name)')
        .eq('buyer_id', currentUser?.id ?? '');
    if (kind != null) q = q.eq('kind', kind);
    final rows = await q.order('created_at', ascending: false);
    return rows.map<Map<String, dynamic>>((r) {
      final v = r['vendors'] as Map?;
      return {...Map<String, dynamic>.from(r), 'vendor_name': v?['name'] ?? 'Provider'};
    }).toList();
  }

  /// Requests sent to a vendor the current person owns (provider side).
  static Future<List<Map<String, dynamic>>> vendorQuoteRequests(
          String vendorId) =>
      _db
          .from('quote_requests')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

  /// Provider replies with a price. Marks the request 'quoted'.
  static Future<void> submitQuote(
          String id, double price, String? note) =>
      _db.from('quote_requests').update({
        'quote_price': price,
        'quote_note': ?note,
        'status': 'quoted',
        'quoted_at': _nowIso(),
      }).eq('id', id);

  /// Buyer accepts or declines a quote.
  static Future<void> setQuoteStatus(String id, String status) =>
      _db.from('quote_requests').update({'status': status}).eq('id', id);
}

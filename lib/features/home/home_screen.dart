import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../auth/create_stable_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/bottom_tab_bar.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../horses/add_horse_screen.dart';
import '../horses/horse_record_screen.dart';
import '../horses/tack_box_screen.dart';
import '../board/board_screen.dart';
import '../board/post_notice_screen.dart';
import '../settings/contacts_screen.dart';
import '../settings/help_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/stable_settings_screen.dart';
import '../shows/shows_screen.dart';
import '../market/market_screen.dart';
import '../market/payments_screen.dart';
import '../market/my_quotes_screen.dart';
import '../people/approvals_screen.dart';
import '../people/my_stables_screen.dart';
import '../people/people_screen.dart';
import '../schedule/schedule_screen.dart';
import '../transport/request_transport_screen.dart';
import '../tasks/groom_day_screen.dart';

/// Screen 06 — Home. Leads with My horses; a four-tab bar switches to the
/// noticeboard, the stable, and you. Home leads with horses because that is
/// what every role recognises first.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _tab = AppTab.horses;

  @override
  void initState() {
    super.initState();
    // Load the person's stables the first time home opens.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => SessionScope.of(context).refresh());
  }

  String _titleFor(AppL10n l10n) => switch (_tab) {
        AppTab.horses => l10n.titleMyHorses,
        AppTab.board => l10n.titleNoticeboard,
        AppTab.stable => l10n.titleTheStable,
        AppTab.you => l10n.titleYou,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = SessionScope.of(context);
    final day = DateFormat.EEEE(Localizations.localeOf(context).toString())
        .format(DateTime.now());
    final initial = SupabaseService.displayName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.stableAndDay(session.activeStableName, day),
                              style:
                                  AppText.eyebrow(color: AppColors.accent700),
                            ),
                            const SizedBox(height: 10),
                            Text(_titleFor(l10n),
                                style: AppText.heading(40, height: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Avatar(initial: initial),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                    child: (session.activeStableId == null && session.hasPending)
                      ? _PendingPanel(session: session)
                      : switch (_tab) {
                      AppTab.horses => _HorsesTab(stableId: session.activeStableId),
                      AppTab.board => _BoardTab(stableId: session.activeStableId),
                      AppTab.stable => _StableTab(
                          stableId: session.activeStableId,
                          role: session.activeStable?['role'] as String?,
                          city: session.activeStable?['city'] as String?,
                        ),
                      AppTab.you => const _YouTab(),
                    },
                  ),
                ),
                BottomTabBar(
                  current: _tab,
                  onChanged: (t) => setState(() => _tab = t),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent2300,
        shape: BoxShape.circle,
      ),
      child: Text(initial,
          style: AppText.heading(17, color: AppColors.accent2900)),
    );
  }
}

class _HorsesTab extends StatefulWidget {
  const _HorsesTab({required this.stableId});
  final String? stableId;

  @override
  State<_HorsesTab> createState() => _HorsesTabState();
}

class _HorsesTabState extends State<_HorsesTab> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final id = widget.stableId;
    if (id == null) return const [];
    return SupabaseService.horses(id);
  }

  void _reload() => setState(() => _future = _load());

  @override
  void didUpdateWidget(covariant _HorsesTab old) {
    super.didUpdateWidget(old);
    if (old.stableId != widget.stableId) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    if (widget.stableId == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 26),
        child: Text(
          'Create a stable first (under You → My stables), then add horses to it.',
          style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6)),
        ),
      );
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2.4),
            ),
          );
        }
        if (snap.hasError) {
          return _ErrorState(message: snap.error.toString(), onRetry: () async => _reload());
        }
        final horses = snap.data ?? const [];
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const Hairline(),
            if (horses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Text(
                  'No horses yet. Add your first one below — it saves to this stable and everyone in it can see it.',
                  style:
                      AppText.body(16, height: 1.5, color: AppColors.ink(0.6)),
                ),
              ),
            for (final h in horses) ...[
              _RealHorseRow(horse: h, onReturn: _reload),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _TextAction(
                label: '+ ${l10n.addAHorse}',
                onTap: () async {
                  await Navigator.of(context).pushNamed(AddHorseScreen.route);
                  _reload();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _RealHorseRow extends StatelessWidget {
  const _RealHorseRow({required this.horse, required this.onReturn});
  final Map<String, dynamic> horse;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final well = (horse['status'] as String?) != 'watch';
    final bits = <String>[
      for (final k in ['breed', 'age'])
        if ((horse[k] as String?)?.isNotEmpty == true) horse[k] as String,
      if ((horse['box'] as String?)?.isNotEmpty == true) 'Box ${horse['box']}',
    ];
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(HorseRecordScreen.route, arguments: horse);
        onReturn();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            PhotoPlaceholder(size: 66, url: horse['photo_url'] as String?),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((horse['name'] as String?) ?? 'Horse',
                      style: AppText.heading(23, height: 1.1)),
                  if (bits.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(bits.join(' · '),
                        style: AppText.body(15, color: AppColors.ink(0.6))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppTag(well ? l10n.statusWell : l10n.statusWatch,
                tone: well ? TagTone.sage : TagTone.neutral),
          ],
        ),
      ),
    );
  }
}

class _BoardTab extends StatefulWidget {
  const _BoardTab({required this.stableId});
  final String? stableId;

  @override
  State<_BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<_BoardTab> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final id = widget.stableId;
    if (id == null) return const [];
    return SupabaseService.notices(id);
  }

  void _reload() => setState(() => _future = _load());

  @override
  void didUpdateWidget(covariant _BoardTab old) {
    super.didUpdateWidget(old);
    if (old.stableId != widget.stableId) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    if (widget.stableId == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 26),
        child: Text(
          'Create a stable first, then post notices the whole stable can see.',
          style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6)),
        ),
      );
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2.4),
            ),
          );
        }
        if (snap.hasError) {
          return _ErrorState(message: snap.error.toString(), onRetry: () async => _reload());
        }
        final notices = snap.data ?? const [];
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const Hairline(),
            if (notices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Text(
                  'Nothing on the board yet. Post the first notice — everyone in the stable will see it.',
                  style:
                      AppText.body(16, height: 1.5, color: AppColors.ink(0.6)),
                ),
              ),
            for (final n in notices) ...[
              _Notice(
                meta: [
                  if (n['pinned'] == true) 'Pinned',
                  (n['author_name'] as String?) ?? 'Someone',
                ].join(' · '),
                metaColor:
                    n['pinned'] == true ? AppColors.accent700 : null,
                title: n['title'] as String?,
                body: (n['body'] as String?) ?? '',
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _TextAction(
                label: '+ ${l10n.postANotice}',
                onTap: () async {
                  await Navigator.of(context).pushNamed(PostNoticeScreen.route);
                  _reload();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.meta,
    this.title,
    required this.body,
    this.metaColor,
  });
  final String meta;
  final String? title;
  final String body;
  final Color? metaColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meta,
              style: AppText.body(13,
                  color: metaColor ?? AppColors.ink(0.5))),
          const SizedBox(height: 7),
          if (title != null) ...[
            Text(title!, style: AppText.heading(23, height: 1.2)),
            const SizedBox(height: 6),
          ],
          Text(body,
              style: AppText.body(16, height: 1.5, color: AppColors.ink(0.85))),
        ],
      ),
    );
  }
}

/// The Stable tab — a live overview strip (real counts) above the stable-wide
/// navigation. Modules the stable has turned off are hidden; owners/managers
/// also see people-management rows.
class _StableTab extends StatefulWidget {
  const _StableTab({required this.stableId, this.role, this.city});
  final String? stableId;
  final String? role;
  final String? city;

  @override
  State<_StableTab> createState() => _StableTabState();
}

class _StableTabState extends State<_StableTab> {
  late Future<_StableSnapshot> _future = _load();

  bool get _isAdmin => widget.role == 'owner' || widget.role == 'manager';

  Future<_StableSnapshot> _load() async {
    final id = widget.stableId;
    if (id == null) return const _StableSnapshot.empty();
    final results = await Future.wait([
      SupabaseService.stableOverview(id),
      SupabaseService.stableFeatures(id),
    ]);
    return _StableSnapshot(
      counts: results[0] as Map<String, int>,
      features: results[1] as Map<String, bool>,
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  void didUpdateWidget(covariant _StableTab old) {
    super.didUpdateWidget(old);
    if (old.stableId != widget.stableId) _reload();
  }

  Future<void> _go(String route) async {
    await Navigator.of(context).pushNamed(route);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    if (widget.stableId == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 26),
        child: Text(
          'Create a stable first (under You → My stables) to see its overview.',
          style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6)),
        ),
      );
    }
    return FutureBuilder<_StableSnapshot>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data ?? const _StableSnapshot.empty();
        final c = data.counts;
        final f = data.features;
        final loading = snap.connectionState == ConnectionState.waiting;
        final pending = c['pending'] ?? 0;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Overview stat tiles.
            Row(
              children: [
                _StatTile(
                    label: 'Horses',
                    value: loading ? '—' : '${c['horses'] ?? 0}'),
                const SizedBox(width: 12),
                _StatTile(
                    label: 'People',
                    value: loading ? '—' : '${c['people'] ?? 0}'),
                const SizedBox(width: 12),
                _StatTile(
                    label: 'Open tasks',
                    value: loading ? '—' : '${c['open_tasks'] ?? 0}'),
              ],
            ),
            if (_isAdmin && pending > 0) ...[
              const SizedBox(height: 12),
              _PendingBanner(
                count: pending,
                onTap: () => _go(ApprovalsScreen.route),
              ),
            ],
            const SizedBox(height: 20),
            const Hairline(),
            _NavRow(
              title: l10n.openSchedule,
              subtitle: l10n.scheduleSub,
              onTap: () => _go(ScheduleScreen.route),
            ),
            const Hairline(),
            _NavRow(
              title: l10n.openTasks,
              subtitle: l10n.tasksSub,
              onTap: () => _go(GroomDayScreen.route),
            ),
            const Hairline(),
            if (f['market'] ?? true) ...[
              _NavRow(
                title: l10n.market,
                subtitle: l10n.marketSub,
                onTap: () => _go(MarketScreen.route),
              ),
              const Hairline(),
            ],
            if (f['transport'] ?? true) ...[
              _NavRow(
                title: l10n.transport,
                subtitle: l10n.transportSub,
                onTap: () => _go(RequestTransportScreen.route),
              ),
              const Hairline(),
            ],
            _NavRow(
              title: l10n.people,
              subtitle: loading
                  ? l10n.peopleNavSub
                  : '${c['people'] ?? 0} in this stable',
              onTap: () => _go(PeopleScreen.route),
            ),
            const Hairline(),
            if (_isAdmin) ...[
              _NavRow(
                title: l10n.needsYou,
                subtitle: pending > 0
                    ? '$pending waiting to join'
                    : l10n.nothingJoins,
                onTap: () => _go(ApprovalsScreen.route),
              ),
              const Hairline(),
            ],
            _NavRow(
              title: l10n.contacts,
              subtitle: 'Farrier, vet, dentist, feed merchant',
              onTap: () => _go(ContactsScreen.route),
            ),
            const Hairline(),
            _NavRow(
              title: l10n.stableSettings,
              subtitle: loading
                  ? '…'
                  : [
                      if ((widget.city ?? '').isNotEmpty) widget.city!,
                      '${c['horses'] ?? 0} horses',
                      '${c['people'] ?? 0} people',
                    ].join(' · '),
              onTap: () => _go(StableSettingsScreen.route),
            ),
            const Hairline(),
          ],
        );
      },
    );
  }
}

/// The overview counts + feature flags for the active stable, loaded together.
class _StableSnapshot {
  const _StableSnapshot({required this.counts, required this.features});
  const _StableSnapshot.empty()
      : counts = const {},
        features = const {};
  final Map<String, int> counts;
  final Map<String, bool> features;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppText.heading(30, height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: AppText.body(13, color: AppColors.ink(0.6))),
          ],
        ),
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.accent200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                count == 1
                    ? '1 person is waiting to join'
                    : '$count people are waiting to join',
                style: AppText.heading(17, color: AppColors.accent900),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.accent900),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow(
      {required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.heading(23, height: 1.1)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppText.body(15, color: AppColors.ink(0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
          ],
        ),
      ),
    );
  }
}

/// The "You" tab hosts the live language switcher for now.
class _YouTab extends StatefulWidget {
  const _YouTab();

  @override
  State<_YouTab> createState() => _YouTabState();
}

class _YouTabState extends State<_YouTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;
    final languages = <(String, String)>[
      ('en', l10n.langEnglish),
      ('ar', l10n.langArabic),
      ('hi', l10n.langHindi),
      ('ur', l10n.langUrdu),
      ('bn', l10n.langBengali),
      ('ne', l10n.langNepali),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Hairline(),
        _NavRow(
          title: l10n.yourProfile,
          subtitle: SupabaseService.currentUser?.email ?? 'Your account',
          onTap: () => Navigator.of(context).pushNamed(ProfileScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.myStables,
          subtitle: l10n.rolePerStable,
          onTap: () => Navigator.of(context).pushNamed(MyStablesScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.tackBox,
          subtitle: '9 items across 7 groups',
          onTap: () => Navigator.of(context).pushNamed(TackBoxScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: 'My orders',
          subtitle: 'What you have ordered from the market',
          onTap: () => Navigator.of(context).pushNamed(PaymentsScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: 'My quotes',
          subtitle: 'Prices from service and transport providers',
          onTap: () => Navigator.of(context).pushNamed(MyQuotesScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.help,
          subtitle: 'Answers, or tell us what is wrong',
          onTap: () => Navigator.of(context).pushNamed(HelpScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.notices,
          subtitle: 'From My Stables — shows, updates and adverts',
          onTap: () => Navigator.of(context).pushNamed(BoardScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.shows,
          subtitle: 'Entries, start lists and results',
          onTap: () => Navigator.of(context).pushNamed(ShowsScreen.route),
        ),
        const Hairline(),
        const SizedBox(height: 30),
        Text(l10n.language.toUpperCase(), style: AppText.eyebrow()),
        const SizedBox(height: 12),
        HairlineList(
          children: [
            for (final (code, name) in languages)
              InkWell(
                onTap: () => controller.setLocale(Locale(code)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: AppText.heading(19,
                                weight: code == current
                                    ? FontWeight.w600
                                    : FontWeight.w500)),
                      ),
                      if (code == 'ar' || code == 'ur') ...[
                        const AppTag('RTL', tone: TagTone.neutral),
                        const SizedBox(width: 12),
                      ],
                      if (code == current)
                        const Icon(Icons.check,
                            color: AppColors.accent2600, size: 22),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Shown on Home when the person has asked to join a stable but isn't approved
/// yet. Persists every visit until an admin lets them in.
class _PendingPanel extends StatefulWidget {
  const _PendingPanel({required this.session});
  final AppSession session;

  @override
  State<_PendingPanel> createState() => _PendingPanelState();
}

class _PendingPanelState extends State<_PendingPanel> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    await widget.session.refresh();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.session.pendingRequests;
    final names = pending
        .map((p) => (p['stable_name'] as String?) ?? 'a stable')
        .toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.accent200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Waiting for approval',
                  style: AppText.heading(22, color: AppColors.accent900)),
              const SizedBox(height: 8),
              Text(
                names.length == 1
                    ? 'You asked to join ${names.first}. An owner or manager '
                        'needs to approve you — it will open up here the moment '
                        'they do.'
                    : 'You asked to join: ${names.join(", ")}. An owner or '
                        'manager needs to approve you.',
                style: AppText.body(16,
                    height: 1.5, color: AppColors.accent900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (_checking)
          const Center(child: CircularProgressIndicator())
        else
          GestureDetector(
            onTap: _check,
            child: Text('Check again',
                style: AppText.heading(17, color: AppColors.accent700)),
          ),
        const SizedBox(height: 22),
        const Hairline(),
        const SizedBox(height: 22),
        Text('Or start your own',
            style: AppText.heading(18, height: 1.2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await Navigator.of(context).pushNamed(CreateStableScreen.route);
            _check();
          },
          child: Text('Create my own stable',
              style: AppText.body(16, color: AppColors.accent700)),
        ),
      ],
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: AppText.body(16, color: AppColors.accent700)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text("Couldn't reach the stable",
            style: AppText.heading(23, height: 1.1)),
        const SizedBox(height: 8),
        Text(
          message ?? 'Check your connection and try again.',
          style: AppText.body(15, color: AppColors.ink(0.6)),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => onRetry(),
          child: Text('Try again',
              style: AppText.heading(17, color: AppColors.accent700)),
        ),
      ],
    );
  }
}

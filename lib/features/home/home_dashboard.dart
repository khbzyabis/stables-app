import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/bottom_tab_bar.dart';
import '../../widgets/photo_placeholder.dart';
import '../horses/add_horse_screen.dart';
import '../horses/horse_record_screen.dart';
import '../board/post_notice_screen.dart';
import '../schedule/schedule_screen.dart';
import '../tasks/assign_task_screen.dart';
import '../tasks/groom_day_screen.dart';

/// The signed-in Home as a proper web dashboard (desktop only): summary tiles
/// across the top, then a two-column layout — a "to do today" list and the
/// horse grid on the left, the board, quick actions and the next show on the
/// right. Wired to the same data the mobile home uses. Phones keep the native
/// single-column home; this widget is never shown there.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({
    super.key,
    required this.stableId,
    required this.onGoTab,
  });

  final String? stableId;
  final ValueChanged<AppTab> onGoTab;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late Future<_DashData> _future = _load();

  Future<_DashData> _load() async {
    final id = widget.stableId;
    if (id == null) return const _DashData();
    Future<List<Map<String, dynamic>>> safe(
            Future<List<Map<String, dynamic>>> f) =>
        f.catchError((_) => <Map<String, dynamic>>[]);
    final results = await Future.wait([
      safe(SupabaseService.tasks(id)),
      safe(SupabaseService.horses(id)),
      safe(SupabaseService.notices(id)),
      safe(SupabaseService.publishedShows()),
    ]);
    return _DashData(
      tasks: results[0],
      horses: results[1],
      notices: results[2],
      shows: results[3],
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashData>(
      future: _future,
      builder: (context, snap) {
        final d = snap.data ?? const _DashData();
        final loading = snap.connectionState == ConnectionState.waiting;
        final openTasks = d.tasks.where((t) => t['done'] != true).toList();
        final wellCount =
            d.horses.where((h) => (h['status'] as String?) != 'watch').length;
        final watchCount = d.horses.length - wellCount;
        final nextShow = d.shows.isNotEmpty ? d.shows.first : null;

        return ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            // Stat tiles.
            _StatRow(
              tiles: [
                _StatTile(
                  tone: _Tone.terra,
                  iconBuilder: (c, s) => AppTabIcon.horses(color: c, size: s),
                  label: 'Horses',
                  value: '${d.horses.length}',
                  meta: watchCount > 0
                      ? '$watchCount to watch · $wellCount well'
                      : 'all well',
                  onTap: () => widget.onGoTab(AppTab.horses),
                ),
                _StatTile(
                  tone: _Tone.amber,
                  icon: Icons.task_alt,
                  label: 'Tasks today',
                  value: '${openTasks.length}',
                  meta: 'open',
                  onTap: () => Navigator.of(context)
                      .pushNamed(GroomDayScreen.route)
                      .then((_) => _reload()),
                ),
                _StatTile(
                  tone: _Tone.sage,
                  icon: Icons.dashboard_outlined,
                  label: 'Board',
                  value: '${d.notices.length}',
                  meta: 'notices',
                  onTap: () => widget.onGoTab(AppTab.board),
                ),
                _StatTile(
                  tone: _Tone.terra,
                  icon: Icons.emoji_events_outlined,
                  label: 'Next show',
                  value: nextShow == null
                      ? '—'
                      : _showWhen(nextShow['starts_on'] as String?),
                  meta: nextShow == null
                      ? 'none listed'
                      : ((nextShow['city'] as String?)?.trim().isNotEmpty == true
                          ? nextShow['city'] as String
                          : 'view details'),
                  valueSize: 22,
                  onTap: () => widget.onGoTab(AppTab.market),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Two-column dashboard.
            LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 760;
                final left = _leftColumn(openTasks, d.horses, loading);
                final right = _rightColumn(d.notices, nextShow, loading);
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [left, const SizedBox(height: 20), right],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 16, child: left),
                    const SizedBox(width: 20),
                    Expanded(flex: 10, child: right),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _leftColumn(
      List<Map<String, dynamic>> openTasks,
      List<Map<String, dynamic>> horses,
      bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          title: 'To do today',
          actionLabel: 'Full schedule →',
          onAction: () => Navigator.of(context)
              .pushNamed(ScheduleScreen.route)
              .then((_) => _reload()),
          child: openTasks.isEmpty
              ? _Empty(loading
                  ? 'Loading…'
                  : 'Nothing outstanding. Assign a task to get started.')
              : Column(
                  children: [
                    for (var i = 0; i < openTasks.length && i < 6; i++)
                      _TaskRow(task: openTasks[i], first: i == 0),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        _Panel(
          title: 'Your horses',
          actionLabel: horses.isEmpty ? null : 'All ${horses.length} →',
          onAction: () => widget.onGoTab(AppTab.horses),
          child: horses.isEmpty
              ? _Empty(loading ? 'Loading…' : 'No horses yet. Add your first.')
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final h in horses.take(6))
                      SizedBox(
                        width: 236,
                        child: _HorseChip(
                          horse: h,
                          onTap: () => Navigator.of(context)
                              .pushNamed(HorseRecordScreen.route, arguments: h)
                              .then((_) => _reload()),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _rightColumn(List<Map<String, dynamic>> notices,
      Map<String, dynamic>? nextShow, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          title: 'Board',
          actionLabel: 'Open →',
          onAction: () => widget.onGoTab(AppTab.board),
          child: notices.isEmpty
              ? _Empty(loading ? 'Loading…' : 'No notices yet.')
              : Column(
                  children: [
                    for (var i = 0; i < notices.length && i < 3; i++)
                      _NoticeRow(notice: notices[i], first: i == 0),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        _Panel(
          title: 'Quick actions',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Action(
                icon: Icons.add,
                label: 'Add a horse',
                onTap: () => Navigator.of(context)
                    .pushNamed(AddHorseScreen.route)
                    .then((_) => _reload()),
              ),
              _Action(
                icon: Icons.task_alt,
                label: 'Assign task',
                onTap: () => Navigator.of(context)
                    .pushNamed(AssignTaskScreen.route)
                    .then((_) => _reload()),
              ),
              _Action(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule',
                onTap: () => Navigator.of(context).pushNamed(ScheduleScreen.route),
              ),
              _Action(
                icon: Icons.post_add_outlined,
                label: 'Post notice',
                onTap: () => Navigator.of(context)
                    .pushNamed(PostNoticeScreen.route)
                    .then((_) => _reload()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _NextShow(show: nextShow, onTap: () => widget.onGoTab(AppTab.market)),
      ],
    );
  }
}

String _showWhen(String? iso) {
  if (iso == null) return 'soon';
  final d = DateTime.tryParse(iso);
  if (d == null) return 'soon';
  return DateFormat('MMM d').format(d);
}

class _DashData {
  const _DashData({
    this.tasks = const [],
    this.horses = const [],
    this.notices = const [],
    this.shows = const [],
  });
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> horses;
  final List<Map<String, dynamic>> notices;
  final List<Map<String, dynamic>> shows;
}

enum _Tone { terra, sage, amber }

Color _toneBg(_Tone t) => switch (t) {
      _Tone.terra => AppColors.accent100,
      _Tone.sage => AppColors.accent2200,
      _Tone.amber => const Color(0xFFF4E7C8),
    };
Color _toneFg(_Tone t) => switch (t) {
      _Tone.terra => AppColors.accent700,
      _Tone.sage => AppColors.accent2700,
      _Tone.amber => const Color(0xFF9A6A1F),
    };

// ---- Building blocks --------------------------------------------------------

class _StatRow extends StatelessWidget {
  const _StatRow({required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 560 ? 2 : 4;
        const gap = 16.0;
        final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles) SizedBox(width: cellW, child: t),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.tone,
    required this.label,
    required this.value,
    required this.meta,
    required this.onTap,
    this.icon,
    this.iconBuilder,
    this.valueSize = 32,
  }) : assert(icon != null || iconBuilder != null);
  final _Tone tone;
  final IconData? icon;
  final Widget Function(Color color, double size)? iconBuilder;
  final String label;
  final String value;
  final String meta;
  final VoidCallback onTap;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warmWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _toneBg(tone),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: icon != null
                        ? Icon(icon, size: 17, color: _toneFg(tone))
                        : iconBuilder!(_toneFg(tone), 17),
                  ),
                  const SizedBox(width: 9),
                  Text(label,
                      style: AppText.body(13,
                          weight: FontWeight.w600, color: AppColors.ink(0.6))),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: AppText.heading(valueSize, height: 1)),
              const SizedBox(height: 6),
              Text(meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12.5, color: AppColors.ink(0.55))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: AppText.heading(17, height: 1))),
                if (actionLabel != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(actionLabel!,
                        style: AppText.body(13,
                            weight: FontWeight.w600,
                            color: AppColors.accent700)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: AppText.body(14, color: AppColors.ink(0.55))),
      );
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.first});
  final Map<String, dynamic> task;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final who = (task['assignee'] as String?)?.trim();
    final due = (task['due'] as String?)?.trim();
    final sub = [
      if (who != null && who.isNotEmpty) who,
      if (due != null && due.isNotEmpty) due,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: first
            ? null
            : Border(top: BorderSide(color: AppColors.text.withValues(alpha: 0.07))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((task['title'] as String?) ?? 'Task',
                    style: AppText.body(15, weight: FontWeight.w600)),
                if (sub.isNotEmpty)
                  Text(sub,
                      style: AppText.body(13, color: AppColors.ink(0.55))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorseChip extends StatelessWidget {
  const _HorseChip({required this.horse, required this.onTap});
  final Map<String, dynamic> horse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final well = (horse['status'] as String?) != 'watch';
    final box = (horse['box'] as String?)?.trim();
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: PhotoPlaceholder(url: horse['photo_url'] as String?),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((horse['name'] as String?) ?? 'Horse',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.heading(15, height: 1.1)),
                    if (box != null && box.isNotEmpty)
                      Text('Box $box',
                          style:
                              AppText.body(12.5, color: AppColors.ink(0.55))),
                    const SizedBox(height: 4),
                    _StatusPill(well: well),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.well});
  final bool well;
  @override
  Widget build(BuildContext context) {
    final bg = well ? AppColors.accent2200 : const Color(0xFFF4E7C8);
    final fg = well ? AppColors.accent2700 : const Color(0xFF9A6A1F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(well ? 'Well' : 'Watch',
          style: AppText.body(11.5, weight: FontWeight.w600, color: fg)),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.notice, required this.first});
  final Map<String, dynamic> notice;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final author = (notice['author_name'] as String?) ?? 'Someone';
    final initial =
        author.characters.isEmpty ? '·' : author.characters.first.toUpperCase();
    final body = (notice['body'] as String?) ?? '';
    final pinned = notice['pinned'] == true;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: first
            ? null
            : Border(top: BorderSide(color: AppColors.text.withValues(alpha: 0.07))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: AppColors.accent2200, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial,
                style: AppText.heading(13, color: AppColors.accent2700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author,
                    style: AppText.body(13.5, weight: FontWeight.w600)),
                if (body.isNotEmpty)
                  Text(body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(13.5, color: AppColors.ink(0.7))),
              ],
            ),
          ),
          if (pinned) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.accent100,
                  borderRadius: BorderRadius.circular(6)),
              child: Text('Pinned',
                  style: AppText.body(10.5,
                      weight: FontWeight.w700, color: AppColors.accent700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Material(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.accent700),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(14, weight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextShow extends StatelessWidget {
  const _NextShow({required this.show, required this.onTap});
  final Map<String, dynamic>? show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (show?['title'] as String?) ?? 'No show listed yet';
    final when = show == null ? null : _showWhen(show!['starts_on'] as String?);
    final city = (show?['city'] as String?)?.trim();
    final sub = show == null
        ? 'Operator-listed shows appear here.'
        : [?when, if (city != null && city.isNotEmpty) city].join(' · ');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E2B25), Color(0xFF403A30)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NEXT SHOW',
                style: AppText.body(11,
                    weight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFFD6A876))),
            const SizedBox(height: 6),
            Text(title,
                style: AppText.heading(19, color: Colors.white, height: 1.1)),
            const SizedBox(height: 4),
            Text(sub,
                style: AppText.body(13, color: const Color(0xFFC9C0B1))),
            const SizedBox(height: 12),
            Text('View →',
                style: AppText.body(13.5,
                    weight: FontWeight.w600, color: const Color(0xFFF3ECDF))),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_tag.dart';
import '../auth/back_link.dart';
import 'add_activity_screen.dart';

/// Screen 16 — Schedule (this week). Everything the stable does, saved to the
/// database. A live week strip, kind filters, and the day's agenda.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  static const route = '/schedule';

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selected = _dateOnly(DateTime.now());
  EventKind? _filter;
  late Future<List<Map<String, dynamic>>> _future = _load();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _iso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.activities(id);
  }

  void _reload() => setState(() => _future = _load());

  EventKind _kindOf(String? name) => EventKind.values.firstWhere(
    (e) => e.name == name,
    orElse: () => EventKind.riding,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final monday = _selected.subtract(Duration(days: _selected.weekday - 1));
    final week = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final all = snap.data ?? const [];
            // Count per day for the strip dots, and the selected day's agenda.
            final loadByIso = <String, int>{};
            for (final a in all) {
              final iso = a['on_date'] as String? ?? '';
              loadByIso[iso] = (loadByIso[iso] ?? 0) + 1;
            }
            final selectedIso = _iso(_selected);
            final agenda = all.where((a) {
              if (a['on_date'] != selectedIso) return false;
              if (_filter == null) return true;
              return _kindOf(a['kind'] as String?) == _filter;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BackLink(label: 'Stable'),
                      const SizedBox(height: 14),
                      Text(
                        '${SessionScope.of(context).activeStableName} · ${DateFormat('MMMM').format(_selected)}'
                            .toUpperCase(),
                        style: AppText.eyebrow(color: AppColors.accent700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE').format(_selected),
                        style: AppText.heading(40, height: 1),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          for (final d in week) ...[
                            Expanded(
                              child: _DayButton(
                                date: d,
                                selected: _dateOnly(d) == _selected,
                                load: loadByIso[_iso(d)] ?? 0,
                                onTap: () =>
                                    setState(() => _selected = _dateOnly(d)),
                              ),
                            ),
                            if (d != week.last) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                      const SizedBox(height: 26),
                      _FilterRow(
                        selected: _filter,
                        allLabel: l10n.filterAll,
                        onPick: (k) => setState(() => _filter = k),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: snap.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(32, 26, 32, 0),
                          children: [
                            for (final e in agenda) ...[
                              _AgendaRow(activity: e, kind: _kindOf(e['kind'])),
                              const SizedBox(height: 10),
                            ],
                            if (agenda.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 26),
                                child: Text(
                                  l10n.quietStable,
                                  style: AppText.body(
                                    16,
                                    height: 1.5,
                                    color: AppColors.ink(0.55),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 30),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: AppButton(
                    label: l10n.addToSchedule,
                    minHeight: 56,
                    fontSize: 17,
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(AddActivityScreen.route);
                      _reload();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.date,
    required this.selected,
    required this.load,
    required this.onTap,
  });
  final DateTime date;
  final bool selected;
  final int load;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.bg : AppColors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('E').format(date).substring(0, 2).toUpperCase(),
              style: AppText.body(
                11,
                color: fg.withValues(alpha: 0.7),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            Text('${date.day}', style: AppText.heading(19, color: fg)),
            const SizedBox(height: 5),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < load.clamp(0, 3); i++) ...[
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.bg.withValues(alpha: 0.8)
                            : AppColors.accent2600,
                      ),
                    ),
                    if (i != load.clamp(0, 3) - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.allLabel,
    required this.onPick,
  });
  final EventKind? selected;
  final String allLabel;
  final ValueChanged<EventKind?> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(allLabel, selected == null, () => onPick(null)),
          for (final k in EventKind.values) ...[
            const SizedBox(width: 8),
            _chip(k.label, selected == k, () => onPick(k)),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppText.body(
            14,
            color: active ? AppColors.bg : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.activity, required this.kind});
  final Map<String, dynamic> activity;
  final EventKind kind;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if ((activity['who'] as String?)?.isNotEmpty == true)
        activity['who'] as String,
      if ((activity['note'] as String?)?.isNotEmpty == true)
        activity['note'] as String,
    ].join(' · ');
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['at_time'] as String?) ?? '',
                  style: AppText.heading(18, height: 1.1),
                ),
                if ((activity['duration'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    activity['duration'] as String,
                    style: AppText.body(13, color: AppColors.ink(0.45)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: kind.hue, width: 2),
                ),
              ),
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (activity['title'] as String?) ?? kind.label,
                    style: AppText.heading(20, height: 1.2),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: AppText.body(15, color: AppColors.ink(0.6)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppTag(kind.label, tone: kind.tone),
        ],
      ),
    );
  }
}

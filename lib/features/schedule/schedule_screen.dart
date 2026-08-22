import 'package:flutter/material.dart';

import '../../data/schedule_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import 'add_activity_screen.dart';
import 'month_screen.dart';

const _weekdayNames = {
  17: 'Monday', 18: 'Tuesday', 19: 'Wednesday', 20: 'Thursday',
  21: 'Friday', 22: 'Saturday', 23: 'Sunday',
};

/// Screen 16 — Schedule (week). Everything the stable does appears here.
/// A week strip, day-load dots, kind filters, and the day's agenda with
/// hue-coded left borders.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  static const route = '/schedule';

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 18;
  EventKind? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final all = ScheduleData.events[_selectedDay] ?? const [];
    final agenda =
        _filter == null ? all : all.where((e) => e.kind == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Serc · August',
                                style: AppText.eyebrow(color: AppColors.accent700)),
                            const SizedBox(height: 10),
                            Text(_weekdayNames[_selectedDay] ?? '',
                                style: AppText.heading(40, height: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(MonthScreen.route),
                        child: Text(l10n.monthView,
                            style: AppText.body(15, color: AppColors.accent700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _WeekStrip(
                    selected: _selectedDay,
                    onPick: (d) => setState(() => _selectedDay = d),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(32, 30, 32, 0),
                children: [
                  const Hairline(),
                  for (final e in agenda) ...[
                    _AgendaRow(event: e),
                    const Hairline(),
                  ],
                  if (agenda.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(l10n.quietStable,
                            style: AppText.body(16,
                                height: 1.5, color: AppColors.ink(0.55))),
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
                onPressed: () =>
                    Navigator.of(context).pushNamed(AddActivityScreen.route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.onPick});
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in ScheduleData.week) ...[
          Expanded(
            child: _DayButton(
              day: d,
              selected: d.num == selected,
              onTap: () => onPick(d.num),
            ),
          ),
          if (d.num != ScheduleData.week.last.num) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton(
      {required this.day, required this.selected, required this.onTap});
  final ScheduleDay day;
  final bool selected;
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
            Text(day.dow.toUpperCase(),
                style: AppText.body(11,
                    color: fg.withValues(alpha: 0.7), letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text('${day.num}', style: AppText.heading(19, color: fg)),
            const SizedBox(height: 5),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < day.load; i++) ...[
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
                    if (i != day.load - 1) const SizedBox(width: 2),
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
  const _FilterRow(
      {required this.selected, required this.allLabel, required this.onPick});
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: active ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(13,
                color: active ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.event});
  final ScheduleEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.time, style: AppText.heading(18, height: 1.1)),
                const SizedBox(height: 3),
                Text(event.duration,
                    style: AppText.body(13, color: AppColors.ink(0.45))),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: event.kind.hue, width: 2),
                ),
              ),
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppText.heading(20, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(event.meta,
                      style: AppText.body(15, color: AppColors.ink(0.6))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppTag(event.kind.label, tone: event.kind.tone),
        ],
      ),
    );
  }
}

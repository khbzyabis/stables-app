import 'package:flutter/material.dart';

import '../../data/schedule_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 17 — Month. Dots mark what is booked; tap a date to see its agenda.
class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});
  static const route = '/schedule/month';

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  int _selected = 20;

  // August 2026 starts on a Saturday. Week begins Monday, so 5 leading blanks.
  static const _leadingBlanks = 5;
  static const _daysInMonth = 31;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final agenda = ScheduleData.events[_selected] ?? const [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
          children: [
            BackLink(label: l10n.weekView),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('August', style: AppText.heading(40, height: 1)),
                const Spacer(),
                Text('2026', style: AppText.body(16, color: AppColors.ink(0.5))),
              ],
            ),
            const SizedBox(height: 26),
            _dowHeader(),
            const SizedBox(height: 10),
            _grid(),
            const SizedBox(height: 34),
            Text(
              'August $_selected'.toUpperCase(),
              style: AppText.eyebrow(),
            ),
            const SizedBox(height: 14),
            const Hairline(),
            for (final e in agenda) ...[
              _monthRow(e),
              const Hairline(),
            ],
            if (agenda.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(l10n.nothingBooked,
                    style: AppText.body(16, color: AppColors.ink(0.55))),
              ),
            const SizedBox(height: 34),
            _legend(),
          ],
        ),
      ),
    );
  }

  Widget _dowHeader() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Text(l.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppText.body(11,
                    color: AppColors.ink(0.45), letterSpacing: 0.6)),
          ),
      ],
    );
  }

  Widget _grid() {
    final cells = <Widget>[];
    for (var i = 0; i < _leadingBlanks; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= _daysInMonth; d++) {
      final hasEvents = (ScheduleData.events[d]?.isNotEmpty) ?? false;
      cells.add(_DateCell(
        num: d,
        selected: d == _selected,
        booked: hasEvents,
        onTap: () => setState(() => _selected = d),
      ));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 0.95,
      children: cells,
    );
  }

  Widget _monthRow(ScheduleEvent e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 58,
              child: Text(e.time, style: AppText.heading(17, height: 1.1))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: AppText.body(17, height: 1.3)),
                const SizedBox(height: 3),
                Text(e.meta,
                    style: AppText.body(14, color: AppColors.ink(0.55))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 9,
            height: 9,
            decoration: BoxDecoration(shape: BoxShape.circle, color: e.kind.hue),
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 20,
      runSpacing: 14,
      children: [
        for (final k in EventKind.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: k.hue),
              ),
              const SizedBox(width: 8),
              Text(k.label,
                  style: AppText.body(14, color: AppColors.ink(0.7))),
            ],
          ),
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.num,
    required this.selected,
    required this.booked,
    required this.onTap,
  });
  final int num;
  final bool selected;
  final bool booked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.bg : AppColors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$num', style: AppText.body(15, color: fg)),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: booked
                    ? (selected ? AppColors.bg : AppColors.accent2600)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


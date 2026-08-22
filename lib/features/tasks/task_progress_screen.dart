import 'package:flutter/material.dart';

import '../../data/tasks_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import 'assign_task_screen.dart';

/// Screen 31 — Task progress (admin). Who has done what, and what is still open.
class TaskProgressScreen extends StatelessWidget {
  const TaskProgressScreen({super.key});
  static const route = '/tasks/progress';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Serc · Tuesday',
                          style: AppText.eyebrow(color: AppColors.accent700)),
                      const SizedBox(height: 10),
                      Text(l10n.tasksToday, style: AppText.heading(40, height: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AssignTaskScreen.route),
                  child: Text(l10n.assign,
                      style: AppText.body(15, color: AppColors.accent700)),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Hairline(),
            for (final p in TasksData.staff) ...[
              _StaffCard(progress: p),
              const Hairline(),
            ],
            const SizedBox(height: 32),
            Text(l10n.stillOpen.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 4),
            const Hairline(),
            _OpenRow(
              title: "Poultice Comme Ci's left fore",
              meta: 'Rasil · due 10:00',
              tag: l10n.statusLate,
              tone: TagTone.accent,
            ),
            const Hairline(),
            _OpenRow(
              title: 'Sweep the tack room',
              meta: 'Layal · by end of day',
              tag: l10n.statusOpen,
              tone: TagTone.neutral,
            ),
            const Hairline(),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.progress});
  final StaffProgress progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.accent2300,
                  shape: BoxShape.circle,
                ),
                child: Text(progress.initial,
                    style: AppText.heading(16, color: AppColors.accent2900)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(progress.name, style: AppText.heading(18, height: 1.2)),
                    const SizedBox(height: 3),
                    Text(progress.role,
                        style: AppText.body(14, color: AppColors.ink(0.55))),
                  ],
                ),
              ),
              AppTag('${progress.done} of ${progress.total}',
                  tone: progress.allDone ? TagTone.sage : TagTone.accent),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              height: 6,
              color: AppColors.neutral200,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: progress.fraction,
                child: Container(
                    color: progress.allDone
                        ? AppColors.accent2600
                        : AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(progress.latest,
              style: AppText.body(14, color: AppColors.ink(0.55))),
        ],
      ),
    );
  }
}

class _OpenRow extends StatelessWidget {
  const _OpenRow({
    required this.title,
    required this.meta,
    required this.tag,
    required this.tone,
  });
  final String title;
  final String meta;
  final String tag;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(17, height: 1.25)),
                const SizedBox(height: 3),
                Text(meta, style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppTag(tag, tone: tone),
        ],
      ),
    );
  }
}

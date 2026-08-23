import 'package:flutter/material.dart';

import '../../data/tasks_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import 'kit_screen.dart';

/// Screen 29 — Groom's day. The day's tasks; tick them done. Ticks work
/// offline (held locally and synced when signal returns) and, when online,
/// are visible to admins straight away.
class GroomDayScreen extends StatefulWidget {
  const GroomDayScreen({super.key});
  static const route = '/tasks';

  @override
  State<GroomDayScreen> createState() => _GroomDayScreenState();
}

class _GroomDayScreenState extends State<GroomDayScreen> {
  final Set<String> _done = {...TasksData.initiallyDone};

  void _toggle(String id) => setState(() {
        _done.contains(id) ? _done.remove(id) : _done.add(id);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final tasks = TasksData.groomDay;
    final doneCount = tasks.where((t) => _done.contains(t.id)).length;
    final fraction = tasks.isEmpty ? 0.0 : doneCount / tasks.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
          children: [
            Text('Rasil · Groom · Tuesday',
                style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 10),
            Text(l10n.yourTasks, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text(
              l10n.taskProgress(doneCount, tasks.length, tasks.length - doneCount),
              style: AppText.body(17, color: AppColors.ink(0.65)),
            ),
            const SizedBox(height: 22),
            _ProgressBar(fraction: fraction),
            const SizedBox(height: 30),
            const Hairline(),
            for (final t in tasks) ...[
              _TaskRow(
                task: t,
                done: _done.contains(t.id),
                onToggle: () => _toggle(t.id),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(KitScreen.route),
              child: Text("See today's kit for Kiki",
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const SizedBox(height: 16),
            Text(l10n.ticksVisible,
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 6,
        color: AppColors.neutral200,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: AppColors.accent2600),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow(
      {required this.task, required this.done, required this.onToggle});
  final StableTask task;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Checkbox(done: done, onTap: onToggle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppText.body(17, height: 1.25).copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.ink(0.45) : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(task.meta,
                    style: AppText.body(14, height: 1.4, color: AppColors.ink(0.55))),
                if (task.hasNote) ...[
                  const SizedBox(height: 6),
                  Text(task.note,
                      style: AppText.body(14, color: AppColors.accent700)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(task.time,
                style: AppText.body(14, color: AppColors.ink(0.45))),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.done, required this.onTap});
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? AppColors.accent2600 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: done ? AppColors.accent2600 : AppColors.ink(0.35),
            width: 1.5,
          ),
        ),
        child: done
            ? const Icon(Icons.check, size: 17, color: AppColors.bg)
            : null,
      ),
    );
  }
}

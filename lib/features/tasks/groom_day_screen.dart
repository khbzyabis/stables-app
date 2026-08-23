import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'assign_task_screen.dart';

/// Screen 29 — the stable's tasks. Tick one done and it saves for everyone;
/// anyone can add a task. Ticks persist to the database immediately.
class GroomDayScreen extends StatefulWidget {
  const GroomDayScreen({super.key});
  static const route = '/tasks';

  @override
  State<GroomDayScreen> createState() => _GroomDayScreenState();
}

class _GroomDayScreenState extends State<GroomDayScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();
  final _pending = <String>{}; // ids mid-toggle

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.tasks(id);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _toggle(Map<String, dynamic> task) async {
    final id = task['id'] as String;
    final next = !(task['done'] == true);
    setState(() {
      task['done'] = next; // optimistic
      _pending.add(id);
    });
    try {
      await SupabaseService.setTaskDone(id, next);
    } catch (e) {
      setState(() => task['done'] = !next); // revert
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _pending.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = SessionScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final tasks = snap.data ?? const [];
            final doneCount = tasks.where((t) => t['done'] == true).length;
            final fraction = tasks.isEmpty ? 0.0 : doneCount / tasks.length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
              children: [
                const BackLink(label: 'Stable'),
                const SizedBox(height: 14),
                Text(session.activeStableName.toUpperCase(),
                    style: AppText.eyebrow(color: AppColors.accent700)),
                const SizedBox(height: 10),
                Text(l10n.yourTasks, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 10),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Text(
                    l10n.taskProgress(
                        doneCount, tasks.length, tasks.length - doneCount),
                    style: AppText.body(17, color: AppColors.ink(0.65)),
                  ),
                  const SizedBox(height: 22),
                  _ProgressBar(fraction: fraction),
                  const SizedBox(height: 30),
                  const Hairline(),
                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No tasks yet. Add one below — whoever it is for can tick it off, and everyone sees it update.',
                        style: AppText.body(16,
                            height: 1.5, color: AppColors.ink(0.6)),
                      ),
                    ),
                  for (final t in tasks) ...[
                    _TaskRow(
                      task: t,
                      busy: _pending.contains(t['id']),
                      onToggle: () => _toggle(t),
                    ),
                    const Hairline(),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed(AssignTaskScreen.route);
                      _reload();
                    },
                    child: Text('+ ${l10n.newTask}',
                        style:
                            AppText.heading(17, color: AppColors.accent700)),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.ticksVisible,
                      style: AppText.body(15,
                          height: 1.5, color: AppColors.ink(0.55))),
                ],
              ],
            );
          },
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
      {required this.task, required this.busy, required this.onToggle});
  final Map<String, dynamic> task;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final done = task['done'] == true;
    final meta = <String>[
      if ((task['assignee'] as String?)?.isNotEmpty == true)
        task['assignee'] as String,
      if ((task['due'] as String?)?.isNotEmpty == true) task['due'] as String,
    ].join(' · ');
    final note = task['note'] as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Checkbox(done: done, onTap: busy ? () {} : onToggle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (task['title'] as String?) ?? '',
                  style: AppText.body(17, height: 1.25).copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.ink(0.45) : AppColors.text,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(meta,
                      style: AppText.body(14,
                          height: 1.4, color: AppColors.ink(0.55))),
                ],
                if (note != null && note.isNotEmpty && !done) ...[
                  const SizedBox(height: 6),
                  Text(note,
                      style: AppText.body(14, color: AppColors.accent700)),
                ],
              ],
            ),
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
        child:
            done ? const Icon(Icons.check, size: 17, color: AppColors.bg) : null,
      ),
    );
  }
}

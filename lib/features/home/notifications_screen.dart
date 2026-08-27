import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_card.dart';
import '../auth/back_link.dart';
import '../tasks/groom_day_screen.dart';

/// What the bell opens — the tasks assigned to you, so a groom, trainer or any
/// member sees their own to-do at a glance.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const route = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.myOpenTasks(id);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 40),
          children: [
            const BackLink(label: 'Home'),
            const SizedBox(height: 18),
            Text('For you', style: AppText.heading(34, height: 1)),
            const SizedBox(height: 8),
            Text('Tasks assigned to you across the stable.',
                style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 22),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final tasks = snap.data ?? const [];
                if (tasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 40, color: AppColors.accent2600),
                        const SizedBox(height: 14),
                        Text("You're all caught up",
                            style: AppText.heading(20)),
                        const SizedBox(height: 6),
                        Text('Nothing is assigned to you right now.',
                            textAlign: TextAlign.center,
                            style:
                                AppText.body(15, color: AppColors.ink(0.55))),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final t in tasks) ...[
                      _TaskAlert(task: t, onOpen: _openTasks),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTasks() async {
    await Navigator.of(context).pushNamed(GroomDayScreen.route);
    _reload();
  }
}

class _TaskAlert extends StatelessWidget {
  const _TaskAlert({required this.task, required this.onOpen});
  final Map<String, dynamic> task;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final due = (task['due'] as String?)?.trim();
    final note = (task['note'] as String?)?.trim();
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFE1EECC),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.task_alt, size: 20, color: AppColors.accent2700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((task['title'] as String?) ?? 'Task',
                    style: AppText.heading(16, height: 1.2)),
                if (due != null && due.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(due,
                      style: AppText.body(13, color: AppColors.accent700)),
                ],
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(note,
                      style: AppText.body(13, color: AppColors.ink(0.55)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
        ],
      ),
    );
  }
}

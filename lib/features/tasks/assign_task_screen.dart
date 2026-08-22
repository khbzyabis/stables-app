import 'package:flutter/material.dart';

import '../../data/stable_store.dart';
import '../../data/tasks_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../auth/back_link.dart';

/// Screen 30 — Assign a task (admin/trainer). What needs doing, who, which
/// horse, by when, repeat, and a note.
class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});
  static const route = '/tasks/assign';

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _what = TextEditingController();
  final _by = TextEditingController(text: '10:00');
  final _repeat = TextEditingController(text: 'Daily');
  final _note = TextEditingController();
  String? _who;
  String? _horse;

  @override
  void dispose() {
    _what.dispose();
    _by.dispose();
    _repeat.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final horses = StableScope.of(context).horses;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
          children: [
            BackLink(label: l10n.cancel),
            const SizedBox(height: 24),
            Text(l10n.newTask, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 30),
            AppField(
              label: l10n.whatNeedsDoing,
              controller: _what,
              hintText: "Poultice Comme Ci's left fore",
            ),
            const SizedBox(height: 30),
            Text(l10n.who.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 12),
            _Chips(
              labels: TasksData.assignees,
              selected: _who,
              onPick: (v) => setState(() => _who = v),
            ),
            const SizedBox(height: 30),
            Text(l10n.whichHorse.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 12),
            _Chips(
              labels: [for (final h in horses) h.name],
              selected: _horse,
              onPick: (v) => setState(() => _horse = v),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppField(label: l10n.byTime, controller: _by)),
                const SizedBox(width: 14),
                Expanded(child: AppField(label: l10n.repeats, controller: _repeat)),
              ],
            ),
            const SizedBox(height: 26),
            AppField(
              label: l10n.noteForThem,
              controller: _note,
              hintText: l10n.optional,
            ),
            const SizedBox(height: 36),
            AppButton(
              label: l10n.assign,
              minHeight: 56,
              fontSize: 17,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips(
      {required this.labels, required this.selected, required this.onPick});
  final List<String> labels;
  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in labels)
          GestureDetector(
            onTap: () => onPick(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: label == selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                    color: label == selected
                        ? AppColors.accent
                        : AppColors.divider),
              ),
              child: Text(label,
                  style: AppText.body(16,
                      color: label == selected ? AppColors.bg : AppColors.text)),
            ),
          ),
      ],
    );
  }
}

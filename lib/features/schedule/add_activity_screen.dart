import 'package:flutter/material.dart';

import '../../data/stable_store.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../auth/back_link.dart';

/// Screen 18 — Add activity. Activity first, then which horse, time, repeat and
/// an optional note. Two taps to save.
class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});
  static const route = '/schedule/add';

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  EventKind _kind = EventKind.riding;
  String? _horse;
  int _repeat = 0;
  final _starts = TextEditingController(text: '17:00');
  final _forDur = TextEditingController(text: '45 min');
  final _note = TextEditingController();

  @override
  void dispose() {
    _starts.dispose();
    _forDur.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final horses = StableScope.of(context).horses;
    final repeats = [
      l10n.repeatOnce,
      l10n.repeatDaily,
      l10n.repeatWeekly,
      l10n.repeatWeekdays,
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
          children: [
            BackLink(label: l10n.cancel),
            const SizedBox(height: 24),
            Text(l10n.whatIsHappening, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final k in EventKind.values)
                  _Chip(
                    label: k.label,
                    selected: k == _kind,
                    onTap: () => setState(() => _kind = k),
                  ),
              ],
            ),
            const SizedBox(height: 36),
            Text(l10n.whichHorse.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in horses)
                  _Chip(
                    label: h.name,
                    selected: h.name == _horse,
                    onTap: () => setState(() => _horse = h.name),
                  ),
              ],
            ),
            const SizedBox(height: 34),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppField(label: l10n.starts, controller: _starts)),
                const SizedBox(width: 14),
                Expanded(child: AppField(label: l10n.forDuration, controller: _forDur)),
              ],
            ),
            const SizedBox(height: 30),
            Text(l10n.repeats.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < repeats.length; i++)
                  _Chip(
                    label: repeats[i],
                    selected: i == _repeat,
                    onTap: () => setState(() => _repeat = i),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            AppField(
              label: l10n.noteIfAny,
              controller: _note,
              hintText: l10n.optional,
            ),
            const SizedBox(height: 36),
            AppButton(
              label: l10n.addToSchedule,
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

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(16,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

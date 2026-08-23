import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../auth/back_link.dart';

/// Screen 19 — edit or delete a scheduled activity. Delete asks once, and only
/// removes this occurrence — the weekly repeat stays.
class EditActivityScreen extends StatefulWidget {
  const EditActivityScreen({super.key});
  static const route = '/edit-activity';

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  static const _kinds = [
    'Lesson',
    'Farrier',
    'Vet',
    'Turnout',
    'Transport',
    'Show',
    'Other'
  ];
  String _kind = 'Lesson';
  bool _confirmingDelete = false;
  final _starts = TextEditingController(text: '10:00');
  final _forDur = TextEditingController(text: '1 hr');
  final _who = TextEditingController(text: 'Toni');

  @override
  void dispose() {
    _starts.dispose();
    _forDur.dispose();
    _who.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackLink(label: 'Tuesday'),
                  const AppTag('Lesson', tone: TagTone.accent),
                ],
              ),
              const SizedBox(height: 20),
              Text('Layal · lesson on Ghazal',
                  style: AppText.heading(36, height: 1.05)),
              const SizedBox(height: 8),
              Text('Tuesday 18 August · 10:00 · indoor school',
                  style: AppText.body(16, color: AppColors.ink(0.6))),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final k in _kinds)
                          _Chip(
                            label: k,
                            selected: k == _kind,
                            onTap: () => setState(() => _kind = k),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                            child: AppField(
                                label: l10n.starts, controller: _starts)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: AppField(
                                label: l10n.forDuration, controller: _forDur)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AppField(label: l10n.who, controller: _who),
                  ],
                ),
              ),
              if (!_confirmingDelete) ...[
                AppButton(
                  label: l10n.saveChanges,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _confirmingDelete = true),
                    child: Text(l10n.deleteActivity,
                        style: AppText.body(16, color: AppColors.accent700)),
                  ),
                ),
              ] else ...[
                Text('Delete the 10:00 lesson? Only this one — the weekly repeat stays.',
                    style: AppText.body(17, height: 1.5)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    AppButton(
                      label: l10n.delete,
                      block: false,
                      minHeight: 52,
                      fontSize: 16,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 10),
                    AppButton(
                      label: l10n.keepIt,
                      variant: AppButtonVariant.secondary,
                      block: false,
                      minHeight: 52,
                      fontSize: 16,
                      onPressed: () =>
                          setState(() => _confirmingDelete = false),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

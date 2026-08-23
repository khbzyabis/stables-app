import 'package:flutter/material.dart';
import '../../data/errors.dart';
import 'package:intl/intl.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../auth/back_link.dart';

/// Screen 18 — Add activity. Kind, which horse, the day, time and a note.
/// Saves to the stable's schedule so everyone sees it.
class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});
  static const route = '/schedule/add';

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  EventKind _kind = EventKind.riding;
  String? _horse;
  DateTime _date = DateTime.now();
  bool _busy = false;
  final _starts = TextEditingController(text: '17:00');
  final _forDur = TextEditingController(text: '45 min');
  final _note = TextEditingController();
  late final Future<List<Map<String, dynamic>>> _horsesFuture = _loadHorses();

  Future<List<Map<String, dynamic>>> _loadHorses() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.horses(id);
  }

  @override
  void dispose() {
    _starts.dispose();
    _forDur.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final stableId = SessionScope.of(context).activeStableId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (stableId == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Create a stable first.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await SupabaseService.addActivity(
        stableId: stableId,
        title: _kind.label,
        kind: _kind.name,
        onDate: DateFormat('yyyy-MM-dd').format(_date),
        atTime: _starts.text.trim(),
        duration: _forDur.text.trim(),
        who: _horse,
        note: _note.text.trim(),
      );
      navigator.pop();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

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
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _horsesFuture,
              builder: (context, snap) {
                final horses = snap.data ?? const [];
                if (horses.isEmpty) {
                  return Text('No horses yet — add one first, or leave blank.',
                      style: AppText.body(14, color: AppColors.ink(0.5)));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final h in horses)
                      _Chip(
                        label: (h['name'] as String?) ?? 'Horse',
                        selected: h['name'] == _horse,
                        onTap: () =>
                            setState(() => _horse = h['name'] as String?),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 34),
            Text(l10n.fieldDay.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(DateFormat('EEEE d MMMM').format(_date),
                            style: AppText.body(17))),
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.ink(0.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: AppField(label: l10n.starts, controller: _starts)),
                const SizedBox(width: 14),
                Expanded(
                    child:
                        AppField(label: l10n.forDuration, controller: _forDur)),
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
              label: _busy ? 'Saving…' : l10n.addToSchedule,
              minHeight: 56,
              fontSize: 17,
              onPressed: _busy ? null : _save,
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

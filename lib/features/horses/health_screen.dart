import 'package:flutter/material.dart';

import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 27 — a horse's health record, built from real entries. Filter by
/// kind; log a new entry from the button.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  static const route = '/health';

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  static const _kinds = ['Vet', 'Farrier', 'Vaccination', 'Note'];
  String _filter = 'All';
  Map<String, dynamic> _horse = const {};
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horse = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _future ??= _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final id = _horse['id'] as String?;
    if (id == null) return const [];
    return SupabaseService.healthEntries(id);
  }

  void _reload() => setState(() => _future = _load());

  Color _hue(String kind) => switch (kind) {
        'Vet' => AppColors.accent700,
        'Farrier' => AppColors.accent500,
        'Vaccination' => AppColors.accent2700,
        _ => AppColors.neutral500,
      };

  TagTone _tone(String kind) => switch (kind) {
        'Vet' => TagTone.outline,
        'Farrier' => TagTone.accent,
        'Vaccination' => TagTone.sage,
        _ => TagTone.neutral,
      };

  Future<void> _logHealth() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _LogHealthSheet(),
    );
    if (result == null) return;
    try {
      await SupabaseService.addHealthEntry(
        horseId: horseId,
        stableId: stableId,
        kind: result['kind'] ?? 'Note',
        title: result['title'] ?? '',
        note: result['note'],
      );
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final all = snap.data ?? const [];
            final log = _filter == 'All'
                ? all
                : all.where((h) => h['kind'] == _filter).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: (_horse['name'] as String?) ?? 'Horse'),
                const SizedBox(height: 20),
                Text(l10n.sectionHealth, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in ['All', ..._kinds]) ...[
                        _Chip(
                          label: f,
                          selected: f == _filter,
                          onTap: () => setState(() => _filter = f),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (log.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                        all.isEmpty
                            ? 'Nothing logged yet. The first entry starts the record.'
                            : 'Nothing of that kind on record.',
                        style: AppText.body(16, color: AppColors.ink(0.55))),
                  )
                else
                  for (final h in log) ...[
                    _HealthRow(entry: h, hue: _hue, tone: _tone),
                    const Hairline(),
                  ],
                const SizedBox(height: 28),
                AppButton(label: 'Log health', onPressed: _logHealth),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow(
      {required this.entry, required this.hue, required this.tone});
  final Map<String, dynamic> entry;
  final Color Function(String) hue;
  final TagTone Function(String) tone;

  @override
  Widget build(BuildContext context) {
    final kind = (entry['kind'] as String?) ?? 'Note';
    final date = (entry['on_date'] as String?) ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(date,
                style:
                    AppText.body(13, height: 1.35, color: AppColors.ink(0.5))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: hue(kind), width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((entry['title'] as String?) ?? '',
                      style: AppText.heading(19, height: 1.25)),
                  if ((entry['note'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(entry['note'] as String,
                        style: AppText.body(15,
                            height: 1.45, color: AppColors.ink(0.6))),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppTag(kind, tone: tone(kind)),
        ],
      ),
    );
  }
}

class _LogHealthSheet extends StatefulWidget {
  const _LogHealthSheet();
  @override
  State<_LogHealthSheet> createState() => _LogHealthSheetState();
}

class _LogHealthSheetState extends State<_LogHealthSheet> {
  String _kind = 'Note';
  final _title = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log health', style: AppText.heading(26)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in ['Vet', 'Farrier', 'Vaccination', 'Note'])
                _Chip(
                  label: k,
                  selected: k == _kind,
                  onTap: () => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _Field(controller: _title, hint: 'What happened (e.g. Front shoes)'),
          const SizedBox(height: 12),
          _Field(controller: _note, hint: 'Note (optional)'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              if (_title.text.trim().isEmpty) return;
              Navigator.of(context).pop({
                'kind': _kind,
                'title': _title.text.trim(),
                'note': _note.text.trim(),
              });
            },
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.accent,
      style: AppText.body(17),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.neutral100,
        hintText: hint,
        hintStyle: AppText.body(16, color: AppColors.ink(0.45)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
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

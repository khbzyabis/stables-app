import 'package:flutter/material.dart';
import '../../data/errors.dart';

import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 28 — a horse's training log, from real sessions. Tap a session for
/// the detail; log a new one from the button.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  static const route = '/training';

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  Map<String, dynamic> _horse = const {};
  Future<List<Map<String, dynamic>>>? _future;
  String? _openId;

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
    return SupabaseService.trainingSessions(id);
  }

  void _reload() => setState(() => _future = _load());

  Color _feelHue(String feel) => switch (feel) {
        'Tense' => AppColors.accent700,
        'Easy' => AppColors.accent2600,
        _ => AppColors.accent2700,
      };

  Future<void> _log() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _LogSessionSheet(),
    );
    if (result == null) return;
    try {
      await SupabaseService.addTrainingSession(
        horseId: horseId,
        stableId: stableId,
        title: result['title'] ?? '',
        feel: result['feel'] ?? 'Good',
        meta: result['meta'],
        detail: result['detail'],
      );
      _reload();
    } catch (e) {
      AppErrors.report(e);
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
            final sessions = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: (_horse['name'] as String?) ?? 'Horse'),
                const SizedBox(height: 20),
                Text(l10n.sectionTraining,
                    style: AppText.heading(40, height: 1)),
                const SizedBox(height: 8),
                Text('${sessions.length} session${sessions.length == 1 ? '' : 's'} logged',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
                const SizedBox(height: 22),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('No sessions yet. Log the first one below.',
                        style: AppText.body(16, color: AppColors.ink(0.55))),
                  )
                else
                  for (final t in sessions) ...[
                    _SessionTile(
                      session: t,
                      open: _openId == t['id'],
                      feelHue: _feelHue,
                      onTap: () => setState(() =>
                          _openId = _openId == t['id'] ? null : t['id'] as String),
                    ),
                    const Hairline(),
                  ],
                const SizedBox(height: 28),
                AppButton(label: 'Log a session', onPressed: _log),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile(
      {required this.session,
      required this.open,
      required this.feelHue,
      required this.onTap});
  final Map<String, dynamic> session;
  final bool open;
  final Color Function(String) feelHue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final feel = (session['feel'] as String?) ?? 'Good';
    final detail = session['detail'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Text((session['on_date'] as String?) ?? '',
                      style: AppText.body(13,
                          height: 1.35, color: AppColors.ink(0.5))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((session['title'] as String?) ?? '',
                          style: AppText.heading(19, height: 1.25)),
                      if ((session['meta'] as String?)?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(session['meta'] as String,
                            style:
                                AppText.body(15, color: AppColors.ink(0.6))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(feel, style: AppText.body(14, color: feelHue(feel))),
              ],
            ),
          ),
        ),
        if (open && detail != null && detail.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 78, bottom: 20),
            child: Text(detail,
                style:
                    AppText.body(16, height: 1.55, color: AppColors.ink(0.75))),
          ),
      ],
    );
  }
}

class _LogSessionSheet extends StatefulWidget {
  const _LogSessionSheet();
  @override
  State<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends State<_LogSessionSheet> {
  String _feel = 'Good';
  final _title = TextEditingController();
  final _meta = TextEditingController();
  final _detail = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _meta.dispose();
    _detail.dispose();
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
          Text('Log a session', style: AppText.heading(26)),
          const SizedBox(height: 18),
          _Field(controller: _title, hint: 'What (e.g. Flatwork, Jumping grid)'),
          const SizedBox(height: 12),
          _Field(controller: _meta, hint: 'Who · how long · where (optional)'),
          const SizedBox(height: 16),
          Text('How did it go'.toUpperCase(), style: AppText.eyebrow()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['Good', 'Easy', 'Tense'])
                _Chip(
                  label: f,
                  selected: f == _feel,
                  onTap: () => setState(() => _feel = f),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Field(controller: _detail, hint: 'Detail / notes (optional)'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              if (_title.text.trim().isEmpty) return;
              Navigator.of(context).pop({
                'title': _title.text.trim(),
                'meta': _meta.text.trim(),
                'feel': _feel,
                'detail': _detail.text.trim(),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'show_screen.dart';

/// Screen 47 — Shows. The stable's shows: what's coming up, and the way into
/// each show's entries and start list. Members can add a show.
class ShowsScreen extends StatefulWidget {
  const ShowsScreen({super.key});
  static const route = '/shows';

  @override
  State<ShowsScreen> createState() => _ShowsScreenState();
}

class _ShowsScreenState extends State<ShowsScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.shows(id);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _addShow() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _NewShowSheet(stableId: id),
    );
    if (ok == true) _reload();
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
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) AppErrors.report(snap.error!);
            final shows = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
              children: [
                BackLink(label: session.activeStableName),
                const SizedBox(height: 16),
                Text(l10n.shows, style: AppText.heading(36, height: 1)),
                const SizedBox(height: 12),
                Text('The shows your stable is following. Add one, then enter '
                    'your horses.',
                    style: AppText.body(16,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 26),
                Text('COMING UP', style: AppText.eyebrow(color: AppColors.accent2700)),
                const SizedBox(height: 4),
                const Hairline(),
                if (shows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('No shows yet. Add the first one below.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  ),
                for (final s in shows) ...[
                  _ShowRow(show: s, onReturn: _reload),
                  const Hairline(),
                ],
                const SizedBox(height: 26),
                AppButton(label: 'Add a show', onPressed: _addShow),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShowRow extends StatelessWidget {
  const _ShowRow({required this.show, required this.onReturn});
  final Map<String, dynamic> show;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse((show['on_date'] as String?) ?? '');
    final meta = [
      if ((show['venue'] as String?)?.isNotEmpty == true) show['venue'],
      if ((show['discipline'] as String?)?.isNotEmpty == true) show['discipline'],
    ].join(' · ');
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(ShowScreen.route, arguments: show);
        onReturn();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(date != null ? DateFormat('d').format(date) : '—',
                      style: AppText.heading(21, height: 1)),
                  const SizedBox(height: 3),
                  Text(
                      date != null
                          ? DateFormat('MMM').format(date).toUpperCase()
                          : '',
                      style: AppText.eyebrow()),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((show['name'] as String?) ?? 'Show',
                      style: AppText.body(17, height: 1.3)),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(meta,
                        style: AppText.body(14, color: AppColors.ink(0.55))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppTag((show['state'] as String?) ?? 'Entries open',
                tone: TagTone.sage),
          ],
        ),
      ),
    );
  }
}

class _NewShowSheet extends StatefulWidget {
  const _NewShowSheet({required this.stableId});
  final String stableId;

  @override
  State<_NewShowSheet> createState() => _NewShowSheetState();
}

class _NewShowSheetState extends State<_NewShowSheet> {
  final _name = TextEditingController();
  final _venue = TextEditingController();
  final _discipline = TextEditingController();
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _venue.dispose();
    _discipline.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Give the show a name.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.addShow(
        stableId: widget.stableId,
        name: _name.text.trim(),
        venue: _venue.text.trim(),
        discipline: _discipline.text.trim(),
        onDate: _date != null ? DateFormat('yyyy-MM-dd').format(_date!) : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't add: $e")));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New show', style: AppText.heading(24)),
          const SizedBox(height: 18),
          AppField(label: 'Name', controller: _name),
          const SizedBox(height: 16),
          AppField(label: 'Venue', controller: _venue),
          const SizedBox(height: 16),
          AppField(label: 'Discipline / height', controller: _discipline),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.ink(0.6)),
                  const SizedBox(width: 12),
                  Text(
                      _date != null
                          ? DateFormat.yMMMMd().format(_date!)
                          : 'Pick a date',
                      style: AppText.body(16,
                          color: _date != null
                              ? AppColors.text
                              : AppColors.ink(0.5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Add show', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'start_list_screen.dart';

/// Screen 54 — a single show: its details, who's entered, and a way to enter
/// one of the stable's horses.
class ShowScreen extends StatefulWidget {
  const ShowScreen({super.key});
  static const route = '/show';

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  Map<String, dynamic>? _show;
  Future<List<Map<String, dynamic>>>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_show != null) return;
    _show = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _reload();
  }

  String get _showId => _show?['id'] as String? ?? '';

  void _reload() =>
      setState(() => _entries = SupabaseService.showEntries(_showId));

  Future<void> _enter() async {
    final stableId = SessionScope.of(context).activeStableId;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _EnterHorseSheet(showId: _showId, stableId: stableId),
    );
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final show = _show ?? const {};
    final name = (show['name'] as String?) ?? 'Show';
    final date = DateTime.tryParse((show['on_date'] as String?) ?? '');
    final facts = <(String, String)>[
      if ((show['venue'] as String?)?.isNotEmpty == true)
        ('Where', show['venue'] as String),
      if (date != null) ('When', DateFormat.yMMMMEEEEd().format(date)),
      if ((show['discipline'] as String?)?.isNotEmpty == true)
        ('Discipline', show['discipline'] as String),
      ('Status', (show['state'] as String?) ?? 'Entries open'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
          children: [
            const BackLink(label: 'Shows'),
            const SizedBox(height: 16),
            Text(name, style: AppText.heading(32, height: 1.05)),
            const SizedBox(height: 22),
            for (final (label, value) in facts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 110,
                        child: Text(label,
                            style: AppText.body(15, color: AppColors.ink(0.55)))),
                    Expanded(
                        child: Text(value,
                            style: AppText.body(16, height: 1.4))),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                    child: Text('Entered', style: AppText.heading(22))),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _entries,
                  builder: (context, snap) {
                    final n = (snap.data ?? const [])
                        .where((e) => e['status'] != 'withdrawn')
                        .length;
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                          StartListScreen.route,
                          arguments: _show),
                      child: Text('Start list ($n) ›',
                          style: AppText.body(15, color: AppColors.accent700)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Hairline(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _entries,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 26),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) AppErrors.report(snap.error!);
                final entries = (snap.data ?? const [])
                    .where((e) => e['status'] != 'withdrawn')
                    .toList();
                if (entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Text('No entries yet. Enter a horse below.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  );
                }
                return Column(
                  children: [
                    for (final e in entries) ...[
                      _EntryRow(entry: e),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            AppButton(label: 'Enter a horse', onPressed: _enter),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});
  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final bits = [
      if ((entry['rider_name'] as String?)?.isNotEmpty == true)
        entry['rider_name'],
      if ((entry['class_name'] as String?)?.isNotEmpty == true)
        entry['class_name'],
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((entry['horse_name'] as String?) ?? 'Horse',
                    style: AppText.heading(18, height: 1.2)),
                if (bits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(bits,
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ],
            ),
          ),
          if ((entry['at_time'] as String?)?.isNotEmpty == true)
            AppTag(entry['at_time'] as String, tone: TagTone.neutral),
        ],
      ),
    );
  }
}

class _EnterHorseSheet extends StatefulWidget {
  const _EnterHorseSheet({required this.showId, required this.stableId});
  final String showId;
  final String? stableId;

  @override
  State<_EnterHorseSheet> createState() => _EnterHorseSheetState();
}

class _EnterHorseSheetState extends State<_EnterHorseSheet> {
  final _rider = TextEditingController();
  final _className = TextEditingController();
  final _time = TextEditingController();
  late Future<List<Map<String, dynamic>>> _horses;
  String? _horseId;
  String? _horseName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rider.text = SupabaseService.displayName;
    _horses = widget.stableId == null
        ? Future.value(const [])
        : SupabaseService.horses(widget.stableId!);
  }

  @override
  void dispose() {
    _rider.dispose();
    _className.dispose();
    _time.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_horseName == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick a horse first.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.addShowEntry(
        showId: widget.showId,
        horseName: _horseName!,
        horseId: _horseId,
        riderName: _rider.text.trim(),
        className: _className.text.trim(),
        atTime: _time.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't enter: $e")));
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
          Text('Enter a horse', style: AppText.heading(24)),
          const SizedBox(height: 16),
          Text('HORSE', style: AppText.eyebrow()),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _horses,
            builder: (context, snap) {
              final horses = snap.data ?? const [];
              if (horses.isEmpty) {
                return Text('No horses in this stable yet.',
                    style: AppText.body(15, color: AppColors.ink(0.6)));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in horses)
                    GestureDetector(
                      onTap: () => setState(() {
                        _horseId = h['id'] as String?;
                        _horseName = h['name'] as String?;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 9),
                        decoration: BoxDecoration(
                          color: _horseId == h['id']
                              ? AppColors.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                              color: _horseId == h['id']
                                  ? AppColors.accent
                                  : AppColors.divider),
                        ),
                        child: Text((h['name'] as String?) ?? 'Horse',
                            style: AppText.body(14,
                                color: _horseId == h['id']
                                    ? AppColors.bg
                                    : AppColors.text)),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AppField(label: 'Rider', controller: _rider),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: AppField(
                      label: 'Class', controller: _className)),
              const SizedBox(width: 12),
              Expanded(
                  child: AppField(
                      label: 'Time (e.g. 10:25)', controller: _time)),
            ],
          ),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Enter', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

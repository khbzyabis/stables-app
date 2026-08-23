import 'package:flutter/material.dart';
import '../../data/errors.dart';

import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 33 — a horse's feed chart, from real entries, grouped by time of day.
class FeedChartScreen extends StatefulWidget {
  const FeedChartScreen({super.key});
  static const route = '/feed-chart';

  @override
  State<FeedChartScreen> createState() => _FeedChartScreenState();
}

class _FeedChartScreenState extends State<FeedChartScreen> {
  static const _times = ['Morning', 'Midday', 'Evening'];
  String _time = 'Morning';
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
    return SupabaseService.feedItems(id);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _add() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddFeedSheet(initialTime: _time),
    );
    if (result == null) return;
    try {
      await SupabaseService.addFeedItem(
        horseId: horseId,
        stableId: stableId,
        timeOfDay: result['time'] ?? 'Morning',
        item: result['item'] ?? '',
        amount: result['amount'],
        note: result['note'],
      );
      setState(() => _time = result['time'] ?? _time);
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
            final all = snap.data ?? const [];
            final rows =
                all.where((r) => r['time_of_day'] == _time).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: (_horse['name'] as String?) ?? 'Horse'),
                const SizedBox(height: 20),
                Text(l10n.feedChart, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (final t in _times) ...[
                      _Chip(
                        label: t,
                        selected: t == _time,
                        onTap: () => setState(() => _time = t),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('Nothing set for $_time yet. Add an item below.',
                        style: AppText.body(16, color: AppColors.ink(0.55))),
                  )
                else
                  for (final r in rows) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((r['item'] as String?) ?? '',
                                    style: AppText.body(18, height: 1.3)),
                                if ((r['note'] as String?)?.isNotEmpty ==
                                    true) ...[
                                  const SizedBox(height: 4),
                                  Text(r['note'] as String,
                                      style: AppText.body(14,
                                          color: AppColors.ink(0.5))),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text((r['amount'] as String?) ?? '',
                              style: AppText.heading(19)),
                        ],
                      ),
                    ),
                    const Hairline(),
                  ],
                const SizedBox(height: 28),
                AppButton(label: 'Add feed item', onPressed: _add),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddFeedSheet extends StatefulWidget {
  const _AddFeedSheet({required this.initialTime});
  final String initialTime;
  @override
  State<_AddFeedSheet> createState() => _AddFeedSheetState();
}

class _AddFeedSheetState extends State<_AddFeedSheet> {
  late String _time = widget.initialTime;
  final _item = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _item.dispose();
    _amount.dispose();
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
          Text('Add feed item', style: AppText.heading(26)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            children: [
              for (final t in ['Morning', 'Midday', 'Evening'])
                _Chip(
                  label: t,
                  selected: t == _time,
                  onTap: () => setState(() => _time = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Field(controller: _item, hint: 'Item (e.g. Chaff, Balancer, Hay)'),
          const SizedBox(height: 12),
          _Field(controller: _amount, hint: 'Amount (e.g. 1 scoop, 200 g)'),
          const SizedBox(height: 12),
          _Field(controller: _note, hint: 'Note (optional)'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              if (_item.text.trim().isEmpty) return;
              Navigator.of(context).pop({
                'time': _time,
                'item': _item.text.trim(),
                'amount': _amount.text.trim(),
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

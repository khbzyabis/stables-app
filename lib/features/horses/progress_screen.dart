import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 67 — how a horse is going, over a chosen range. Bars for how many
/// sessions each month, rows for the numbers. Counted from the training log —
/// nothing here is a score.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  static const route = '/progress';

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const _ranges = <String, int>{'3 months': 3, '6 months': 6, '12 months': 12};
  String _range = '3 months';
  Map<String, dynamic>? _horse;
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horse ??= (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    final id = _horse?['id'] as String?;
    _future ??= id == null
        ? Future.value(const <Map<String, dynamic>>[])
        : SupabaseService.trainingSessions(id);
  }

  /// Sessions grouped into the last [months] calendar buckets, oldest first.
  List<(String, int)> _bars(List<Map<String, dynamic>> sessions, int months) {
    final now = DateTime.now();
    final buckets = <String, int>{};
    final labels = <String>[];
    for (var i = months - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('yyyy-MM').format(m);
      buckets[key] = 0;
      labels.add(key);
    }
    for (final s in sessions) {
      final raw = s['on_date'] as String?;
      if (raw == null) continue;
      final d = DateTime.tryParse(raw);
      if (d == null) continue;
      final key = DateFormat('yyyy-MM').format(DateTime(d.year, d.month, 1));
      if (buckets.containsKey(key)) buckets[key] = buckets[key]! + 1;
    }
    return [for (final k in labels) (DateFormat('MMM').format(DateTime.parse('$k-01')), buckets[k]!)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final name = (_horse?['name'] as String?) ?? 'Horse';
    final months = _ranges[_range]!;
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
            final all = snap.data ?? const [];
            final cutoff = DateTime(DateTime.now().year, DateTime.now().month - months + 1, 1);
            final inRange = all.where((s) {
              final d = DateTime.tryParse((s['on_date'] as String?) ?? '');
              return d != null && !d.isBefore(cutoff);
            }).toList();
            final bars = _bars(all, months);
            final maxBar = bars.fold<int>(1, (m, b) => b.$2 > m ? b.$2 : m);
            final feels = <String, int>{};
            for (final s in inRange) {
              final f = (s['feel'] as String?) ?? 'Good';
              feels[f] = (feels[f] ?? 0) + 1;
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
              children: [
                BackLink(label: name),
                const SizedBox(height: 18),
                Text(l10n.howItIsGoing, style: AppText.heading(34, height: 1.05)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (final r in _ranges.keys) ...[
                      _Chip(
                        label: r,
                        selected: r == _range,
                        onTap: () => setState(() => _range = r),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 26),
                if (all.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No training logged yet. As sessions are added to $name'
                      "'s training log, they'll chart here.",
                      style: AppText.body(16,
                          height: 1.5, color: AppColors.ink(0.6)),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < bars.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${bars[i].$2}',
                                      style: AppText.body(12,
                                          color: AppColors.ink(0.5))),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: (bars[i].$2 / maxBar) * 96 + 2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: i == bars.length - 1
                                          ? AppColors.accent
                                          : AppColors.accent2400,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                          bottom: Radius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(bars[i].$1,
                                      style: AppText.body(11,
                                          color: AppColors.ink(0.5))),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Sessions per month over the last $_range.',
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                  const SizedBox(height: 24),
                  const Hairline(),
                  _Row(label: 'Sessions', meta: 'In this range', value: '${inRange.length}'),
                  const Hairline(),
                  for (final feel in feels.entries) ...[
                    _Row(
                        label: feel.key,
                        meta: 'How the sessions felt',
                        value: '${feel.value}'),
                    const Hairline(),
                  ],
                  const SizedBox(height: 20),
                  Text(
                      'Counted from the training log. Nothing here is a score.',
                      style: AppText.body(14,
                          height: 1.55, color: AppColors.ink(0.5))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.meta, required this.value});
  final String label;
  final String meta;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.body(16, height: 1.35)),
                const SizedBox(height: 4),
                Text(meta, style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(value, style: AppText.heading(18)),
        ],
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

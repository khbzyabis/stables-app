import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 67 — how a horse is going, over a chosen range. Bars for volume,
/// rows for the numbers, and the trainer's note. Nothing here is a score.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  static const route = '/progress';

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _range = '3 months';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final set = HorseDetailData.progress[_range]!;
    final maxBar =
        set.bars.map((b) => b.$2).reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 18),
            Text(l10n.howItIsGoing, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 20),
            Row(
              children: [
                for (final r in HorseDetailData.progressRanges) ...[
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
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < set.bars.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${set.bars[i].$2}',
                                style: AppText.body(12, color: AppColors.ink(0.5))),
                            const SizedBox(height: 8),
                            Container(
                              height: (set.bars[i].$2 / maxBar) * 96,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: i == set.bars.length - 1
                                    ? AppColors.accent
                                    : AppColors.accent2400,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                    bottom: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(set.bars[i].$1,
                                style: AppText.body(11, color: AppColors.ink(0.5))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(set.caption,
                style: AppText.body(14, color: AppColors.ink(0.55))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final r in set.rows) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.label, style: AppText.body(16, height: 1.35)),
                          const SizedBox(height: 4),
                          Text(r.meta,
                              style: AppText.body(14, color: AppColors.ink(0.5))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(r.value, style: AppText.heading(18)),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(color: AppColors.accent2300, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toni wrote'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent2700)),
                  const SizedBox(height: 7),
                  Text(set.note, style: AppText.body(16, height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
                'Counted from the schedule and the training log. Nothing here is a score.',
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.5))),
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

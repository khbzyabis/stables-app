import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 33 — the feed chart. What goes in the bucket, by time of day, plus
/// the do-not-feed note.
class FeedChartScreen extends StatefulWidget {
  const FeedChartScreen({super.key});
  static const route = '/feed-chart';

  @override
  State<FeedChartScreen> createState() => _FeedChartScreenState();
}

class _FeedChartScreenState extends State<FeedChartScreen> {
  String _time = 'Morning';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final rows = HorseDetailData.feedChart[_time]!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 20),
            Text(l10n.feedChart, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Changed by Layal, 4 days ago',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            Row(
              children: [
                for (final t in HorseDetailData.feedChart.keys) ...[
                  _Chip(
                    label: t,
                    selected: t == _time,
                    onTap: () => setState(() => _time = t),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            const Hairline(),
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
                          Text(r.item, style: AppText.body(18, height: 1.3)),
                          if (r.note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(r.note,
                                style: AppText.body(14,
                                    color: AppColors.ink(0.5))),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(r.amount, style: AppText.heading(19)),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            Text('Do not feed'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 10),
            Text('No alfalfa. Soaked hay only after a dusty day.',
                style: AppText.body(17, height: 1.5)),
            const SizedBox(height: 28),
            Row(
              children: [
                AppButton(
                  label: l10n.editChart,
                  block: false,
                  minHeight: 52,
                  fontSize: 16,
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: l10n.history,
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 52,
                  fontSize: 16,
                  onPressed: () {},
                ),
              ],
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

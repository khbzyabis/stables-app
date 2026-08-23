import 'package:flutter/material.dart';

import '../../data/shows_data.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 55 — the start list. Your ride is highlighted, with a plain-language
/// estimate of when to be ready. Times move; a notification follows.
class StartListScreen extends StatelessWidget {
  const StartListScreen({super.key});
  static const route = '/start-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Spring Tour'),
            const SizedBox(height: 16),
            Text('1.10 m, class 3', style: AppText.heading(30, height: 1.08)),
            const SizedBox(height: 8),
            Text('32 entries · starts 09:00 · order drawn Thursday',
                style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent2200,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You are 14th to go'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent2800)),
                  const SizedBox(height: 7),
                  Text('Kiki · about 10:25',
                      style: AppText.heading(22, height: 1.2)),
                  const SizedBox(height: 5),
                  Text(
                      'Roughly 90 seconds a round. Be in the collecting ring by 10:05.',
                      style: AppText.body(15,
                          height: 1.5, color: AppColors.accent2900)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Hairline(),
            for (final r in ShowsData.startList) ...[
              _StartRow(entry: r),
              const Hairline(),
            ],
            const SizedBox(height: 18),
            Text(
                'Times move. You get a notification if the class runs early or late.',
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.5))),
          ],
        ),
      ),
    );
  }
}

class _StartRow extends StatelessWidget {
  const _StartRow({required this.entry});
  final StartEntry entry;

  @override
  Widget build(BuildContext context) {
    final highlight = entry.me || entry.stable;
    return Container(
      color: entry.me ? AppColors.accent100 : null,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${entry.no}',
                style: AppText.heading(17, color: AppColors.ink(0.6))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.rider,
                    style: highlight
                        ? AppText.heading(17)
                        : AppText.body(17, height: 1.3)),
                const SizedBox(height: 3),
                Text(entry.horse,
                    style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          SizedBox(
            width: 78,
            child: Text(entry.at,
                textAlign: TextAlign.right,
                style: AppText.body(15, color: AppColors.ink(0.65))),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/shows_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'show_screen.dart';
import 'start_list_screen.dart';

/// Screen 47 — Shows mode. The world outside the yard: My Stables notices,
/// what is coming up, and the ways into entries, results and shops.
class ShowsScreen extends StatelessWidget {
  const ShowsScreen({super.key});
  static const route = '/shows';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Yard'),
            const SizedBox(height: 16),
            Text('Shows · Dubai'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 9),
            Text(l10n.shows, style: AppText.heading(36, height: 1)),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent2200,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From My Stables'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent2800)),
                  const SizedBox(height: 7),
                  Text('Spring Tour entries open Monday',
                      style: AppText.heading(19, height: 1.25)),
                  const SizedBox(height: 6),
                  Text(
                      'Three legs at Al Qudra. Entries through the app for the first time this year.',
                      style: AppText.body(15,
                          height: 1.55, color: AppColors.accent2900)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Coming up'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 4),
            const Hairline(),
            for (final w in ShowsData.shows) ...[
              _ShowRow(row: w),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            for (final l in ShowsData.showLinks) ...[
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(
                    l.label.startsWith('Start')
                        ? StartListScreen.route
                        : ShowScreen.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.label, style: AppText.heading(18)),
                            const SizedBox(height: 4),
                            Text(l.meta,
                                style: AppText.body(14,
                                    color: AppColors.ink(0.55))),
                          ],
                        ),
                      ),
                      Text('›',
                          style: AppText.body(19, color: AppColors.ink(0.4))),
                    ],
                  ),
                ),
              ),
              const Hairline(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShowRow extends StatelessWidget {
  const _ShowRow({required this.row});
  final ShowRow row;

  @override
  Widget build(BuildContext context) {
    final tone = switch (row.tone) {
      'sage' => TagTone.sage,
      'accent' => TagTone.accent,
      _ => TagTone.neutral,
    };
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(ShowScreen.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(row.day, style: AppText.heading(21, height: 1)),
                  const SizedBox(height: 3),
                  Text(row.month.toUpperCase(),
                      style: AppText.eyebrow()),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.name, style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(row.meta,
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppTag(row.state, tone: tone),
          ],
        ),
      ),
    );
  }
}

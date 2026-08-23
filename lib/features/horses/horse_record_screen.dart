import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';
import 'documents_screen.dart';
import 'edit_horse_screen.dart';
import 'feed_chart_screen.dart';
import 'health_screen.dart';
import 'progress_screen.dart';
import 'setups_screen.dart';
import 'tack_box_screen.dart';
import 'training_screen.dart';

/// Screen 32 — a horse's record, filled in. The hub that links to health,
/// progress, training, setups, tack, feed and documents.
class HorseRecordScreen extends StatelessWidget {
  const HorseRecordScreen({super.key});
  static const route = '/horse-record';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final links = <RecordLink>[
      RecordLink(HealthScreen.route, l10n.sectionHealth,
          'Farrier Thursday · last note 11 Aug'),
      RecordLink(ProgressScreen.route, l10n.howItIsGoing,
          'Three months of work, side by side'),
      RecordLink(TrainingScreen.route, l10n.sectionTraining,
          '4 sessions in the last fortnight'),
      RecordLink(SetupsScreen.route, l10n.setups,
          'Flatwork, jumping, hacking, lunging'),
      RecordLink(
          TackBoxScreen.route, l10n.tack, "From Ahmad's tack box · 9 items"),
      RecordLink(
          FeedChartScreen.route, l10n.feedChart, 'Three feeds · no alfalfa'),
      RecordLink(DocumentsScreen.route, l10n.documents,
          'Passport, insurance, vaccinations'),
    ];

    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -120,
          child: Container(
            width: 290,
            height: 290,
            decoration: const BoxDecoration(
                color: AppColors.accent2200, shape: BoxShape.circle),
          ),
        ),
        Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: l10n.navHorses),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const PhotoPlaceholder(size: 88),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kiki', style: AppText.heading(36, height: 1)),
                          const SizedBox(height: 8),
                          Text('Gelding · 9 years · 16.1 hh',
                              style:
                                  AppText.body(15, color: AppColors.ink(0.6))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AppTag(l10n.statusWell, tone: TagTone.sage),
                    const SizedBox(width: 8),
                    const AppTag('Box 7', tone: TagTone.neutral),
                    const SizedBox(width: 8),
                    const AppTag('Ahmad', tone: TagTone.neutral),
                  ],
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 34,
                  runSpacing: 24,
                  children: const [
                    _Fact(label: 'Breed', value: 'Arabian cross'),
                    _Fact(label: 'Farrier', value: 'Thursday'),
                    _Fact(label: 'Last ridden', value: 'Yesterday'),
                  ],
                ),
                const SizedBox(height: 24),
                const Hairline(),
                for (final l in links) ...[
                  _RecordRow(link: l),
                  const Hairline(),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(EditHorseScreen.route),
                  child: Text(l10n.editDetails,
                      style: AppText.heading(16, color: AppColors.accent700)),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(EditHorseScreen.route),
                  child: Text(l10n.moveHorse,
                      style: AppText.body(16, color: AppColors.ink(0.55))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow()),
        const SizedBox(height: 5),
        Text(value, style: AppText.body(17)),
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.link});
  final RecordLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(link.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 19),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.label, style: AppText.heading(20)),
                  const SizedBox(height: 4),
                  Text(link.meta,
                      style: AppText.body(15, color: AppColors.ink(0.55))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('›',
                style: AppText.body(19, color: AppColors.ink(0.4))),
          ],
        ),
      ),
    );
  }
}

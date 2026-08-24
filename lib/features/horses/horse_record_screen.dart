import 'package:flutter/material.dart';

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

/// Screen 32 — a horse's record. The hub for one real horse; its links carry
/// the horse to Health, Training and Feed (which load that horse's data).
class HorseRecordScreen extends StatefulWidget {
  const HorseRecordScreen({super.key});
  static const route = '/horse-record';

  @override
  State<HorseRecordScreen> createState() => _HorseRecordScreenState();
}

class _HorseRecordScreenState extends State<HorseRecordScreen> {
  Map<String, dynamic>? _horse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horse ??= (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(context)
        .pushNamed(EditHorseScreen.route, arguments: _horse);
    if (!mounted) return;
    if (result == 'removed') {
      Navigator.of(context).pop('removed'); // back to the horses list
    } else if (result is Map<String, dynamic>) {
      setState(() => _horse = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final horse = _horse ?? const {};
    final name = (horse['name'] as String?) ?? 'Horse';
    final well = (horse['status'] as String?) != 'watch';

    final facts = <(String, String)>[
      for (final k in ['breed', 'age', 'height', 'sex'])
        if ((horse[k] as String?)?.isNotEmpty == true)
          (k[0].toUpperCase() + k.substring(1), horse[k] as String),
    ];

    final links = <(String, String, String)>[
      (HealthScreen.route, l10n.sectionHealth, 'Vet, farrier and vaccination notes'),
      (TrainingScreen.route, l10n.sectionTraining, 'Sessions and how they went'),
      (FeedChartScreen.route, l10n.feedChart, 'What goes in the bucket'),
      (ProgressScreen.route, l10n.howItIsGoing, 'Work over time'),
      (SetupsScreen.route, l10n.setups, 'Tack per activity'),
      (TackBoxScreen.route, l10n.tack, 'The kit'),
      (DocumentsScreen.route, l10n.documents, 'Passport, insurance, vaccinations'),
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
                          Text(name, style: AppText.heading(36, height: 1)),
                          if ((horse['box'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text('Box ${horse['box']}',
                                style: AppText.body(15,
                                    color: AppColors.ink(0.6))),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AppTag(well ? l10n.statusWell : l10n.statusWatch,
                        tone: well ? TagTone.sage : TagTone.accent),
                  ],
                ),
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 34,
                    runSpacing: 24,
                    children: [
                      for (final (label, value) in facts)
                        _Fact(label: label, value: value),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Hairline(),
                for (final (route, label, meta) in links) ...[
                  InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(route, arguments: horse),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label, style: AppText.heading(20)),
                                const SizedBox(height: 4),
                                Text(meta,
                                    style: AppText.body(15,
                                        color: AppColors.ink(0.55))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('›',
                              style:
                                  AppText.body(19, color: AppColors.ink(0.4))),
                        ],
                      ),
                    ),
                  ),
                  const Hairline(),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _openEdit,
                  child: Text(l10n.editDetails,
                      style: AppText.heading(16, color: AppColors.accent700)),
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

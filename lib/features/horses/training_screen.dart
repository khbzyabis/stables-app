import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 28 — training log. Sessions and how they went, with a two-week
/// load bar and an expandable note per session.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  static const route = '/training';

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final maxLoad =
        HorseDetailData.load.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 20),
            Text(l10n.sectionTraining, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 8),
            Text('Four sessions in the last fortnight',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 26),
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final v in HorseDetailData.load) ...[
                    Expanded(
                      child: Container(
                        height: v == 0 ? 4 : 12 + (v / maxLoad) * 52,
                        decoration: BoxDecoration(
                          color: v == 0
                              ? AppColors.neutral300
                              : AppColors.accent2500,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(999), bottom: Radius.circular(3)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Last two weeks · taller is a longer session',
                style: AppText.body(13, color: AppColors.ink(0.45))),
            const SizedBox(height: 26),
            const Hairline(),
            for (var i = 0; i < HorseDetailData.sessions.length; i++) ...[
              _SessionTile(
                session: HorseDetailData.sessions[i],
                open: _open == i,
                onTap: () => setState(() => _open = _open == i ? null : i),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 28),
            AppButton(
              label: l10n.logSession,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile(
      {required this.session, required this.open, required this.onTap});
  final TrainingSession session;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(session.date,
                      style: AppText.body(14,
                          height: 1.35, color: AppColors.ink(0.5))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title,
                          style: AppText.heading(19, height: 1.25)),
                      const SizedBox(height: 4),
                      Text(session.meta,
                          style: AppText.body(15, color: AppColors.ink(0.6))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(session.feel,
                    style: AppText.body(14, color: session.feelHue)),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(left: 72, bottom: 20),
            child: Text(session.detail,
                style:
                    AppText.body(16, height: 1.55, color: AppColors.ink(0.75))),
          ),
      ],
    );
  }
}

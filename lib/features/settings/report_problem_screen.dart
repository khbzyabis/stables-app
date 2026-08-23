import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 45 — report a problem. Pick a kind, one line and a photo, and the
/// device facts are attached automatically. Becomes a support ticket.
class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});
  static const route = '/report-problem';

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  int _kind = 0;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final kind = CommsData.problemKinds[_kind];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Help'),
            const SizedBox(height: 18),
            Text(l10n.somethingWrong, style: AppText.heading(36, height: 1.05)),
            const SizedBox(height: 10),
            Text('One line is enough. A photo is better than a paragraph.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < CommsData.problemKinds.length; i++)
                  _Chip(
                    label: CommsData.problemKinds[i].$1,
                    selected: i == _kind,
                    onTap: () => setState(() => _kind = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.whatHappened.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                maxLines: 3,
                cursorColor: AppColors.accent,
                style: AppText.body(17, height: 1.5),
                decoration: InputDecoration.collapsed(
                  hintText: kind.$2,
                  hintStyle: AppText.body(17, color: AppColors.ink(0.45)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.photo_camera_outlined,
                        size: 20, color: AppColors.neutral700),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.addAPhoto, style: AppText.body(17)),
                      const SizedBox(height: 3),
                      Text('Camera or your library',
                          style: AppText.body(14, color: AppColors.ink(0.55))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Sent with it'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 4),
            const Hairline(),
            for (final (label, value) in CommsData.problemFacts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(label,
                            style:
                                AppText.body(15, color: AppColors.ink(0.55)))),
                    Text(value, style: AppText.body(15)),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 14),
            Text('No horse records or notes are sent.',
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.5))),
            const SizedBox(height: 24),
            AppButton(
              label: _sent ? l10n.sent : l10n.send,
              onPressed: () => setState(() => _sent = true),
            ),
            if (_sent) ...[
              const SizedBox(height: 18),
              Text(
                  'Sent. It is ticket #218 in the console, unassigned, marked high because a groom cannot work.',
                  style: AppText.body(15,
                      height: 1.55, color: AppColors.accent700)),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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

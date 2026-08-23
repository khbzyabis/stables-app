import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../horses/add_horse_screen.dart';

/// Screen 13 — the rider's side. A horse they added is visible only to them
/// until the stable admin approves it.
class HorsePendingScreen extends StatelessWidget {
  const HorsePendingScreen({super.key});
  static const route = '/horse-pending';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Serc · Rider'.toUpperCase(),
                  style: AppText.eyebrow(color: AppColors.accent700)),
              const SizedBox(height: 12),
              Text(l10n.titleMyHorses, style: AppText.heading(40, height: 1)),
              const SizedBox(height: 30),
              const Hairline(),
              _HorseRow(
                name: 'Ghazal',
                meta: 'Sent to Layal · 2 hours ago',
                tag: l10n.pending,
                tone: TagTone.accent,
              ),
              const Hairline(),
              Opacity(
                opacity: 0.55,
                child: _HorseRow(
                  name: 'Nour',
                  meta: 'At Desert Rose Stables',
                  tag: l10n.approved,
                  tone: TagTone.sage,
                ),
              ),
              const Hairline(),
              const SizedBox(height: 26),
              Text(
                  'Ghazal is only visible to you until the stable admin approves her.',
                  style: AppText.body(16,
                      height: 1.55, color: AppColors.ink(0.6))),
              const Spacer(),
              AppButton(
                label: 'Add another horse',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AddHorseScreen.route),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorseRow extends StatelessWidget {
  const _HorseRow(
      {required this.name,
      required this.meta,
      required this.tag,
      required this.tone});
  final String name;
  final String meta;
  final String tag;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const PhotoPlaceholder(size: 66),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.heading(23, height: 1.1)),
                const SizedBox(height: 4),
                Text(meta,
                    style: AppText.body(15, color: AppColors.ink(0.6))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppTag(tag, tone: tone),
        ],
      ),
    );
  }
}

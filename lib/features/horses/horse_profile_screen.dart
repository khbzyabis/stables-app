import 'package:flutter/material.dart';

import '../../data/stable_store.dart';
import '../../l10n/app_localizations.dart';
import '../../models/horse.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';

/// Screen 08 — Horse profile. Shows status, health and training. A freshly
/// added horse shows honest empty states rather than fake data.
class HorseProfileScreen extends StatelessWidget {
  const HorseProfileScreen({super.key});
  static const route = '/horse';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final store = StableScope.of(context);
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    // Fall back to the first horse when opened without an argument (e.g. a
    // direct web deep-link).
    final Horse horse = id != null ? store.byId(id) : store.horses.first;
    final well = horse.status == HorseStatus.well;

    return Stack(
      children: [
        // Decorative organic circle behind the header.
        Positioned(
          top: -90,
          right: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              color: AppColors.accent2200,
              shape: BoxShape.circle,
            ),
          ),
        ),
        AppScreen(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackLink(label: l10n.navHorses),
              const SizedBox(height: 28),
              const PhotoPlaceholder(size: 96),
              const SizedBox(height: 22),
              Text(horse.name, style: AppText.heading(42, height: 1)),
              const SizedBox(height: 14),
              Row(
                children: [
                  AppTag(well ? l10n.statusWell : l10n.statusWatch,
                      tone: well ? TagTone.sage : TagTone.accent),
                  if (horse.addedToday) ...[
                    const SizedBox(width: 8),
                    AppTag(l10n.addedToday, tone: TagTone.neutral),
                  ],
                ],
              ),
              const SizedBox(height: 30),
              if (!horse.hasDetails) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(l10n.profileNoDetails,
                      style: AppText.body(17,
                          height: 1.55, color: AppColors.ink(0.6))),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Text('+ ${l10n.addDetails}',
                      style: AppText.heading(17, color: AppColors.accent700)),
                ),
              ] else
                _Details(horse: horse),
              const SizedBox(height: 44),
              const Hairline(),
              _Section(title: l10n.sectionHealth, body: l10n.healthEmpty),
              const Hairline(),
              _Section(title: l10n.sectionTraining, body: l10n.trainingEmpty),
              const Hairline(),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.logSomething,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.horse});
  final Horse horse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final rows = <(String, String?)>[
      (l10n.detailAge, horse.age),
      (l10n.detailBreed, horse.breed),
      (l10n.detailSex, horse.sex),
      (l10n.detailHeight, horse.height),
      (l10n.detailBox, horse.box),
      (l10n.detailNotes, horse.notes),
    ].where((r) => r.$2 != null && r.$2!.isNotEmpty).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (label, value) in rows)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$label  ', style: AppText.eyebrow()),
                Text(value!, style: AppText.body(16)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading(21)),
          const SizedBox(height: 6),
          Text(body, style: AppText.body(16, color: AppColors.ink(0.55))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'add_tack_item_screen.dart';
import 'setups_screen.dart';

/// Screen 20 — a rider's own tack box. Tap a group to see its items. The kit
/// here can be named on a schedule so the groom tacks up the right things.
class TackBoxScreen extends StatefulWidget {
  const TackBoxScreen({super.key});
  static const route = '/tack-box';

  @override
  State<TackBoxScreen> createState() => _TackBoxScreenState();
}

class _TackBoxScreenState extends State<TackBoxScreen> {
  int? _open;

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
            const BackLink(label: 'Serc'),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layal · Serc'.toUpperCase(),
                          style: AppText.eyebrow(color: AppColors.accent700)),
                      const SizedBox(height: 10),
                      Text(l10n.tackBox, style: AppText.heading(40, height: 1)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AddTackItemScreen.route),
                  child: Text(l10n.addItem,
                      style: AppText.body(15, color: AppColors.accent700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l10n.tackBoxIntro,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            for (var i = 0; i < HorseDetailData.tackGroups.length; i++) ...[
              _GroupTile(
                group: HorseDetailData.tackGroups[i],
                open: _open == i,
                onTap: () => setState(() => _open = _open == i ? null : i),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 30),
            AppButton(
              label: l10n.buildSetup,
              onPressed: () =>
                  Navigator.of(context).pushNamed(SetupsScreen.route),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile(
      {required this.group, required this.open, required this.onTap});
  final TackGroup group;
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: AppText.heading(21)),
                      const SizedBox(height: 4),
                      Text(group.summary,
                          style:
                              AppText.body(15, color: AppColors.ink(0.55))),
                    ],
                  ),
                ),
                Text(open ? '–' : '+',
                    style: AppText.body(22, color: AppColors.ink(0.45))),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final it in group.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          decoration: const BoxDecoration(
                              color: AppColors.accent2500,
                              shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.name, style: AppText.body(17)),
                              if (it.note.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(it.note,
                                    style: AppText.body(14,
                                        color: AppColors.ink(0.5))),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

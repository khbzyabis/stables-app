import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../edge/invite_accepted_screen.dart';
import '../horses/add_horse_screen.dart';

/// Screen 64 — day one, nothing in it yet. An honest empty state that points at
/// the first useful things to do.
class DayOneScreen extends StatelessWidget {
  const DayOneScreen({super.key});
  static const route = '/day-one';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                  color: AppColors.accent2200, shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                Text('Serc · Tuesday'.toUpperCase(),
                    style: AppText.eyebrow(color: AppColors.accent700)),
                const SizedBox(height: 9),
                Text('My horses', style: AppText.heading(36, height: 1)),
                const SizedBox(height: 30),
                Container(
                  width: 66,
                  height: 66,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral400, width: 2),
                  ),
                  child: Icon(Icons.pets,
                      size: 26, color: AppColors.neutral700),
                ),
                const SizedBox(height: 22),
                Text('No horses yet', style: AppText.heading(24, height: 1.2)),
                const SizedBox(height: 10),
                Text(
                    'Add one and the rest of the app has something to hang on to — the schedule, the tack, the health notes.',
                    style: AppText.body(17,
                        height: 1.6, color: AppColors.ink(0.7))),
                const SizedBox(height: 26),
                AppButton(
                  label: 'Add your first horse',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AddHorseScreen.route),
                ),
                const SizedBox(height: 32),
                const Hairline(),
                const SizedBox(height: 22),
                Text('While you are here'.toUpperCase(),
                    style: AppText.eyebrow(color: AppColors.accent2700)),
                const SizedBox(height: 12),
                _Link(
                  label: 'Invite the people who work here',
                  onTap: () => Navigator.of(context)
                      .pushNamed(InviteAcceptedScreen.route),
                ),
                const SizedBox(height: 14),
                _Link(label: 'Put the stable on the map', onTap: () {}),
                const SizedBox(height: 14),
                _Link(label: 'Write the first notice', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: AppText.body(16, color: AppColors.accent700)),
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../home/home_screen.dart';

/// Screen 10 — opening an invite link. The role travels with the invite; you
/// keep the same account and this stable is added to the ones you are in.
class InviteAcceptedScreen extends StatelessWidget {
  const InviteAcceptedScreen({super.key});
  static const route = '/invite-accepted';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -130,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                  color: AppColors.accent200, shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invitation'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent700)),
                  const SizedBox(height: 14),
                  Text('Layal asked you to join Serc',
                      style: AppText.heading(40, height: 1.05)),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      AppTag('As trainer', tone: TagTone.accent),
                      SizedBox(width: 8),
                      AppTag('Dubai', tone: TagTone.neutral),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                      'You keep the same account. This stable is added to the ones you are already in, with its own role.',
                      style: AppText.body(17,
                          height: 1.55, color: AppColors.ink(0.7))),
                  const SizedBox(height: 34),
                  const Hairline(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                        'As a trainer you can log training, read the noticeboard and see horses you are assigned.',
                        style: AppText.body(16, height: 1.5)),
                  ),
                  const Hairline(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                        'You cannot invite people, approve horses or edit stable settings.',
                        style: AppText.body(16,
                            height: 1.5, color: AppColors.ink(0.6))),
                  ),
                  const Hairline(),
                  const Spacer(),
                  AppButton(
                    label: 'Join as trainer',
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(HomeScreen.route, (r) => false),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.notNow,
                          style: AppText.body(16, color: AppColors.ink(0.55))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

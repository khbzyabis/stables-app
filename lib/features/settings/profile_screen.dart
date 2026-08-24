import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import '../auth/splash_screen.dart';

/// Screen 37 — your profile. One account across every stable, with links to
/// your stables, tack box, payments, language and help.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const route = '/profile';

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    final session = SessionScope.of(context);
    try {
      await SupabaseService.signOut();
      session.clear();
    } catch (_) {}
    nav.pushNamedAndRemoveUntil(SplashScreen.route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final name = SupabaseService.displayName;
    final email = SupabaseService.currentUser?.email ?? '';
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'Y';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
          children: [
            const BackLink(label: 'You'),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.accent2300, shape: BoxShape.circle),
                  child: Text(initial,
                      style: AppText.heading(28, color: AppColors.accent2900)),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.heading(32, height: 1)),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(email,
                            style: AppText.body(15, color: AppColors.ink(0.6))),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Hairline(),
            for (final l in CommsData.meLinks) ...[
              InkWell(
                onTap: l.route == null
                    ? null
                    : () => Navigator.of(context).pushNamed(l.route!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.label, style: AppText.body(18, height: 1.3)),
                            const SizedBox(height: 4),
                            Text(l.meta,
                                style: AppText.body(14,
                                    color: AppColors.ink(0.5))),
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
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _signOut(context),
              child: Text(l10n.signOut,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'To delete your account, contact support for now.'))),
              child: Text(l10n.deleteAccount,
                  style: AppText.body(15, color: AppColors.ink(0.5))),
            ),
          ],
        ),
      ),
    );
  }
}

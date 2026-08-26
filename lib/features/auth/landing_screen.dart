import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'sign_in_screen.dart';

/// The public front page everyone lands on (signed out, at the root). It points
/// each audience to their door so nobody needs to know /sell or /admin.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _goto(String path) =>
      launchUrl(Uri.parse(path), webOnlyWindowName: '_self');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand mark
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: Text('MS',
                          style:
                              AppText.heading(30, color: AppColors.bg)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('My Stables',
                      textAlign: TextAlign.center,
                      style: AppText.heading(40, height: 1.05)),
                  const SizedBox(height: 12),
                  Text(
                    'Everything for the yard — horses, people, and the market '
                    'that supplies them.',
                    textAlign: TextAlign.center,
                    style: AppText.body(17,
                        height: 1.5, color: AppColors.ink(0.65)),
                  ),
                  const SizedBox(height: 40),

                  _Choice(
                    icon: Icons.pets_outlined,
                    title: 'I ride or run a stable',
                    subtitle:
                        'Riders, owners, grooms, vets and managers. Your horses, '
                        'schedule, and the market.',
                    primary: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SignInScreen())),
                  ),
                  const SizedBox(height: 14),
                  _Choice(
                    icon: Icons.storefront_outlined,
                    title: 'I sell or provide a service',
                    subtitle:
                        'Shops, feed, farriers, vets, physios and transport. '
                        'Manage orders, listings and payouts.',
                    onTap: () => kIsWeb
                        ? _goto('/sell')
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SignInScreen())),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: GestureDetector(
                      onTap: () => kIsWeb ? _goto('/admin') : null,
                      child: Text('Operator sign-in',
                          style: AppText.body(15, color: AppColors.ink(0.5))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon,
                  size: 26,
                  color: primary ? AppColors.bg : AppColors.accent700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.heading(18,
                            color: primary ? AppColors.bg : AppColors.text)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppText.body(13,
                            height: 1.4,
                            color: primary
                                ? AppColors.bg.withValues(alpha: 0.85)
                                : AppColors.ink(0.6))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: primary ? AppColors.bg : AppColors.ink(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

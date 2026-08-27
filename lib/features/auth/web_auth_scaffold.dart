import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_screen.dart';

/// Chrome for the auth screens (sign-in / sign-up) when they are opened from
/// the website on a desktop browser. It mirrors the marketing homepage — the
/// same near-white ground, a simple site header, and a centred card — so
/// arriving here from "Start selling" feels like the same, professional site
/// rather than a stretched-out mobile form.
///
/// On a phone (or any narrow viewport) it falls back to the familiar padded
/// [AppScreen], so the native app is unchanged.
class WebAuthScaffold extends StatelessWidget {
  const WebAuthScaffold({super.key, required this.child});

  final Widget child;

  /// The marketing page's ground — a touch cooler and lighter than the warm
  /// app ground, so the two read as one site.
  static const _pageBg = Color(0xFFFBF8F3);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = kIsWeb && c.maxWidth > 620;
        if (!wide) {
          return AppScreen(scrollable: true, child: child);
        }
        return Scaffold(
          backgroundColor: _pageBg,
          body: SafeArea(
            child: Column(
              children: [
                const _SiteHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.warmWhite,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.divider),
                            boxShadow: AppShadow.md,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  void _home() => launchUrl(Uri.parse('/'), webOnlyWindowName: '_self');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Row(
            children: [
              GestureDetector(
                onTap: _home,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('M',
                          style: AppText.heading(17,
                              color: Colors.white, height: 1)),
                    ),
                    const SizedBox(width: 10),
                    Text('My Stables', style: AppText.heading(20, height: 1)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _home,
                child: Text('← Back to site',
                    style: AppText.body(15, color: AppColors.ink(0.6))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

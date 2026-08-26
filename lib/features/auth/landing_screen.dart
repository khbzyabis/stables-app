import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import 'sign_in_screen.dart';

/// The public marketing homepage everyone lands on (signed out, at the root).
/// A hero, what the product does, who it's for, and clear doors — so nobody
/// needs to know /sell or /admin. CTAs route into the right portal.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _sell() => launchUrl(Uri.parse('/sell'), webOnlyWindowName: '_self');
  void _admin() => launchUrl(Uri.parse('/admin'), webOnlyWindowName: '_self');
  void _openApp(BuildContext c) => Navigator.of(c)
      .push(MaterialPageRoute(builder: (_) => const SignInScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 860;
          return SingleChildScrollView(
            child: Column(
              children: [
                _TopBar(wide: wide, onSignIn: () => _openApp(context)),
                _Hero(
                    wide: wide,
                    onApp: () => _openApp(context),
                    onSell: kIsWeb ? _sell : () => _openApp(context)),
                const _TrustStrip(),
                _Features(wide: wide),
                _Audiences(
                    wide: wide,
                    onApp: () => _openApp(context),
                    onSell: kIsWeb ? _sell : () => _openApp(context)),
                _HowItWorks(wide: wide),
                _CtaBand(
                    onApp: () => _openApp(context),
                    onSell: kIsWeb ? _sell : () => _openApp(context)),
                _Footer(onAdmin: kIsWeb ? _admin : () {}),
              ],
            ),
          );
        }),
      ),
    );
  }
}

double _pad(double w) => w >= 860 ? 64 : 24;

Widget _wrap(BuildContext context, Widget child, {Color? color}) {
  final w = MediaQuery.of(context).size.width;
  return Container(
    width: double.infinity,
    color: color,
    padding: EdgeInsets.symmetric(horizontal: _pad(w), vertical: 0),
    child: Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120), child: child),
    ),
  );
}

// ---- Top bar ---------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.wide, required this.onSignIn});
  final bool wide;
  final VoidCallback onSignIn;
  @override
  Widget build(BuildContext context) {
    return _wrap(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(children: [
          const _Logo(),
          const Spacer(),
          AppButton(
            label: AppL10n.of(context).ldSignIn,
            variant: AppButtonVariant.secondary,
            block: false,
            minHeight: 44,
            fontSize: 15,
            onPressed: onSignIn,
          ),
        ]),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration:
            const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
        child: Text('MS', style: AppText.heading(15, color: AppColors.bg)),
      ),
      const SizedBox(width: 10),
      Text('My Stables', style: AppText.heading(20)),
    ]);
  }
}

// ---- Hero ------------------------------------------------------------------
class _Hero extends StatelessWidget {
  const _Hero({required this.wide, required this.onApp, required this.onSell});
  final bool wide;
  final VoidCallback onApp;
  final VoidCallback onSell;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final copy = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(l10n.ldHeroEyebrow,
            style: AppText.eyebrow(color: AppColors.accent700)),
        const SizedBox(height: 16),
        Text(l10n.ldHeroTitle,
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: AppText.heading(wide ? 54 : 40, height: 1.02)),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            l10n.ldHeroBody,
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: AppText.body(18, height: 1.55, color: AppColors.ink(0.7)),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(
              width: 220,
              child: AppButton(label: l10n.ldOpenApp, onPressed: onApp)),
          SizedBox(
            width: 220,
            child: AppButton(
                label: l10n.ldSell,
                variant: AppButtonVariant.secondary,
                onPressed: onSell),
          ),
        ]),
      ],
    );
    final art = _HeroArt();
    return _wrap(
      context,
      Padding(
        padding: EdgeInsets.only(top: wide ? 40 : 24, bottom: wide ? 56 : 36),
        child: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(child: copy),
                const SizedBox(width: 48),
                Expanded(child: art),
              ])
            : Column(children: [copy, const SizedBox(height: 36), art]),
      ),
    );
  }
}

class _HeroArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // A calm branded panel (real photography comes later).
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
            child: Text('MS', style: AppText.heading(40, color: AppColors.bg)),
          ),
        ),
      ),
    );
  }
}

// ---- Trust strip -----------------------------------------------------------
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = [
      l10n.ldTrust1,
      l10n.ldTrust2,
      l10n.ldTrust3,
      l10n.ldTrust4,
    ];
    return _wrap(
      context,
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 22,
          runSpacing: 12,
          children: [
            for (final t in items)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline,
                    size: 18, color: AppColors.accent2700),
                const SizedBox(width: 8),
                Text(t, style: AppText.body(14, color: AppColors.ink(0.75))),
              ]),
          ],
        ),
      ),
    );
  }
}

// ---- Features --------------------------------------------------------------
class _Features extends StatelessWidget {
  const _Features({required this.wide});
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = [
      (Icons.pets_outlined, l10n.ldFeat1Title, l10n.ldFeat1Body),
      (Icons.event_available_outlined, l10n.ldFeat2Title, l10n.ldFeat2Body),
      (Icons.storefront_outlined, l10n.ldFeat3Title, l10n.ldFeat3Body),
      (Icons.shield_outlined, l10n.ldFeat4Title, l10n.ldFeat4Body),
      (Icons.groups_outlined, l10n.ldFeat5Title, l10n.ldFeat5Body),
      (Icons.translate_outlined, l10n.ldFeat6Title, l10n.ldFeat6Body),
    ];
    final cols = wide ? 3 : 1;
    return _wrap(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.ldFeaturesTitle, style: AppText.heading(wide ? 34 : 28)),
          const SizedBox(height: 24),
          _Grid(
            cols: cols,
            children: [
              for (final f in items)
                _FeatureCard(icon: f.$1, title: f.$2, body: f.$3),
            ],
          ),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 26, color: AppColors.accent700),
        const SizedBox(height: 14),
        Text(title, style: AppText.heading(19)),
        const SizedBox(height: 8),
        Text(body, style: AppText.body(14, height: 1.5, color: AppColors.ink(0.65))),
      ]),
    );
  }
}

// ---- Audiences -------------------------------------------------------------
class _Audiences extends StatelessWidget {
  const _Audiences(
      {required this.wide, required this.onApp, required this.onSell});
  final bool wide;
  final VoidCallback onApp;
  final VoidCallback onSell;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final cards = [
      _AudienceCard(
        title: l10n.ldAudRidersTitle,
        body: l10n.ldAudRidersBody,
        cta: l10n.ldOpenApp,
        onTap: onApp,
        primary: true,
      ),
      _AudienceCard(
        title: l10n.ldAudSellersTitle,
        body: l10n.ldAudSellersBody,
        cta: l10n.ldSell,
        onTap: onSell,
      ),
    ];
    return _wrap(
      context,
      Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: wide
            ? Row(children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 20),
                Expanded(child: cards[1]),
              ])
            : Column(children: [
                cards[0],
                const SizedBox(height: 16),
                cards[1],
              ]),
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard(
      {required this.title,
      required this.body,
      required this.cta,
      required this.onTap,
      this.primary = false});
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: primary ? AppColors.accent2200 : AppColors.surface,
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.heading(24)),
        const SizedBox(height: 10),
        Text(body, style: AppText.body(15, height: 1.55, color: AppColors.ink(0.7))),
        const SizedBox(height: 20),
        AppButton(
          label: cta,
          block: false,
          variant: primary ? AppButtonVariant.primary : AppButtonVariant.secondary,
          onPressed: onTap,
        ),
      ]),
    );
  }
}

// ---- How it works ----------------------------------------------------------
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.wide});
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final steps = [
      ('1', l10n.ldStep1Title, l10n.ldStep1Body),
      ('2', l10n.ldStep2Title, l10n.ldStep2Body),
      ('3', l10n.ldStep3Title, l10n.ldStep3Body),
    ];
    return _wrap(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.ldHowTitle, style: AppText.heading(wide ? 34 : 28)),
          const SizedBox(height: 24),
          _Grid(
            cols: wide ? 3 : 1,
            children: [
              for (final s in steps)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle),
                          child: Text(s.$1,
                              style: AppText.heading(18, color: AppColors.bg)),
                        ),
                        const SizedBox(height: 14),
                        Text(s.$2, style: AppText.heading(19)),
                        const SizedBox(height: 8),
                        Text(s.$3,
                            style: AppText.body(14,
                                height: 1.5, color: AppColors.ink(0.65))),
                      ]),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ---- CTA band --------------------------------------------------------------
class _CtaBand extends StatelessWidget {
  const _CtaBand({required this.onApp, required this.onSell});
  final VoidCallback onApp;
  final VoidCallback onSell;
  @override
  Widget build(BuildContext context) {
    return _wrap(
      context,
      Container(
        margin: const EdgeInsets.symmetric(vertical: 28),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          Text(AppL10n.of(context).ldCtaTitle,
              textAlign: TextAlign.center,
              style: AppText.heading(30, color: AppColors.neutral100)),
          const SizedBox(height: 10),
          Text(AppL10n.of(context).ldCtaBody,
              textAlign: TextAlign.center,
              style: AppText.body(16, color: AppColors.neutral300)),
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            SizedBox(
                width: 220,
                child: AppButton(
                    label: AppL10n.of(context).ldOpenApp, onPressed: onApp)),
            SizedBox(
                width: 220,
                child: AppButton(
                    label: AppL10n.of(context).ldSell,
                    variant: AppButtonVariant.secondary,
                    onPressed: onSell)),
          ]),
        ]),
      ),
    );
  }
}

// ---- Footer ----------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer({required this.onAdmin});
  final VoidCallback onAdmin;
  @override
  Widget build(BuildContext context) {
    return _wrap(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(children: [
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const _Logo(),
              Text(AppL10n.of(context).ldCopyright,
                  style: AppText.body(13, color: AppColors.ink(0.5))),
              GestureDetector(
                onTap: onAdmin,
                child: Text(AppL10n.of(context).ldOperatorSignIn,
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ---- Responsive grid -------------------------------------------------------
class _Grid extends StatelessWidget {
  const _Grid({required this.cols, required this.children});
  final int cols;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    if (cols == 1) {
      return Column(
        children: [
          for (final c in children) ...[c, const SizedBox(height: 14)],
        ],
      );
    }
    const gap = 20.0;
    return LayoutBuilder(builder: (context, cns) {
      final cardW = (cns.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final c in children) SizedBox(width: cardW, child: c),
        ],
      );
    });
  }
}

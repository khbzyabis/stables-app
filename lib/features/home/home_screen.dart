import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/stable_store.dart';
import '../../l10n/app_localizations.dart';
import '../../models/horse.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/bottom_tab_bar.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../horses/add_horse_screen.dart';
import '../horses/horse_profile_screen.dart';

/// Screen 06 — Home. Leads with My horses; a four-tab bar switches to the
/// noticeboard, the stable, and you. Home leads with horses because that is
/// what every role recognises first.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _tab = AppTab.horses;

  String _titleFor(AppL10n l10n) => switch (_tab) {
        AppTab.horses => l10n.titleMyHorses,
        AppTab.board => l10n.titleNoticeboard,
        AppTab.stable => l10n.titleTheStable,
        AppTab.you => l10n.titleYou,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final store = StableScope.of(context);
    final day = DateFormat.EEEE(Localizations.localeOf(context).toString())
        .format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.stableAndDay(store.stableName, day),
                          style: AppText.eyebrow(color: AppColors.accent700),
                        ),
                        const SizedBox(height: 10),
                        Text(_titleFor(l10n),
                            style: AppText.heading(40, height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _Avatar(initial: 'A'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                child: switch (_tab) {
                  AppTab.horses => _HorsesTab(store: store),
                  AppTab.board => const _BoardTab(),
                  AppTab.stable => _ComingSoonTab(text: l10n.stableTabHint),
                  AppTab.you => const _YouTab(),
                },
              ),
            ),
            BottomTabBar(
              current: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent2300,
        shape: BoxShape.circle,
      ),
      child: Text(initial,
          style: AppText.heading(17, color: AppColors.accent2900)),
    );
  }
}

class _HorsesTab extends StatelessWidget {
  const _HorsesTab({required this.store});
  final StableStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Hairline(),
        for (final horse in store.horses) ...[
          _HorseRow(horse: horse),
          const Hairline(),
        ],
        const SizedBox(height: 26),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _TextAction(
            label: '+ ${l10n.addAHorse}',
            onTap: () => Navigator.of(context).pushNamed(AddHorseScreen.route),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _HorseRow extends StatelessWidget {
  const _HorseRow({required this.horse});
  final Horse horse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final well = horse.status == HorseStatus.well;
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(HorseProfileScreen.route, arguments: horse.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const PhotoPlaceholder(size: 66),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(horse.name, style: AppText.heading(23, height: 1.1)),
                  if (horse.statusLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(horse.statusLine,
                        style: AppText.body(15, color: AppColors.ink(0.6))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppTag(
              well ? l10n.statusWell : l10n.statusWatch,
              tone: well ? TagTone.sage : TagTone.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardTab extends StatelessWidget {
  const _BoardTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    // Sample notices (content, not chrome — server data in production).
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Hairline(),
        _Notice(
          meta: 'Pinned · Layal, stable manager',
          metaColor: AppColors.accent700,
          title: 'Arena closed Friday morning',
          body: 'Surface being levelled from 8 until noon. Turnout as normal.',
        ),
        const Hairline(),
        _Notice(
          meta: '2 hours ago · Toni',
          body: 'Anyone lost a navy headcollar? It is on the tack room hook.',
        ),
        const Hairline(),
        _Notice(
          meta: 'Yesterday · Layal',
          body: 'Hay delivery Wednesday — please keep the top gateway clear.',
        ),
        const Hairline(),
        const SizedBox(height: 26),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _TextAction(label: '+ ${l10n.postANotice}', onTap: () {}),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.meta,
    this.title,
    required this.body,
    this.metaColor,
  });
  final String meta;
  final String? title;
  final String body;
  final Color? metaColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meta,
              style: AppText.body(13,
                  color: metaColor ?? AppColors.ink(0.5))),
          const SizedBox(height: 7),
          if (title != null) ...[
            Text(title!, style: AppText.heading(23, height: 1.2)),
            const SizedBox(height: 6),
          ],
          Text(body,
              style: AppText.body(16, height: 1.5, color: AppColors.ink(0.85))),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        AppTag(l10n.comingSoon.toUpperCase(), tone: TagTone.neutral),
        const SizedBox(height: 16),
        Text(text,
            style: AppText.body(17, height: 1.5, color: AppColors.ink(0.6))),
      ],
    );
  }
}

/// The "You" tab hosts the live language switcher for now.
class _YouTab extends StatelessWidget {
  const _YouTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;
    final languages = <(String, String)>[
      ('en', l10n.langEnglish),
      ('ar', l10n.langArabic),
      ('hi', l10n.langHindi),
      ('ur', l10n.langUrdu),
      ('bn', l10n.langBengali),
      ('ne', l10n.langNepali),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(l10n.language.toUpperCase(), style: AppText.eyebrow()),
        const SizedBox(height: 12),
        HairlineList(
          children: [
            for (final (code, name) in languages)
              InkWell(
                onTap: () => controller.setLocale(Locale(code)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: AppText.heading(19,
                                weight: code == current
                                    ? FontWeight.w600
                                    : FontWeight.w500)),
                      ),
                      if (code == 'ar' || code == 'ur') ...[
                        const AppTag('RTL', tone: TagTone.neutral),
                        const SizedBox(width: 12),
                      ],
                      if (code == current)
                        const Icon(Icons.check,
                            color: AppColors.accent2600, size: 22),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: AppText.body(16, color: AppColors.accent700)),
    );
  }
}

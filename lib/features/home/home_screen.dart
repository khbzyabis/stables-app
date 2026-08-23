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
import '../horses/horse_record_screen.dart';
import '../horses/tack_box_screen.dart';
import '../board/board_screen.dart';
import '../board/noticeboard_screen.dart';
import '../board/post_notice_screen.dart';
import '../settings/contacts_screen.dart';
import '../settings/help_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/stable_settings_screen.dart';
import '../market/market_screen.dart';
import '../market/payments_screen.dart';
import '../people/approvals_screen.dart';
import '../people/my_stables_screen.dart';
import '../people/people_screen.dart';
import '../schedule/schedule_screen.dart';
import '../transport/request_transport_screen.dart';
import '../tasks/groom_day_screen.dart';
import '../tasks/task_progress_screen.dart';

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
                  AppTab.stable => const _StableTab(),
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

    if (store.status == LoadStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2.4,
          ),
        ),
      );
    }
    if (store.status == LoadStatus.error) {
      return _ErrorState(message: store.error, onRetry: store.load);
    }

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
      // A horse with a filled-in record opens the record hub; a freshly
      // added one opens its honest empty profile.
      onTap: () => Navigator.of(context).pushNamed(
        horse.hasDetails ? HorseRecordScreen.route : HorseProfileScreen.route,
        arguments: horse.id,
      ),
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
          child: _TextAction(
            label: '+ ${l10n.postANotice}',
            onTap: () =>
                Navigator.of(context).pushNamed(PostNoticeScreen.route),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _TextAction(
            label: l10n.titleNoticeboard,
            onTap: () =>
                Navigator.of(context).pushNamed(NoticeboardScreen.route),
          ),
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

/// The Stable tab — the stable-wide views. The schedule is live; people,
/// contacts and settings follow.
class _StableTab extends StatelessWidget {
  const _StableTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Hairline(),
        _NavRow(
          title: l10n.openSchedule,
          subtitle: l10n.scheduleSub,
          onTap: () => Navigator.of(context).pushNamed(ScheduleScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.openTasks,
          subtitle: l10n.tasksSub,
          onTap: () => Navigator.of(context).pushNamed(TaskProgressScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.yourTasks,
          subtitle: l10n.ticksVisible,
          onTap: () => Navigator.of(context).pushNamed(GroomDayScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.market,
          subtitle: l10n.marketSub,
          onTap: () => Navigator.of(context).pushNamed(MarketScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.transport,
          subtitle: l10n.transportSub,
          onTap: () =>
              Navigator.of(context).pushNamed(RequestTransportScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.people,
          subtitle: l10n.peopleNavSub,
          onTap: () => Navigator.of(context).pushNamed(PeopleScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.needsYou,
          subtitle: l10n.nothingJoins,
          onTap: () => Navigator.of(context).pushNamed(ApprovalsScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.contacts,
          subtitle: 'Farrier, vet, dentist, feed merchant',
          onTap: () => Navigator.of(context).pushNamed(ContactsScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.stableSettings,
          subtitle: 'Dubai · 14 horses · 6 people',
          onTap: () =>
              Navigator.of(context).pushNamed(StableSettingsScreen.route),
        ),
        const Hairline(),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow(
      {required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.heading(23, height: 1.1)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppText.body(15, color: AppColors.ink(0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
          ],
        ),
      ),
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
        const Hairline(),
        _NavRow(
          title: l10n.yourProfile,
          subtitle: 'ahmad@serc.ae',
          onTap: () => Navigator.of(context).pushNamed(ProfileScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.myStables,
          subtitle: l10n.rolePerStable,
          onTap: () => Navigator.of(context).pushNamed(MyStablesScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.tackBox,
          subtitle: '9 items across 7 groups',
          onTap: () => Navigator.of(context).pushNamed(TackBoxScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.payments,
          subtitle: l10n.paymentsSub,
          onTap: () => Navigator.of(context).pushNamed(PaymentsScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.help,
          subtitle: 'Answers, or tell us what is wrong',
          onTap: () => Navigator.of(context).pushNamed(HelpScreen.route),
        ),
        const Hairline(),
        _NavRow(
          title: l10n.notices,
          subtitle: 'From My Stables — shows, updates and adverts',
          onTap: () => Navigator.of(context).pushNamed(BoardScreen.route),
        ),
        const Hairline(),
        const SizedBox(height: 30),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text("Couldn't reach the stable",
            style: AppText.heading(23, height: 1.1)),
        const SizedBox(height: 8),
        Text(
          message ?? 'Check your connection and try again.',
          style: AppText.body(15, color: AppColors.ink(0.6)),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => onRetry(),
          child: Text('Try again',
              style: AppText.heading(17, color: AppColors.accent700)),
        ),
      ],
    );
  }
}

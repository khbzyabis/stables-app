import 'package:flutter/material.dart';

import '../../data/nav.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/bottom_tab_bar.dart';
import 'stable_switcher.dart';

/// The desktop chrome for the signed-in rider app. On a wide (laptop) browser
/// the app is presented as a real web app — a persistent left sidebar for
/// navigation and a comfortable centred content column on the warm ground —
/// instead of a phone-shaped panel. On phones this is never used; the native
/// bottom-tab layout renders as before.
///
/// The sidebar lives above the Navigator, so it stays in place while detail
/// pages (a horse record, the schedule, …) open in the content area. Selecting
/// a tab returns to Home and switches [homeTab].
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.child,
    required this.onSelect,
    required this.onProfile,
  });

  /// The current Navigator output (the active page) shown in the content area.
  final Widget child;

  /// Switch to a home tab (and return to Home if a detail page is open).
  final void Function(AppTab) onSelect;

  /// Open the profile / account screen.
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return ColoredBox(
      color: AppColors.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            session: session,
            onSelect: onSelect,
            onProfile: onProfile,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caps a mobile-designed detail page (a horse record, the schedule, an order)
/// to a comfortable centred width on a wide desktop, so pushed pages inside the
/// desktop shell read as a focused column instead of stretching. On phones and
/// narrow viewports it passes the child through untouched.
class DesktopCap extends StatelessWidget {
  const DesktopCap({super.key, required this.child, this.maxWidth = 780});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth <= maxWidth) return child;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.session,
    required this.onSelect,
    required this.onProfile,
  });

  final AppSession session;
  final void Function(AppTab) onSelect;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final name = SupabaseService.displayName;
    final initial =
        name.characters.isEmpty ? 'S' : name.characters.first.toUpperCase();
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand + stable.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Text('My Stables',
                          style: AppText.heading(20, height: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showStableSwitcher(context),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('STABLE',
                                      style: AppText.body(10,
                                          weight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: AppColors.ink(0.45))),
                                  const SizedBox(height: 2),
                                  Text(
                                    session.activeStableName.isEmpty
                                        ? 'Your stable'
                                        : session.activeStableName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.heading(15, height: 1.1),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.unfold_more_rounded,
                                size: 19, color: AppColors.ink(0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Nav.
            Expanded(
              child: ValueListenableBuilder<AppTab>(
                valueListenable: homeTab,
                builder: (context, current, _) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _NavItem(
                        label: 'Home',
                        icon: Icons.home_rounded,
                        active: current == AppTab.home,
                        onTap: () => onSelect(AppTab.home),
                      ),
                      _NavItem(
                        label: 'Horses',
                        iconBuilder: (c, s) =>
                            AppTabIcon.horses(color: c, size: s),
                        active: current == AppTab.horses,
                        onTap: () => onSelect(AppTab.horses),
                      ),
                      _NavItem(
                        label: 'Board',
                        iconBuilder: (c, s) =>
                            AppTabIcon.board(color: c, size: s),
                        active: current == AppTab.board,
                        onTap: () => onSelect(AppTab.board),
                      ),
                      _NavItem(
                        label: 'Market',
                        icon: Icons.storefront_outlined,
                        active: current == AppTab.market,
                        onTap: () => onSelect(AppTab.market),
                      ),
                      _NavItem(
                        label: 'You',
                        iconBuilder: (c, s) => AppTabIcon.me(color: c, size: s),
                        active: current == AppTab.you,
                        onTap: () => onSelect(AppTab.you),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Profile.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onProfile,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.accent200,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(initial,
                            style: AppText.heading(15,
                                color: AppColors.accent800, height: 1)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name.isEmpty ? 'You' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(15, weight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: AppColors.ink(0.4)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.iconBuilder,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget Function(Color color, double size)? iconBuilder;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent800 : AppColors.ink(0.7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.accent100 : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                icon != null
                    ? Icon(icon, size: 21, color: color)
                    : iconBuilder!(color, 21),
                const SizedBox(width: 13),
                Text(
                  label,
                  style: AppText.body(16,
                      weight: active ? FontWeight.w600 : FontWeight.w500,
                      color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

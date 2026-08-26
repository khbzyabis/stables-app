import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'app_icons.dart';

enum AppTab { home, horses, board, stable, market, you }

/// The floating dark tab bar: a rounded pill with five tabs. The active tab is
/// an oval terracotta capsule. Home leads; Horses, Board, Stable and You follow.
class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    super.key,
    required this.current,
    required this.onChanged,
    this.showLabels = true,
  });

  final AppTab current;
  final ValueChanged<AppTab> onChanged;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
                color: Color(0x42140E06), blurRadius: 40, offset: Offset(0, 18)),
          ],
        ),
        padding: const EdgeInsets.all(7),
        child: Row(
          children: [
            _item(AppTab.home, 'Home'),
            _item(AppTab.horses, 'Horses'),
            _item(AppTab.board, 'Board'),
            _item(AppTab.market, 'Market'),
            _item(AppTab.you, 'You'),
          ],
        ),
      ),
    );
  }

  Widget _item(AppTab tab, String label) {
    final active = tab == current;
    final color = active ? Colors.white : const Color(0xFF948B7D);
    final Widget icon = switch (tab) {
      AppTab.home => Icon(Icons.home_rounded, size: 22, color: color),
      AppTab.horses => AppTabIcon.horses(color: color, size: 22),
      AppTab.board => AppTabIcon.board(color: color, size: 22),
      AppTab.stable => AppTabIcon.stable(color: color, size: 22),
      AppTab.market => Icon(Icons.storefront_outlined, size: 22, color: color),
      AppTab.you => AppTabIcon.me(color: color, size: 22),
    };
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFCF7A41), AppColors.accent])
                : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x738C491A),
                        blurRadius: 14,
                        offset: Offset(0, 6)),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                offset: active ? const Offset(0, -0.05) : Offset.zero,
                child: icon,
              ),
              if (showLabels) ...[
                const SizedBox(height: 7),
                Text(label,
                    style:
                        AppText.body(10, color: color, letterSpacing: 0.4)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'app_icons.dart';

enum AppTab { home, horses, board, stable, you }

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
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33140E06), blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _item(AppTab.home, 'Home'),
            _item(AppTab.horses, 'Horses'),
            _item(AppTab.board, 'Board'),
            _item(AppTab.stable, 'Stable'),
            _item(AppTab.you, 'You'),
          ],
        ),
      ),
    );
  }

  Widget _item(AppTab tab, String label) {
    final active = tab == current;
    final color = active ? Colors.white : const Color(0xFFA79F91);
    final Widget icon = switch (tab) {
      AppTab.home => Icon(Icons.home_rounded, size: 23, color: color),
      AppTab.horses => AppTabIcon.horses(color: color, size: 23),
      AppTab.board => AppTabIcon.board(color: color, size: 23),
      AppTab.stable => AppTabIcon.stable(color: color, size: 23),
      AppTab.you => AppTabIcon.me(color: color, size: 23),
    };
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              if (showLabels) ...[
                const SizedBox(height: 5),
                Text(label, style: AppText.body(11, color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

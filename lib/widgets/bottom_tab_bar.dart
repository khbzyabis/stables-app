import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'app_icons.dart';

enum AppTab { horses, board, stable, you }

/// The four-tab bar: Horses (two horseshoes), Board (speech bubble),
/// Stable (barn), You (person). A fifth "Shows" item appears only when the
/// operator has enabled the Shows feature flag (not shown in this foundation).
/// Active tint is accent-700; inactive is ink at 45%.
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
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      child: Row(
        children: [
          _item(AppTab.horses, 'Horses'),
          _item(AppTab.board, 'Board'),
          _item(AppTab.stable, 'Stable'),
          _item(AppTab.you, 'You'),
        ],
      ),
    );
  }

  Widget _item(AppTab tab, String label) {
    final active = tab == current;
    final color = active ? AppColors.accent700 : AppColors.ink(0.45);
    final Widget icon = switch (tab) {
      AppTab.horses => AppTabIcon.horses(color: color),
      AppTab.board => AppTabIcon.board(color: color),
      AppTab.stable => AppTabIcon.stable(color: color),
      AppTab.you => AppTabIcon.me(color: color),
    };
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(tab),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (showLabels) ...[
                const SizedBox(height: 6),
                Text(label, style: AppText.body(11, color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

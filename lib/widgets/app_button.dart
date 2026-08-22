import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// Pill button. Label uses Gabarito (the heading face), matching `.btn` in the
/// design system. Terracotta primary is the single action on a screen.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.block = true,
    this.minHeight = 58,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool block;
  final double minHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    late final Color bg;
    late final Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.accent;
        fg = AppColors.bg;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.text;
        side = BorderSide(color: AppColors.divider);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.accent700;
    }

    final child = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: fg, size: 18),
            child: icon!,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: AppText.heading(
            fontSize,
            weight: variant == AppButtonVariant.secondary
                ? FontWeight.w500
                : FontWeight.w600,
            color: fg,
            height: 1.2,
            letterSpacing: -0.01,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: bg,
        shape: StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

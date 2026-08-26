import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A warm-white rounded card — the shared surface for list items and grouped
/// content across the app. Matches the home hub cards so every screen reads as
/// one coherent "mini app" rather than a mix of flat rows and cards.
///
/// Pass [onTap] to make it tappable (ripple included); leave it null for a
/// static container. [padding] defaults to a comfortable list-row inset.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    this.radius = 18,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: shape,
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: AppColors.warmWhite,
      borderRadius: shape,
      child: InkWell(borderRadius: shape, onTap: onTap, child: content),
    );
  }
}

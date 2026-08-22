import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A grey placeholder standing in for photography, which has not been produced.
/// Neutral-300 fill with neutral-700 uppercase label, per the design.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.size = 66,
    this.circle = true,
    this.label = 'Photo',
    this.radius = AppRadius.md,
  });

  final double size;
  final bool circle;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: AppText.body(10,
            weight: FontWeight.w500,
            color: AppColors.neutral700,
            letterSpacing: 0.6),
      ),
    );
  }
}

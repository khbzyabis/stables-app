import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A photo slot. When [url] is set it shows that image; otherwise it falls back
/// to a neutral grey placeholder with an uppercase label, per the design.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.size = 66,
    this.circle = true,
    this.label = 'Photo',
    this.radius = AppRadius.md,
    this.url,
  });

  final double size;
  final bool circle;
  final String label;
  final double radius;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
    final borderRadius = circle
        ? BorderRadius.circular(size)
        : BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
        child: hasImage
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => _label(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _label(),
              )
            : _label(),
      ),
    );
  }

  Widget _label() => Center(
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

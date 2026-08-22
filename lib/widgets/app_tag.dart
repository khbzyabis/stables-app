import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum TagTone { accent, sage, neutral, outline }

/// A small pill tag. Sage means settled / healthy / confirmed;
/// terracotta means act or attention.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.tone = TagTone.neutral});

  final String label;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    Border? border;

    switch (tone) {
      case TagTone.accent:
        bg = AppColors.accent100;
        fg = AppColors.accent800;
      case TagTone.sage:
        bg = AppColors.accent2100;
        fg = AppColors.accent2800;
      case TagTone.neutral:
        bg = AppColors.neutral100;
        fg = AppColors.neutral800;
      case TagTone.outline:
        bg = const Color(0x00000000);
        fg = AppColors.accent;
        border = Border.all(color: AppColors.accent);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.md * 0.75),
      ),
      child: Text(label, style: AppText.tag(color: fg)),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// The muted "← Back" link used across onboarding. The arrow mirrors for RTL.
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Text(
        '${isRtl ? '→' : '←'} $label',
        style: AppText.body(15, color: AppColors.ink(0.55)),
      ),
    );
  }
}

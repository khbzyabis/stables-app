import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// The three-segment progress bar used through onboarding (screens 3–5).
/// Filled segments are terracotta; the rest are neutral-300.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.total,
    required this.current,
  });

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < current ? AppColors.accent : AppColors.neutral300,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

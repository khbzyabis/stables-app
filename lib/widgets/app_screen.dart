import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Standard mobile screen chrome: the warm page ground, the design's screen
/// padding (32px horizontal, 84px top below the status bar, 44px bottom), and a
/// safe area. The iPhone bezel from the prototype is presentation only and is
/// deliberately not reproduced.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.scrollable = false,
    this.padding,
  });

  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        const EdgeInsets.fromLTRB(
          AppSpace.screenH,
          AppSpace.screenTop,
          AppSpace.screenH,
          AppSpace.screenBottom,
        );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: scrollable
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(padding: pad, child: child),
                    ),
                  );
                },
              )
            : Padding(padding: pad, child: child),
      ),
    );
  }
}

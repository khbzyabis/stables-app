import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'sign_in_screen.dart';

/// Screen 01 — Splash. Wordmark, sage and terracotta circles, three pulsing
/// dots. Tapping anywhere advances to sign in (the prototype behaviour).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(SignInScreen.route),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Decorative organic circles, mirrored for RTL via Directional.
            PositionedDirectional(
              top: -120,
              end: -150,
              child: _circle(420, AppColors.accent2200),
            ),
            PositionedDirectional(
              top: 150,
              end: 60,
              child: _circle(132, AppColors.accent300),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // The wordmark's ring motif — an open ring (the bottom
                    // edge is transparent, as in the prototype).
                    Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 34),
                      child: CustomPaint(
                        painter: _OpenRingPainter(),
                      ),
                    ),
                    Text(
                      l10n.appName,
                      style: AppText.heading(56, height: 0.95),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        l10n.splashTagline,
                        style: AppText.body(
                          19,
                          height: 1.45,
                          color: AppColors.ink(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),
                    _PulsingDots(controller: _controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// An open terracotta ring: a 5px stroke that leaves the bottom arc open,
/// matching the prototype's `border-bottom-color: transparent`.
class _OpenRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final rect = Offset(2.5, 2.5) &
        Size(size.width - 5, size.height - 5);
    // Sweep from top, leaving a gap at the bottom (~50°).
    const start = -1.3; // radians, roughly top-right
    const sweep = 4.7; // ~270°+, open at the bottom
    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingDots extends StatelessWidget {
  const _PulsingDots({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          _Dot(controller: controller, delay: i * 0.13),
          if (i != 2) const SizedBox(width: 9),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.controller, required this.delay});
  final AnimationController controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + delay) % 1.0;
        // Ease in/out around the midpoint.
        final phase = (0.5 - (t - 0.5).abs()) * 2; // 0→1→0
        final opacity = 0.25 + 0.75 * phase;
        final dy = -3 * phase;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

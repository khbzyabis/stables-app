import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The two custom marks from the design (two horseshoes for Horses, a barn for
/// Stable), plus stroked Board and Person marks, drawn to match the
/// prototype's Lucide-style 24×24 paths at stroke-width ~2.2–2.75.
class AppTabIcon extends StatelessWidget {
  const AppTabIcon.horses({super.key, this.color, this.size = 25})
      : _kind = _Kind.horses;
  const AppTabIcon.board({super.key, this.color, this.size = 25})
      : _kind = _Kind.board;
  const AppTabIcon.stable({super.key, this.color, this.size = 25})
      : _kind = _Kind.stable;
  const AppTabIcon.me({super.key, this.color, this.size = 25})
      : _kind = _Kind.me;

  final _Kind _kind;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF201E1D);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IconPainter(_kind, c)),
    );
  }
}

enum _Kind { horses, board, stable, me }

class _IconPainter extends CustomPainter {
  _IconPainter(this.kind, this.color);
  final _Kind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0; // paths are authored on a 24×24 grid
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      case _Kind.horses:
        paint.strokeWidth = 2.4 * s;
        // A single horseshoe: an arch over the top with two short feet, open at
        // the bottom — reads clearly as a horseshoe (not two bumps).
        canvas.drawArc(
          Rect.fromCircle(center: Offset(12 * s, 15 * s), radius: 7 * s),
          math.pi,
          math.pi,
          false,
          paint,
        );
        canvas.drawLine(Offset(5 * s, 15 * s), Offset(5 * s, 20 * s), paint);
        canvas.drawLine(Offset(19 * s, 15 * s), Offset(19 * s, 20 * s), paint);
      case _Kind.board:
        paint.strokeWidth = 2.75 * s;
        final p = Path()
          ..moveTo(21 * s, 15 * s)
          ..cubicTo(21 * s, 16.1 * s, 20.1 * s, 17 * s, 19 * s, 17 * s)
          ..lineTo(8 * s, 17 * s)
          ..lineTo(3 * s, 21 * s)
          ..lineTo(3 * s, 5 * s)
          ..cubicTo(3 * s, 3.9 * s, 3.9 * s, 3 * s, 5 * s, 3 * s)
          ..lineTo(19 * s, 3 * s)
          ..cubicTo(20.1 * s, 3 * s, 21 * s, 3.9 * s, 21 * s, 5 * s)
          ..close();
        canvas.drawPath(p, paint);
      case _Kind.stable:
        paint.strokeWidth = 2.4 * s;
        // Barn: pitched roof, a floor line, and doors.
        final roof = Path()
          ..moveTo(3 * s, 10.5 * s)
          ..lineTo(12 * s, 4 * s)
          ..lineTo(21 * s, 10.5 * s)
          ..lineTo(21 * s, 21 * s)
          ..lineTo(3 * s, 21 * s)
          ..close();
        canvas.drawPath(roof, paint);
        canvas.drawLine(Offset(3 * s, 13.8 * s), Offset(21 * s, 13.8 * s), paint);
        final door = Path()
          ..moveTo(9.3 * s, 21 * s)
          ..lineTo(9.3 * s, 15.8 * s)
          ..lineTo(14.7 * s, 15.8 * s)
          ..lineTo(14.7 * s, 21 * s);
        canvas.drawPath(door, paint);
      case _Kind.me:
        paint.strokeWidth = 2.75 * s;
        canvas.drawCircle(Offset(12 * s, 8 * s), 4 * s, paint);
        final body = Path()
          ..moveTo(4 * s, 21 * s)
          ..cubicTo(4 * s, 17 * s, 7.6 * s, 15 * s, 12 * s, 15 * s)
          ..cubicTo(16.4 * s, 15 * s, 20 * s, 17 * s, 20 * s, 21 * s);
        canvas.drawPath(body, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.kind != kind || old.color != color;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

class PetalData {
  final double size;
  final double speed;
  final double drift;
  final double rotation;
  final double startDelay;
  final Color color;
  final double horizontalOffset;

  PetalData({
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.startDelay,
    required this.color,
    required this.horizontalOffset,
  });
}

class PetalsPainter extends CustomPainter {
  final Animation<double> animation;
  final List<PetalData> petals;

  PetalsPainter({required this.animation, required this.petals})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var petal in petals) {
      final double progress =
          (animation.value * petal.speed + petal.startDelay) % 1.0;

      // X: starts from RIGHT edge, moves to LEFT edge
      final double x =
          size.width -
          (progress * (size.width + 80)) +
          math.sin(progress * math.pi * 2) * petal.drift * 0.3;

      // Y: stays roughly at same height with gentle wave
      final double y =
          petal.horizontalOffset * size.height +
          math.sin(progress * math.pi * 3) * petal.drift * 0.4;

      final double rotation = petal.rotation + (progress * math.pi * 2);

      final Paint paint = Paint()
        ..color = petal.color.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 1.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PetalsPainter oldDelegate) => true;
}

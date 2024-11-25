import 'dart:math';

import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double value;

  GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;

    final pointerPaint = Paint()
      ..color = Color(0xFFF86767)
      ..style = PaintingStyle.fill
      ..strokeWidth = 6; // 바늘의 두께를 더 두껍게 설정

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height);

    // Draw the gauge background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14, // Start angle (180 degrees)
      3.14, // Sweep angle (180 degrees)
      false,
      paint,
    );

    // Calculate the pointer angle for value in range [0, 180]
    final normalizedValue = (value / 180).clamp(0.0, 1.0); // Normalize to [0, 1]
    final angle = 3.14 + (3.14 * normalizedValue); // Scale to 180 degrees

    final pointerLength = radius - 10;

    final pointerEnd = Offset(
      center.dx + pointerLength * cos(angle),
      center.dy + pointerLength * sin(angle),
    );

    // Draw the pointer
    canvas.drawLine(center, pointerEnd, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint on value change
  }
}

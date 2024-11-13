import 'package:flutter/material.dart';

class SpeedChartPainter extends CustomPainter {
  final List<double> speedData;

  SpeedChartPainter({required this.speedData});

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    double maxSpeed = speedData.reduce((a, b) => a > b ? a : b);
    double minSpeed = speedData.reduce((a, b) => a < b ? a : b);
    double scaleX = size.width / speedData.length;
    double scaleY = size.height / (maxSpeed - minSpeed);

    Path path = Path();
    for (int i = 0; i < speedData.length; i++) {
      double x = i * scaleX;
      double y = size.height - (speedData[i] - minSpeed) * scaleY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 2, pointPaint); // 점 그리기
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

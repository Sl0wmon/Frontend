import 'package:flutter/material.dart';

class PedalChartPainter extends CustomPainter {
  final List<double> brakeData;
  final List<double> accelData;

  PedalChartPainter({required this.brakeData, required this.accelData});

  @override
  void paint(Canvas canvas, Size size) {
    Paint brakePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint accelPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double scaleX = size.width / brakeData.length;
    double scaleY = size.height;

    Path brakePath = Path();
    Path accelPath = Path();

    for (int i = 0; i < brakeData.length; i++) {
      double x = i * scaleX;
      double brakeY = size.height - brakeData[i] * scaleY;
      double accelY = size.height - accelData[i] * scaleY;

      if (i == 0) {
        brakePath.moveTo(x, brakeY);
        accelPath.moveTo(x, accelY);
      } else {
        brakePath.lineTo(x, brakeY);
        accelPath.lineTo(x, accelY);
      }
    }

    canvas.drawPath(brakePath, brakePaint);
    canvas.drawPath(accelPath, accelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

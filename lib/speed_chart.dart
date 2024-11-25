import 'package:flutter/material.dart';

class SpeedChart extends StatelessWidget {
  const SpeedChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: SpeedChartPainter(),
      ),
    );
  }
}

class SpeedChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 속도 그래프 데이터
    final speedPath = Path()
      ..moveTo(0, size.height * 0.8) // 시작점
      ..lineTo(size.width * 0.3, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.7);

    // 그래프 그리기
    canvas.drawPath(speedPath, bluePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

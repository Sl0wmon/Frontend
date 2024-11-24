import 'package:flutter/material.dart';

class PedalChart extends StatelessWidget {
  const PedalChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: PedalChartPainter(),
      ),
    );
  }
}

class PedalChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 페달 그래프 데이터
    final pedalPath = Path()
      ..moveTo(0, size.height * 0.6) // 시작점
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.2);

    final pedalPath2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.6);

    // 그래프 그리기
    canvas.drawPath(pedalPath, redPaint); // 브레이크 그래프
    canvas.drawPath(pedalPath2, bluePaint); // 엑셀러레이터 그래프
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

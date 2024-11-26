import 'package:flutter/material.dart';

class SpeedChart extends StatelessWidget {
  final List<Map<String, dynamic>> speedData;

  const SpeedChart({Key? key, required this.speedData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (speedData.isEmpty) {
      return const Center(child: Text('속도 데이터가 없습니다.'));
    }

    return CustomPaint(
      painter: SpeedChartPainter(speedData),
      size: const Size(double.infinity, 200),
    );
  }
}

class SpeedChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> speedData;

  SpeedChartPainter(this.speedData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final padding = 20.0;

    // X축 범위: speedData.length
    // Y축 범위: 속도 최대값에 맞춰서 스케일링
    double maxSpeed = speedData.map((data) => data['speed']).reduce((a, b) => a > b ? a : b);
    double minSpeed = speedData.map((data) => data['speed']).reduce((a, b) => a < b ? a : b);

    double scaleX = (size.width - 2 * padding) / (speedData.length - 1);
    double scaleY = (size.height - 2 * padding) / (maxSpeed - minSpeed);

    Path path = Path();
    for (int i = 0; i < speedData.length; i++) {
      double x = padding + i * scaleX;
      double y = size.height - padding - (speedData[i]['speed'] - minSpeed) * scaleY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // X, Y 축 그리기
    paint
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(Offset(padding, padding), Offset(padding, size.height - padding), paint); // Y축
    canvas.drawLine(Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), paint); // X축
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

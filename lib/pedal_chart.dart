import 'package:flutter/material.dart';

class PedalChart extends StatelessWidget {
  final List<Map<String, dynamic>> pedalData;

  const PedalChart({Key? key, required this.pedalData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pedalData.isEmpty) {
      return const Center(child: Text('페달 데이터가 없습니다.'));
    }

    return CustomPaint(
      painter: PedalChartPainter(pedalData),
      size: const Size(double.infinity, 200),
    );
  }
}

class PedalChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> pedalData;

  PedalChartPainter(this.pedalData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final padding = 20.0;

    // X축 범위: pedalData.length
    // Y축 범위: 0 (0%)부터 1 (100%)까지
    double scaleX = (size.width - 2 * padding) / (pedalData.length - 1);
    double scaleY = (size.height - 2 * padding) / 1.0; // 0% - 100% 구간

    Path acceleratorPath = Path();
    Path brakePath = Path();

    for (int i = 0; i < pedalData.length; i++) {
      double x = padding + i * scaleX;
      double acceleratorY = size.height - padding - pedalData[i]['accPressure'] * scaleY;
      double brakeY = size.height - padding - pedalData[i]['brakePressure'] * scaleY;

      if (i == 0) {
        acceleratorPath.moveTo(x, acceleratorY);
        brakePath.moveTo(x, brakeY);
      } else {
        acceleratorPath.lineTo(x, acceleratorY);
        brakePath.lineTo(x, brakeY);
      }
    }

    // 엑셀러레이터(파랑) 경로 그리기
    paint.color = Colors.blue;
    canvas.drawPath(acceleratorPath, paint);

    // 브레이크(빨강) 경로 그리기
    paint.color = Colors.red;
    canvas.drawPath(brakePath, paint);

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

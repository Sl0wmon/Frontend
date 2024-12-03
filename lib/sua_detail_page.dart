import 'dart:convert';
import 'package:flutter/material.dart';
import 'http_service.dart'; // HttpService 파일 경로ㅅ

class SUADetailPage extends StatefulWidget {
  final String suaid;
  const SUADetailPage({Key? key, required this.suaid}) : super(key: key);

  @override
  _SUADetailPageState createState() => _SUADetailPageState();
}

class _SUADetailPageState extends State<SUADetailPage> {
  List<Map<String, dynamic>> suaDetails = [];
  List<double> speedData = [];
  List<double> accPressureData = [];
  List<double> brakePressureData = [];
  List<double> rpmData = [];  // RPM 데이터 리스트
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    fetchSUADetail();
  }

  Future<void> fetchSUADetail() async {
    final response = await HttpService().postRequest(
      "SUARecord/timestamp/list",
      {"SUAId": widget.suaid},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == "true" && data["data"] != null) {
        setState(() {
          suaDetails = List<Map<String, dynamic>>.from(data["data"]);

          // Extract graph data
          speedData = suaDetails.map((entry) => entry['speed'] as double).toList();
          accPressureData = suaDetails.map((entry) => entry['accPressure'] as double).toList();
          brakePressureData = suaDetails.map((entry) => entry['brakePressure'] as double).toList();
          rpmData = suaDetails.map((entry) => entry['rpm'] as double).toList();  // RPM 데이터 추출

          // Calculate total distance
          totalDistance = calculateTotalDistance();
        });
      }
    } else {
      print('SUA 기록 로드 실패');
    }
  }

  double calculateTotalDistance() {
    double distance = 0.0;
    for (int i = 1; i < suaDetails.length; i++) {
      final current = suaDetails[i];
      final previous = suaDetails[i - 1];
      final speedCurrent = current['speed'] as double;
      final speedPrevious = previous['speed'] as double;
      final timeDiff = (current['timestamp'][3] - previous['timestamp'][3]) * 3600 +
          (current['timestamp'][4] - previous['timestamp'][4]) * 60 +
          (current['timestamp'][5] - previous['timestamp'][5]);
      distance += (speedCurrent + speedPrevious) / 2 * (timeDiff / 3600); // 평균 속도로 거리 계산
    }
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    if (suaDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('SUA 상세 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final averageSpeed = speedData.reduce((a, b) => a + b) / speedData.length;

    return Scaffold(
      appBar: AppBar(title: const Text('SUA 상세 정보')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '속도',
              style: TextStyle(fontSize: 24, fontFamily: 'head', color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: LineGraphPainter(speedData, Colors.blue),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '평균 속도: ${averageSpeed.toStringAsFixed(2)} km/h',
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'body'),
            ),
            const SizedBox(height: 20),

            const Text(
              '페달 기록',
              style: TextStyle(fontSize: 24, fontFamily: 'head', color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: PedalGraphPainter(
                    accPressureData,
                    brakePressureData,
                  ),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '가속 페달 (빨간색) | 브레이크 페달 (초록색)',
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'body'),
            ),

            // RPM 그래프 섹션 추가
            const SizedBox(height: 20),
            const Text(
              'RPM',
              style: TextStyle(fontSize: 24, fontFamily: 'head', color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: RPMGraphPainter(rpmData),
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineGraphPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LineGraphPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double padding = 16.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = usableWidth / (data.length - 1);
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.1); // 최댓값보다 10% 높게
    final yScale = usableHeight / maxY;

    path.moveTo(padding, size.height - padding - data[0] * yScale);
    for (int i = 1; i < data.length; i++) {
      final x = padding + i * xStep;
      final y = size.height - padding - data[i] * yScale;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // Y축
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    // X축
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    // Y축 값의 마커를 표시
    const markerCount = 5;
    final markerStep = maxY / markerCount;
    for (int i = 0; i <= markerCount; i++) {
      final yValue = markerStep * i;
      final yOffset = size.height - padding - (yValue * yScale);

      final markerTextPainter = TextPainter(
        text: TextSpan(
          text: yValue.toStringAsFixed(0),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      markerTextPainter.layout();

      markerTextPainter.paint(
        canvas,
        Offset(padding - markerTextPainter.width - 5, yOffset - markerTextPainter.height / 2),
      );

      canvas.drawLine(
        Offset(padding, yOffset),
        Offset(size.width - padding, yOffset),
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PedalGraphPainter extends CustomPainter {
  final List<double> accPressureData;
  final List<double> brakePressureData;

  PedalGraphPainter(this.accPressureData, this.brakePressureData);

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 16.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;

    final accPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final brakePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pathAcc = Path();
    final pathBrake = Path();

    final xStep = usableWidth / (accPressureData.length - 1);
    final maxY = ([
      accPressureData.reduce((a, b) => a > b ? a : b),
      brakePressureData.reduce((a, b) => a > b ? a : b)
    ].reduce((a, b) => a > b ? a : b) * 1.1);

    final yScale = usableHeight / maxY;

    pathAcc.moveTo(padding, size.height - padding - accPressureData[0] * yScale);
    pathBrake.moveTo(padding, size.height - padding - brakePressureData[0] * yScale);
    for (int i = 1; i < accPressureData.length; i++) {
      final x = padding + i * xStep;
      final yAcc = size.height - padding - accPressureData[i] * yScale;
      final yBrake = size.height - padding - brakePressureData[i] * yScale;
      pathAcc.lineTo(x, yAcc);
      pathBrake.lineTo(x, yBrake);
    }

    canvas.drawPath(pathAcc, accPaint);
    canvas.drawPath(pathBrake, brakePaint);

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    const markerCount = 5;
    final markerStep = maxY / markerCount;
    for (int i = 0; i <= markerCount; i++) {
      final yValue = markerStep * i;
      final yOffset = size.height - padding - yValue * yScale;

      final markerTextPainter = TextPainter(
        text: TextSpan(
          text: yValue.toStringAsFixed(0),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      markerTextPainter.layout();

      markerTextPainter.paint(
        canvas,
        Offset(padding - markerTextPainter.width - 5, yOffset - markerTextPainter.height / 2),
      );

      canvas.drawLine(
        Offset(padding, yOffset),
        Offset(size.width - padding, yOffset),
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RPMGraphPainter extends CustomPainter {
  final List<double> rpmData;

  RPMGraphPainter(this.rpmData);

  @override
  void paint(Canvas canvas, Size size) {
    if (rpmData.isEmpty) return;

    const double padding = 16.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = usableWidth / (rpmData.length - 1);
    final maxY = (rpmData.reduce((a, b) => a > b ? a : b) * 1.1);
    final yScale = usableHeight / maxY;

    path.moveTo(padding, size.height - padding - rpmData[0] * yScale);
    for (int i = 1; i < rpmData.length; i++) {
      final x = padding + i * xStep;
      final y = size.height - padding - rpmData[i] * yScale;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // Y축
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    // X축
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    // Y축 값의 마커를 표시
    const markerCount = 5;
    final markerStep = maxY / markerCount;
    for (int i = 0; i <= markerCount; i++) {
      final yValue = markerStep * i;
      final yOffset = size.height - padding - (yValue * yScale);

      final markerTextPainter = TextPainter(
        text: TextSpan(
          text: yValue.toStringAsFixed(0),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      markerTextPainter.layout();

      markerTextPainter.paint(
        canvas,
        Offset(padding - markerTextPainter.width - 5, yOffset - markerTextPainter.height / 2),
      );

      canvas.drawLine(
        Offset(padding, yOffset),
        Offset(size.width - padding, yOffset),
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

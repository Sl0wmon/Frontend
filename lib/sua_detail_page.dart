import 'package:flutter/material.dart';
import 'package:slomon/http_service.dart';
import 'dart:convert';

class SUADetailPage extends StatefulWidget {
  final String suaid;

  const SUADetailPage({super.key, required this.suaid});

  @override
  State<SUADetailPage> createState() => _SUADetailPageState();
}

class _SUADetailPageState extends State<SUADetailPage> {
  List<Map<String, dynamic>> suaDetails = [];
  List<double> speedData = [];
  List<double> accPressureData = [];
  List<double> brakePressureData = [];

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
        });
      }
    } else {
      print('Failed to load SUA detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (suaDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('급발진 상세 기록', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                // 알림 클릭 이벤트 처리
              },
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final averageSpeed = speedData.reduce((a, b) => a + b) / speedData.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('급발진 상세 기록', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // 알림 클릭 이벤트 처리
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('속도', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // 하얀 사각형 배경 추가, 여유 공간을 만들기 위해 padding 설정
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 배경 색
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색
                    blurRadius: 5,
                    offset: const Offset(0, 3), // 그림자 위치
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0), // 여유 공간 추가
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
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            const Text('페달 기록', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // 하얀 사각형 배경 추가, 여유 공간을 만들기 위해 padding 설정
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 배경 색
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색
                    blurRadius: 5,
                    offset: const Offset(0, 3), // 그림자 위치
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0), // 여유 공간 추가
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
            const SizedBox(height: 20),
            // 범례 텍스트 추가
            Text(
              '가속 페달 (빨간색) / 브레이크 페달 (초록색)',
              style: const TextStyle(fontSize: 16, color: Colors.black),
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
  final List<double> accData;
  final List<double> brakeData;

  PedalGraphPainter(this.accData, this.brakeData);

  @override
  void paint(Canvas canvas, Size size) {
    if (accData.isEmpty || brakeData.isEmpty) return;

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

    final accPath = Path();
    final brakePath = Path();

    final xStep = usableWidth / (accData.length - 1);
    final maxY = 1000.0; // 압력 최대값
    final yScale = usableHeight / maxY;

    accPath.moveTo(padding, size.height - padding - accData[0] * yScale);
    for (int i = 1; i < accData.length; i++) {
      final x = padding + i * xStep;
      final y = size.height - padding - accData[i] * yScale;
      accPath.lineTo(x, y);
    }

    brakePath.moveTo(padding, size.height - padding - brakeData[0] * yScale);
    for (int i = 1; i < brakeData.length; i++) {
      final x = padding + i * xStep;
      final y = size.height - padding - brakeData[i] * yScale;
      brakePath.lineTo(x, y);
    }

    canvas.drawPath(accPath, accPaint);
    canvas.drawPath(brakePath, brakePaint);

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

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
  Map<String, dynamic>? suaDetail;
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

      setState(() {
        suaDetail = data['data'][0];
        speedData = suaDetail!['speedData']?.cast<double>() ?? [];
        accPressureData = suaDetail!['accPressureData']?.cast<double>() ?? [];
        brakePressureData = suaDetail!['brakePressureData']?.cast<double>() ?? [];
      });
    } else {
      print('Failed to load SUA detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (suaDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('급발진 상세'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('급발진 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('속도 그래프', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: LineGraphPainter(speedData, Colors.blue, '속도'),
                child: Container(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('페달 압력 그래프', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: PedalGraphPainter(
                  accPressureData,
                  brakePressureData,
                ),
                child: Container(),
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
  final String label;

  LineGraphPainter(this.data, this.color, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = size.width / (data.length - 1);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final yScale = size.height / maxY;

    path.moveTo(0, size.height - data[0] * yScale);

    for (int i = 1; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - data[i] * yScale;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // X축
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint); // Y축
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

    final accPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final brakePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final accPath = Path();
    final brakePath = Path();

    final xStep = size.width / (accData.length - 1);
    final maxY = 1000.0; // 압력 값은 0~1000 사이로 정규화
    final yScale = size.height / maxY;

    // 가속 페달 데이터 그리기
    accPath.moveTo(0, size.height - accData[0] * yScale);
    for (int i = 1; i < accData.length; i++) {
      final x = i * xStep;
      final y = size.height - accData[i] * yScale;
      accPath.lineTo(x, y);
    }

    // 브레이크 데이터 그리기
    brakePath.moveTo(0, size.height - brakeData[0] * yScale);
    for (int i = 1; i < brakeData.length; i++) {
      final x = i * xStep;
      final y = size.height - brakeData[i] * yScale;
      brakePath.lineTo(x, y);
    }

    canvas.drawPath(accPath, accPaint);
    canvas.drawPath(brakePath, brakePaint);

    // 축 그리기
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // X축
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint); // Y축
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

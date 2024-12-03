import 'package:flutter/material.dart';
import 'http_service.dart';
import 'dart:convert';
import 'notification_page.dart';

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

          // Calculate total distance
          totalDistance = calculateTotalDistance();
        });
      }
    } else {
      print('Failed to load SUA detail');
    }
  }

  double calculateTotalDistance() {
    double distance = 0.0;
    for (int i = 1; i < suaDetails.length; i++) {
      final timestamps1 = suaDetails[i - 1]['timestamp'] as List<dynamic>;
      final timestamps2 = suaDetails[i]['timestamp'] as List<dynamic>;

      // Convert timestamps to DateTime
      final time1 = DateTime(
        timestamps1[0], timestamps1[1], timestamps1[2], timestamps1[3], timestamps1[4], timestamps1[5],
      );
      final time2 = DateTime(
        timestamps2[0], timestamps2[1], timestamps2[2], timestamps2[3], timestamps2[4], timestamps2[5],
      );

      final timeDiff = time2.difference(time1).inSeconds / 3600.0; // 시간 단위로 변환

      // 평균 속도 계산 (여러 속도 값의 평균)
      final speeds = List<double>.from(suaDetails[i - 1]['speed']); // 여러 속도 값을 리스트로 변환
      final speeds2 = List<double>.from(suaDetails[i]['speed']); // 두 번째 지점에서의 속도 값

      final totalSpeed = speeds.fold(0.0, (sum, speed) => sum + speed) +
          speeds2.fold(0.0, (sum, speed) => sum + speed);

      final averageSpeed = totalSpeed / (speeds.length + speeds2.length);

      distance += averageSpeed * timeDiff; // 이동 거리 (km)
    }
    return distance;
  }


  @override
  Widget build(BuildContext context) {
    if (suaDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '급발진 상세 기록',
            style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 28),
                fontFamily: 'head',
                color: Color(0xFF818585)
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
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
        title: Text(
          '급발진 상세 기록',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: Color(0xFF818585)
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(
            height: 7,
            color: Color(0xFF8CD8B4),
          ),
        ),
      ),
      body: SingleChildScrollView(  // 세로로 스크롤 가능하도록 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),  // 상단 공백을 줄임
            Text(
              'SUA ID: ${widget.suaid}',  // SUAId를 상단에 표시
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'head'
              ),
            ),
            const SizedBox(height: 15),  // SUAId와 아래 항목 사이 공백 줄임
            const Text(
                '속도',
                style: TextStyle(
                    fontSize: 24,
                  fontFamily: 'head',
                  color: Colors.black
                )
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
              '총 주행 거리: ${totalDistance.toStringAsFixed(2)} km',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                fontFamily: 'body'
              ),
            ),
            Text(
              '평균 속도: ${averageSpeed.toStringAsFixed(2)} km/h',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                fontFamily: 'body'
              ),
            ),
            const SizedBox(height: 20),
            const Text(
                '페달 기록',
                style: TextStyle(
                    fontSize: 24,
                  fontFamily: 'head',
                  color: Colors.black
                )
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
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                fontFamily: 'body'
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size *
        (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
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

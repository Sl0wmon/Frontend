import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 임의의 속도 데이터 (50개의 임의 속도 값)
    final List<double> speedData = List.generate(50, (index) => (index % 5) * 20.0 + 10.0);
    final double averageSpeed = speedData.reduce((a, b) => a + b) / speedData.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('급발진 상황 기록'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 아이콘 클릭 시 동작
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2024.09.04', style: TextStyle(fontSize: 20)),
            Text('15:30:22 ~ 15:40:56', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('주행 거리', style: TextStyle(fontSize: 18)),
            Text('1.54km', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('페달 기록', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 200,
                width: 800, // 그래프를 더 넓게 표시
                child: CustomPaint(
                  painter: PedalChartPainter(
                    brakeData: List.generate(50, (index) => index % 2 == 0 ? 1.0 : 0.0),
                    accelData: List.generate(50, (index) => index % 3 == 0 ? 1.0 : 0.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('속도 기록', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 200,
                width: 800, // 그래프를 더 넓게 표시
                child: CustomPaint(
                  painter: SpeedChartPainter(speedData: speedData),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('평균 속도: ${averageSpeed.toStringAsFixed(2)} km/h', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('사이드 메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
          ),
          ListTile(
            title: Text('대시보드'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
          ),
          ListTile(
            title: Text('급발진 상황 기록'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('차량 부품 교체 주기'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('OBD 진단 가이드'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('알림'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }
}

class PedalChartPainter extends CustomPainter {
  final List<double> brakeData;
  final List<double> accelData;

  PedalChartPainter({required this.brakeData, required this.accelData});

  @override
  void paint(Canvas canvas, Size size) {
    final brakePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final accelPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final pathBrake = Path();
    final pathAccel = Path();

    final spacing = size.width / (brakeData.length - 1);

    // x축과 y축 그리기
    canvas.drawLine(Offset(0, size.height - 20), Offset(size.width, size.height - 20), axisPaint); // x축
    canvas.drawLine(Offset(0, 0), Offset(0, size.height - 20), axisPaint); // y축

    // 축 레이블 추가
    final textPainterX = TextPainter(
      text: TextSpan(
        text: '시간',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterX.layout();
    textPainterX.paint(canvas, Offset(size.width - textPainterX.width - 5, size.height - 15));

    final textPainterY = TextPainter(
      text: TextSpan(
        text: '페달 압력',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterY.layout();
    textPainterY.paint(canvas, Offset(5, 5));

    for (int i = 0; i < brakeData.length; i++) {
      final x = i * spacing;
      final yBrake = size.height - 20 - (brakeData[i] * (size.height - 20)); // Y축 조정
      final yAccel = size.height - 20 - (accelData[i] * (size.height - 20)); // Y축 조정

      if (i == 0) {
        pathBrake.moveTo(x, yBrake);
        pathAccel.moveTo(x, yAccel);
      } else {
        pathBrake.lineTo(x, yBrake);
        pathAccel.lineTo(x, yAccel);
      }
    }

    canvas.drawPath(pathBrake, brakePaint);
    canvas.drawPath(pathAccel, accelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SpeedChartPainter extends CustomPainter {
  final List<double> speedData;

  SpeedChartPainter({required this.speedData});

  @override
  void paint(Canvas canvas, Size size) {
    final speedPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final pathSpeed = Path();
    final spacing = size.width / (speedData.length - 1);

    // x축과 y축 그리기
    canvas.drawLine(Offset(0, size.height - 20), Offset(size.width, size.height - 20), axisPaint); // x축
    canvas.drawLine(Offset(0, 0), Offset(0, size.height - 20), axisPaint); // y축

    // 축 레이블 추가
    final textPainterX = TextPainter(
      text: TextSpan(
        text: '시간',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterX.layout();
    textPainterX.paint(canvas, Offset(size.width - textPainterX.width - 5, size.height - 15));

    final textPainterY = TextPainter(
      text: TextSpan(
        text: '속도 (km/h)',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterY.layout();
    textPainterY.paint(canvas, Offset(5, 5));

    for (int i = 0; i < speedData.length; i++) {
      final x = i * spacing;
      final ySpeed = size.height - 20 - (speedData[i] * (size.height - 20) / 100); // 속도 그래프 비율 조정

      if (i == 0) {
        pathSpeed.moveTo(x, ySpeed);
      } else {
        pathSpeed.lineTo(x, ySpeed);
      }
    }

    canvas.drawPath(pathSpeed, speedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // DashboardPage를 import합니다.

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              Scaffold.of(context).openDrawer(); // 사이드 메뉴 열기
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context), // 새로 작성한 _buildDrawer 메소드 호출
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
            Container(
              height: 200,
              child: CustomPaint(
                painter: LineChartPainter(
                  dataPoints: [1, 2, 3, 2, 5, 1],
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('속도', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: CustomPaint(
                painter: LineChartPainter(
                  dataPoints: [1, 3, 2, 5, 4, 6],
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('평균: 165km', style: TextStyle(fontSize: 16)),
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
              color: Colors.teal,
            ),
          ),
          ListTile(
            title: Text('대시보드'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()), // DashboardPage로 이동
              );
            },
          ),
          ListTile(
            title: Text('급발진 상황 기록'),
            onTap: () {
              Navigator.pop(context); // 드로어 닫기
              // 현재 페이지이므로 아무 동작도 하지 않음
            },
          ),
          ListTile(
            title: Text('차량 부품 교체 주기'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('OBD 진단 가이드'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('알림'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  LineChartPainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spacing = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * spacing;
      final y = size.height - (dataPoints[i] / 6 * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

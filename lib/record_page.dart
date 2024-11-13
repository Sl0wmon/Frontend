import 'dart:math';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'speed_chart_painter.dart';  // SpeedChartPainter import
import 'pedal_chart_painter.dart';  // PedalChartPainter import

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 임의의 속도 데이터 (50개의 임의 속도 값)
    final List<double> speedData = List.generate(50, (index) => (index % 5) * 20.0 + 10.0);
    final double averageSpeed = speedData.reduce((a, b) => a + b) / speedData.length;

    // 브레이크와 엑셀러레이터 페달의 임의 데이터 생성
    final random = Random();
    final List<double> brakeData = List.generate(50, (index) => random.nextDouble());  // 0과 1 사이의 랜덤 값
    final List<double> accelData = List.generate(50, (index) => random.nextDouble());  // 0과 1 사이의 랜덤 값

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
                    brakeData: brakeData,
                    accelData: accelData,
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

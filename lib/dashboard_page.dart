import 'package:flutter/material.dart';
import 'record_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data variables
  List<String> speeds = ['50'];
  List<String> engineRpms = ['701'];
  List<String> coolantTemps = ['110'];
  List<String> intakeTemps = ['30'];
  List<String> engineLoads = ['29.4'];
  List<String> intakePressures = ['100'];
  List<String> drivingDistances = ['75'];
  List<String> journeyTimes = ['18:16'];
  List<String> averageSpeeds = ['50 km/h'];
  List<String> idleTimes = ['15:16'];
  List<String> fuelEfficiencies = ['0 km/L'];
  List<String> fuelRates = ['0 L/h'];

  double _getFontSize(BuildContext context, double size) {
    return size * MediaQuery.of(context).textScaleFactor; // 화면 비율에 맞춘 글꼴 크기
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.4; // 카드 너비 (40% 너비)
    final double cardHeight = size.height * 0.15; // 카드 높이 (15% 높이)

    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드', style: TextStyle(fontSize: _getFontSize(context, 20))), // 제목 글꼴 크기
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // 사이드 메뉴
      body: _buildDashboardPage(cardWidth, cardHeight), // 카드 크기 전달
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('사이드 메뉴', style: TextStyle(color: Colors.white, fontSize: _getFontSize(context, 24))),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          ListTile(
            title: Text('대시보드', style: TextStyle(fontSize: _getFontSize(context, 18))),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('급발진 상황 기록', style: TextStyle(fontSize: _getFontSize(context, 18))),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordPage()), // Navigate to RecordPage
              );
            },
          ),
          ListTile(
            title: Text('차량 부품 교체 주기', style: TextStyle(fontSize: _getFontSize(context, 18))),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('OBD 진단 가이드', style: TextStyle(fontSize: _getFontSize(context, 18))),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('알림', style: TextStyle(fontSize: _getFontSize(context, 18))),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage(double cardWidth, double cardHeight) {
    // 페이지 내용
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 첫 번째 카드 집합 (2x3 레이아웃)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: cardWidth / cardHeight, // 카드 비율 설정
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('속도', '${speeds[0]} km/h', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('엔진 RPM', '${engineRpms[0]} rpm', cardWidth, cardHeight, isLargeFont: true),
              _buildCard(
                '냉각수 온도',
                '${coolantTemps[0]} °C',
                cardWidth,
                cardHeight,
                isHighlighted: coolantTemps[0] == '110',
                isLargeFont: true,
              ),
              _buildCard('흡입 온도', '${intakeTemps[0]} °C', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('엔진 부하', '${engineLoads[0]} %', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('흡입 압력', '${intakePressures[0]} kPa', cardWidth, cardHeight),
            ],
          ),
          SizedBox(height: 16),
          // 두 번째 카드 집합 (3x2 레이아웃)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: cardWidth / cardHeight, // 카드 비율 설정
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('주행 거리', '${drivingDistances[0]} km', cardWidth, cardHeight),
              _buildCard('주행 시간', journeyTimes[0], cardWidth, cardHeight),
              _buildCard('평균 속도', averageSpeeds[0], cardWidth, cardHeight),
              _buildCard('유휴 시간', idleTimes[0], cardWidth, cardHeight),
              _buildCard('순간 연료 효율성', fuelEfficiencies[0], cardWidth, cardHeight),
              _buildCard('순간 소비', fuelRates[0], cardWidth, cardHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, double cardWidth, double cardHeight, {bool isHighlighted = false, bool isLargeFont = false}) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.red[100] : Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: _getFontSize(context, isLargeFont ? 20 : 16), color: Colors.black54)), // 글꼴 크기 조정
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: _getFontSize(context, isLargeFont ? 28 : 24), color: isHighlighted ? Colors.red : Colors.black)), // 글꼴 크기 조정
        ],
      ),
    );
  }
}

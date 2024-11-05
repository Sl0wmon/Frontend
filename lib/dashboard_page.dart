import 'package:flutter/material.dart';
import 'record_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Timer를 사용하기 위해 추가

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data variables
  String speed = '0';
  String rpm = '0';
  String coolantTemp = '0';
  String intakeTemp = '0';
  String engineLoad = '0';
  String intakePressure = '0';
  String drivingDistance = '0';
  String journeyTime = '00:00';
  String averageSpeed = '0 km/h';
  String idleTime = '00:00';
  String fuelEfficiency = '0 km/L';
  String fuelRate = '0 L/h';

  bool isLoading = true; // 로딩 상태 변수 추가
  Timer? timer; // Timer 변수 추가

  @override
  void initState() {
    super.initState();
    fetchData();
    // 1초마다 fetchData를 호출하는 타이머 설정
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel(); // 페이지가 닫힐 때 타이머 취소
    super.dispose();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://172.30.104.185:8080/api/dashboard/view');
    final response = await http.post(url, body: jsonEncode({"userId": "test"}), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == "true") {
        final dashboardData = data['data'];
        setState(() {
          speed = dashboardData['speed'].toString();
          rpm = dashboardData['rpm'].toString();
          coolantTemp = dashboardData['coolantTemperature'].toString();
          intakeTemp = dashboardData['intakeTemperature'].toString();
          engineLoad = dashboardData['engineLoad'].toString();
          intakePressure = dashboardData['intakePressure'].toString();
          drivingDistance = dashboardData['mileage'].toString();
          journeyTime = "${dashboardData['drivingTime'][0]}:${dashboardData['drivingTime'][1].toString().padLeft(2, '0')}";
          averageSpeed = "${dashboardData['averageSpeed']} km/h";
          idleTime = "${dashboardData['idleTime'][0]}:${dashboardData['idleTime'][1].toString().padLeft(2, '0')}";
          fuelEfficiency = "${dashboardData['instantaneousFuelEfficiency']} km/L";
          fuelRate = "${dashboardData['instantaneousConsumption']} L/h";
          isLoading = false; // 데이터 로드 완료 후 로딩 상태 변경
        });
      }
    } else {
      // 에러 처리 로직 추가 가능
    }
  }

  double _getFontSize(BuildContext context, double size) {
    return size * MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      drawer: _buildDrawer(), // 사이드 메뉴
      body: isLoading ? _buildLoadingIndicator() : _buildDashboardPage(cardWidth, cardHeight), // 로딩 중일 때 인디케이터 표시
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(), // 로딩 인디케이터
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 첫 번째 카드 집합 (2x3 레이아웃)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('속도', '$speed km/h', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('엔진 RPM', '$rpm rpm', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('냉각수 온도', '$coolantTemp °C', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('흡입 온도', '$intakeTemp °C', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('엔진 부하', '$engineLoad %', cardWidth, cardHeight, isLargeFont: true),
              _buildCard('흡입 압력', '$intakePressure kPa', cardWidth, cardHeight),
            ],
          ),
          SizedBox(height: 16),
          // 두 번째 카드 집합 (3x2 레이아웃)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('주행 거리', '$drivingDistance km', cardWidth, cardHeight),
              _buildCard('주행 시간', journeyTime, cardWidth, cardHeight),
              _buildCard('평균 속도', averageSpeed, cardWidth, cardHeight),
              _buildCard('유휴 시간', idleTime, cardWidth, cardHeight),
              _buildCard('순간 연료 효율성', fuelEfficiency, cardWidth, cardHeight),
              _buildCard('순간 소비', fuelRate, cardWidth, cardHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, double cardWidth, double cardHeight, {bool isLargeFont = false}) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: _getFontSize(context, isLargeFont ? 20 : 16), color: Colors.black54)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: _getFontSize(context, isLargeFont ? 28 : 24), color: Colors.black)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'record_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 데이터 변수
  String speed = '0.0';
  String rpm = '0.0';
  String coolantTemp = '0.0';
  String intakeTemp = '0.0';
  String engineLoad = '0.0';
  String intakePressure = '0.0';
  String drivingDistance = '0.0';
  String journeyTime = '0:00:00 (시:분:초)';
  String averageSpeed = '0.0 km/h';
  String idleTime = '0:00:00 (시:분:초)';
  String fuelEfficiency = '0.0 km/L';
  String fuelRate = '0.0 L/h';

  bool isLoading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://172.30.104.185:8080/api/dashboard/view');
    final response = await http.post(url,
        body: jsonEncode({"userId": "test"}),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == "true") {
        final dashboardData = data['data'];
        setState(() {
          speed = dashboardData['speed'].toStringAsFixed(1);
          rpm = dashboardData['rpm'].toStringAsFixed(1);
          coolantTemp = dashboardData['coolantTemperature'].toStringAsFixed(1);
          intakeTemp = dashboardData['intakeTemperature'].toStringAsFixed(1);
          engineLoad = (dashboardData['engineLoad'] * 100).toStringAsFixed(1);
          intakePressure = dashboardData['intakePressure'].toStringAsFixed(1);
          drivingDistance = dashboardData['mileage'].toStringAsFixed(1);
          journeyTime = formatTime(dashboardData['drivingTime']);
          averageSpeed = "${dashboardData['averageSpeed'].toStringAsFixed(1)} km/h";
          idleTime = formatTime(dashboardData['idleTime']);
          fuelEfficiency = "${dashboardData['instantaneousFuelEfficiency'].toStringAsFixed(1)} km/L";
          fuelRate = "${dashboardData['instantaneousConsumption'].toStringAsFixed(2)} L/h";
          isLoading = false;
        });
      }
    }
  }

  String formatTime(List<dynamic> timeData) {
    if (timeData == null || timeData.length < 3) {
      return '0:00:00 (시:분:초)';
    }
    int hours = timeData[0] ?? 0;
    int minutes = timeData[1] ?? 0;
    int seconds = timeData[2] ?? 0;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} (시:분:초)';
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    // 화면 비율에 따라 폰트 사이즈를 조정합니다.
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0; // 기준 비율 (iPhone 11)
    return size * (aspectRatio / baseAspectRatio) * MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 카드의 가로 세로 비율을 설정합니다.
    final double cardWidth = size.width * 0.4;
    final double cardHeight = size.height * 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드', style: TextStyle(fontSize: _getAdaptiveFontSize(context, 20))),
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
      body: isLoading ? _buildLoadingIndicator() : _buildDashboardPage(cardWidth, cardHeight),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('사이드 메뉴', style: TextStyle(color: Colors.white, fontSize: _getAdaptiveFontSize(context, 24))),
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
          ),
          ListTile(
            title: Text('대시보드'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('급발진 상황 기록'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => RecordPage()));
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

  Widget _buildDashboardPage(double cardWidth, double cardHeight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCardSingleLine('속도', '$speed km/h', cardWidth, cardHeight, isLargeFont: true),
              _buildCardSingleLine('RPM', '$rpm rpm', cardWidth, cardHeight, isLargeFont: true),
              _buildCardSingleLine('냉각수 온도', '$coolantTemp °C', cardWidth, cardHeight, isLargeFont: true),
              _buildCardSingleLine('흡기 온도', '$intakeTemp °C', cardWidth, cardHeight, isLargeFont: true),
              _buildCardSingleLine('엔진 부하', '$engineLoad %', cardWidth, cardHeight, isLargeFont: true),
              _buildCardSingleLine('흡기 압력', '$intakePressure kPa', cardWidth, cardHeight, isLargeFont: true),
            ],
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCardDoubleLine('주행 거리', '$drivingDistance km', cardWidth, cardHeight),
              _buildCardDoubleLine('주행 시간', journeyTime, cardWidth, cardHeight),
              _buildCardDoubleLine('평균 속도', averageSpeed, cardWidth, cardHeight),
              _buildCardDoubleLine('공회전 시간', idleTime, cardWidth, cardHeight),
              _buildCardDoubleLine('순간 연비', fuelEfficiency, cardWidth, cardHeight, speedValue: double.tryParse(speed) ?? 0),
              _buildCardDoubleLine('순간 연료 소모량', fuelRate, cardWidth, cardHeight, speedValue: double.tryParse(speed) ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSingleLine(String title, String value, double cardWidth, double cardHeight, {bool isLargeFont = false}) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: _getCardColor(title),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: _getAdaptiveFontSize(context, isLargeFont ? 24 : 18))),
            Text(value, style: TextStyle(fontSize: _getAdaptiveFontSize(context, isLargeFont ? 32 : 22))),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDoubleLine(String title, String value, double cardWidth, double cardHeight, {double speedValue = 0, bool isLargeFont = false}) {
    List<String> splitValue = value.split(' ');
    String numberPart = splitValue[0];
    String unitPart = splitValue.length > 1 ? splitValue[1] : '';
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: _getCardColor(title, speedValue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: _getAdaptiveFontSize(context, isLargeFont ? 20 : 16), color: Colors.black54)),
            SizedBox(height: 8),
            Text(numberPart, style: TextStyle(fontSize: _getAdaptiveFontSize(context, isLargeFont ? 28 : 24), color: Colors.black)),
            Text(unitPart, style: TextStyle(fontSize: _getAdaptiveFontSize(context, isLargeFont ? 20 : 16), color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(String title, [double speedValue = 0]) {
    double? coolantTempValue = double.tryParse(coolantTemp);
    double? intakeTempValue = double.tryParse(intakeTemp);
    double? engineLoadValue = double.tryParse(engineLoad);
    double? intakePressureValue = double.tryParse(intakePressure);
    double? fuelEfficiencyValue = double.tryParse(fuelEfficiency);
    double? fuelRateValue = double.tryParse(fuelRate);

    if (title == '냉각수 온도' && coolantTempValue != null) {
      if (coolantTempValue < 85 || coolantTempValue > 105) {
        return colorFromHex('#FFBDBE');
      }
    } else if (title == '흡기 온도' && intakeTempValue != null) {
      if (intakeTempValue < 20 || intakeTempValue > 50) {
        return colorFromHex('#FFBDBE');
      }
    } else if (title == '엔진 부하' && engineLoadValue != null) {
      if (engineLoadValue < 20 || engineLoadValue > 70) {
        return colorFromHex('#FFBDBE');
      }
    } else if (title == '흡기 압력' && intakePressureValue != null) {
      if (intakePressureValue < 20 || intakePressureValue > 80) {
        return colorFromHex('#FFBDBE');
      }
    } else if (title == '순간 연비' && speedValue > 0 && fuelEfficiencyValue != null) {
      if (fuelEfficiencyValue < 10 || fuelEfficiencyValue > 20) {
        return colorFromHex('#FFBDBE');
      }
    } else if (title == '순간 연료 소모량' && speedValue == 0 && fuelRateValue != null) {
      if (fuelRateValue < 0.2 || fuelRateValue > 1.5) {
        return colorFromHex('#FFBDBE');
      }
    }
    return colorFromHex('#8CD8B4');
  }
}

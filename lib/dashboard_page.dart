import 'package:flutter/material.dart';
import 'package:slomon/notification_page.dart';
import 'package:slomon/replacementCycle.dart';
import 'obd_guide_page.dart';
import 'record_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final Map<String, dynamic> userData = {
    "userId": "test"// 서버에 보낼 사용자 데이터
  };
  String name = ""; // 이름 변수
  String phone = ""; // 이름 변수

  String speed = '0.0';
  String rpm = '0.0';
  String coolantTemp = '0.0';
  String intakeTemp = '0.0';
  String engineLoad = '0.0';
  String intakePressure = '0.0';
  String drivingDistance = '0.0';
  String journeyTime = '0:00:00';
  String averageSpeed = '0.0 km/h';
  String idleTime = '0:00:00';
  String fuelEfficiency = '0.0 km/L';
  String fuelRate = '0.0 L/h';

  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchData());
    fetchUserInfo();  // 사용자 정보를 가져오는 함수 호출
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

  Future<void> fetchUserInfo() async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/user/view');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"userId": "kchh0925"}),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            name = jsonData['data']['name'];
          });
        } else {
          print('Unexpected response format: ${jsonData.toString()}');
        }
      } else {
        print('Failed to load user info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }


  Future<void> fetchData() async {
    final url = Uri.parse('http://192.168.45.134:8080/api/dashboard/view');
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
          averageSpeed =
          "${dashboardData['averageSpeed'].toStringAsFixed(1)} km/h";
          idleTime = formatTime(dashboardData['idleTime']);
          fuelEfficiency =
          "${dashboardData['instantaneousFuelEfficiency'].toStringAsFixed(1)} km/L";
          fuelRate =
          "${dashboardData['instantaneousConsumption'].toStringAsFixed(2)} L/h";

          // 디버그 메시지 추가
          print('Updated values: speed=$speed, rpm=$rpm, coolantTemp=$coolantTemp, intakeTemp=$intakeTemp');

          isLoading = false;
        });
      }
    }
  }

  String formatTime(List<dynamic> timeData) {
    if (timeData == null || timeData.length < 3) {
      return '0:00:00';
    }
    int hours = timeData[0] ?? 0;
    int minutes = timeData[1] ?? 0;
    int seconds = timeData[2] ?? 0;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getCardColor(String title, [double value = 0]) {
    // 기본 색상과 기준값을 초과할 때의 색상 설정
    Color defaultColor = Color(0xFF8CD8B4);
    Color alertColor = Color(0xFFF39393);

    switch (title) {
      case '속도':
        return value > 80 ? alertColor : defaultColor;
      case '냉각수 온도':
        return value > 100 ? alertColor : defaultColor;
      case '흡기 온도':
        return value > 70 ? alertColor : defaultColor;
      case '엔진 부하':
        return value > 80 ? alertColor : defaultColor;
      case '흡기 압력':
        return value > 120 ? alertColor : defaultColor;
      default:
        return defaultColor;
    }
  }


  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.4;
    final double cardHeight = size.height * 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '대시보드',
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(context, 28),
            fontFamily: 'head',
            color: Color(0xFF818585),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? _buildLoadingIndicator()
          : Column(
        children: [
          Divider(
            color: Color(0xFF8CD8B4),
            thickness: 7,
          ),
          // 여백 제거: SizedBox(height: 0)
          _buildDashboardPage(cardWidth, cardHeight),
        ],
      ),
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
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사이드 메뉴',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getAdaptiveFontSize(context, 24),
                    fontFamily: 'head',
                  ),
                ),
                SizedBox(height: 40), // 사이드 메뉴와 이름 간격 조정
                Row(
                  children: [
                    // 프로필 이미지 위치
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'), // 이미지 경로 지정
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // 이미지와 텍스트 간격 조정
                    Expanded(
                      child: Text(
                        '$name님', // 이름 텍스트 표시
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _getAdaptiveFontSize(context, 18),
                            fontFamily: 'body',
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        // 버튼 클릭 시 동작
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, "대시보드", Icons.dashboard, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashboardPage())
            );
          }),
          _buildDrawerItem(context, "급발진 상황 기록", Icons.history, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RecordPage()));
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.car_repair, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReplacementCyclePage()));
          }),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.info, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ObdGuidePage()));
          }),
          _buildDrawerItem(context, "알림", Icons.notifications, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NotificationPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: colorFromHex('#8CD8B4')),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
    );
  }


  Widget _buildDashboardPage(double cardWidth, double cardHeight) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 세로 스크롤
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 첫 번째 GridView
            GridView.count(
              shrinkWrap: true, // 부모 위젯 높이에 맞춰 GridView 축소
              physics: NeverScrollableScrollPhysics(), // GridView 자체 스크롤 비활성화
              crossAxisCount: 2,
              childAspectRatio: cardWidth / cardHeight,
              crossAxisSpacing: 8, // 간격 조정
              mainAxisSpacing: 8, // 간격 조정
              children: [
                _buildCardSingleLine(
                    '속도', '$speed km/h', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(speed)),
                _buildCardSingleLine(
                    'RPM', '$rpm rpm', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(rpm)),
                _buildCardSingleLine(
                    '냉각수 온도', '$coolantTemp °C', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(coolantTemp)),
                _buildCardSingleLine(
                    '흡기 온도', '$intakeTemp °C', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(intakeTemp)),
                _buildCardSingleLine(
                    '엔진 부하', '$engineLoad %', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(engineLoad)),
                _buildCardSingleLine(
                    '흡기 압력', '$intakePressure kPa', cardWidth, cardHeight,
                    isLargeFont: true, valueData: double.parse(intakePressure)),
              ],
            ),
            SizedBox(height: 8),
            // 두 번째 GridView
            GridView.count(
              shrinkWrap: true, // 부모 위젯 높이에 맞춰 GridView 축소
              physics: NeverScrollableScrollPhysics(), // GridView 자체 스크롤 비활성화
              crossAxisCount: 3,
              childAspectRatio: cardWidth / cardHeight,
              crossAxisSpacing: 16, // 간격 조정
              mainAxisSpacing: 16, // 간격 조정
              children: [
                _buildCardDoubleLine(
                    '주행 거리', '$drivingDistance km', cardWidth, cardHeight),
                _buildCardDoubleLine(
                    '주행 시간', journeyTime, cardWidth, cardHeight),  // 00:00:00 형식 그대로
                _buildCardDoubleLine(
                    '평균 속도', averageSpeed, cardWidth, cardHeight),
                _buildCardDoubleLine(
                    '공회전 시간', idleTime, cardWidth, cardHeight),  // 00:00:00 형식 그대로
                _buildCardDoubleLine(
                    '연비', fuelEfficiency, cardWidth, cardHeight),
                _buildCardDoubleLine(
                    '연료 소비', fuelRate, cardWidth, cardHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSingleLine(
      String title, String value, double cardWidth, double cardHeight,
      {bool isLargeFont = false, double? valueData}) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getAdaptiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B6C6C),
                  ),
                ),
                Divider(
                  color: Color(0xFF8CD8B4),
                  thickness: 4,
                  indent: 50,
                  endIndent: 50,
                  height: 3,
                ),
              ],
            ),
          ),
          Card(
            color: _getCardColor(title, valueData ?? 0),
            elevation: 4,
            margin: EdgeInsets.all(3),
            child: Container(
              width: double.infinity,
              height: cardHeight - 20,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title == '냉각수 온도' || title == '흡기 온도')
                    Container(
                      width: cardWidth * 0.8,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Color(0xFFE2FFF1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: double.parse(value.split(" ")[0]) / 130,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFEA7B7B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (!(title == '냉각수 온도' || title == '흡기 온도'))
                    Image.asset(
                      'assets/images/speed.png',
                      width: 50,
                      height: 40,
                    ),
                  SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: value.split(" ")[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeFont
                            ? _getAdaptiveFontSize(context, 24)
                            : _getAdaptiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: " ${value.split(" ")[1]}",
                          style: TextStyle(
                            color: Color(0xFFE2FFF1),
                            fontSize: isLargeFont
                                ? _getAdaptiveFontSize(context, 17)
                                : _getAdaptiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCardDoubleLine(
      String title, String value, double cardWidth, double cardHeight) {
    // 숫자와 단위 구분을 위한 정규 표현식 사용
    final regex = RegExp(r"(\d+(\.\d+)?)(\s?[a-zA-Z]+)?"); // 숫자와 단위 분리

    // value 텍스트에서 숫자와 단위를 각각 추출
    final matches = regex.allMatches(value);
    List<TextSpan> textSpans = [];

    // 주행 시간과 공회전 시간은 단위 없이 '00:00:00' 형식으로 출력되도록 처리
    if (title == '주행 시간' || title == '공회전 시간') {
      // '00:00:00' 형식으로 시간을 출력
      textSpans.add(
        TextSpan(
          text: value, // 시간만 출력
          style: TextStyle(
            color: Colors.white, // 숫자는 흰색
            fontSize: _getAdaptiveFontSize(context, 15),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      for (var match in matches) {
        if (match.group(1) != null) {
          // 숫자 부분
          textSpans.add(
            TextSpan(
              text: match.group(1),
              style: TextStyle(
                color: Colors.white, // 숫자는 흰색
                fontSize: _getAdaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        if (match.group(3) != null) {
          // 단위 부분
          textSpans.add(
            TextSpan(
              text: match.group(3),
              style: TextStyle(
                color: Color(0xFFE2FFF1), // 단위는 빨강
                fontSize: _getAdaptiveFontSize(context, 12),
              ),
            ),
          );
        }
      }
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(vertical: 0.0), // 위아래 여백 제거
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 타이틀 텍스트와 Divider
          Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _getAdaptiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B6C6C),
                ),
              ),
              Divider(
                color: Color(0xFF8CD8B4),
                thickness: 4,
                indent: 30,
                endIndent: 30,
                height: 11.0, // Divider와 텍스트 간의 기본 간격 조정
              ),
            ],
          ),
          // Divider와 Card 사이의 간격 제거
          // 카드 내용
          Expanded(
            child: Card(
              color: _getCardColor(title), // 제목에 맞는 카드 색상
              elevation: 3,
              margin: EdgeInsets.zero, // Card의 외부 여백 제거
              child: Container(
                width: double.infinity, // 카드 너비를 부모에 맞춤
                height: double.maxFinite,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4.0), // 카드 내부 여백 최소화
                child: SingleChildScrollView(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: textSpans),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
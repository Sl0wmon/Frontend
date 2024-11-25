import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DataProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'GaugePainter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = ""; // 이름 변수
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchUserInfo(); // 사용자 정보를 가져오는 함수 호출
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/dashboard/view');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"userId": "kchh0925"}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          Provider.of<DataProvider>(context, listen: false).updateData(jsonData['data']);
        } else {
          print('Unexpected response format: ${jsonData.toString()}');
        }
      } else {
        print('Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  Color _getCardColor(String title, [double value = 0]) {
    Color defaultColor = const Color(0xFF8CD8B4);
    Color alertColor = const Color(0xFFF39393);

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
    const baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.4;
    final double cardHeight = size.height * 0.25; // 기존 0.15에서 0.25로 수정하여 높이를 늘림

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '대시보드',
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(context, 28),
            fontFamily: 'head',
            color: const Color(0xFF818585),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? _buildLoadingIndicator()
          : Consumer<DataProvider>(
        builder: (context, provider, child) {
          final data = provider.data;

          if (data == null || data.isEmpty) {
            return Center(child: Text("데이터를 불러오는 중입니다..."));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: cardWidth / cardHeight,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildCardSingleLine(
                        '속도',
                        '${data["Speed"] ?? "0.0"} km/h',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["Speed"] ?? "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        'RPM',
                        '${data["RPM"] ?? "0.0"} rpm',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["RPM"] ?? "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '냉각수 온도',
                        '${data["CoolantTemp"] ?? "0.0"} °C',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["CoolantTemp"] ?? "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '흡기 온도',
                        '${data["IntakeTemp"] ?? "0.0"} °C',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["IntakeTemp"] ?? "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '엔진 부하',
                        '${data["EngineLoad"] ?? "0.0"} %',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["EngineLoad"] ?? "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '흡기 압력',
                        '${data["IntakePressure"] ?? "0.0"} kPa',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["IntakePressure"] ?? "0.0") ?? 0.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return const Center(
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
              color: const Color(0xFF8CD8B4),
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
                const SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$name님',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _getAdaptiveFontSize(context, 18),
                            fontFamily: 'body',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
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
        ],
      ),
    );
  }

  Widget _buildCardSingleLine(
      String title, String value, double cardWidth, double cardHeight,
      {bool isLargeFont = false, double? valueData}) {
    double numericValue = 0.0;

    try {
      numericValue = double.parse(value.split(" ")[0]);
    } catch (e) {
      print("Error parsing value for $title: $e");
    }

    return SizedBox(
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
                    fontSize: _getAdaptiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(
                  color: Color(0xFF8CD8B4),
                  thickness: 4,
                  indent: 50,
                  endIndent: 50,
                  height: 3,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Card(
            color: _getCardColor(title, numericValue),
            elevation: 4,
            margin: const EdgeInsets.all(3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // 카드 자체 모서리를 더 둥글게 설정
            ),
            child: Container(
              width: double.infinity,
              height: cardHeight - 30,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 냉각수 온도와 흡기 온도는 그래프 유지
                  if (title == '냉각수 온도' || title == '흡기 온도')
                    Container(
                      width: cardWidth * 0.9,
                      height: 19,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2FFF1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (numericValue / 130).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA7B7B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )

                  // 나머지 박스는 계기판 추가
                  else
                    CustomPaint(
                      size: Size(cardWidth * 0.8, cardHeight * 0.5),
                      painter: GaugePainter(numericValue),
                    ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: value.split(" ")[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeFont
                            ? _getAdaptiveFontSize(context, 35)
                            : _getAdaptiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: " ${value.split(" ")[1]}",
                          style: TextStyle(
                            color: const Color(0xFFE2FFF1),
                            fontSize: isLargeFont
                                ? _getAdaptiveFontSize(context, 20)
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
}

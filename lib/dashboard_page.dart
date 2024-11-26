import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slomon/http_service.dart';
import 'package:slomon/user_provider.dart';
import 'DataProvider.dart';
import 'dart:convert';
import 'dart:async';
import 'drawer_widget.dart';
import 'GaugePainter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = ""; // 이름 변수
  String userId = "";
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(
        context, listen: false); // listen: false로 값을 가져옴
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => fetchData());
    name =
    user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
    userId = user.userId ?? "";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  Future<void> fetchData() async {
    try {
      final response = await HttpService().postRequest(
          "dashboard/view", {"userId": userId});

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // 데이터가 'ping'일 경우 무시하고 return
        if (jsonData['data'] == "ping") {
          print("Received ping. Keeping existing data.");
          return;
        }

        // 유효한 데이터일 경우에만 상태 업데이트
        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          Provider.of<DataProvider>(context, listen: false).updateData(
              jsonData['data']);
        } else {
          print('Unexpected response format: ${jsonData.toString()}');
        }
      } else {
        print('Failed to load dashboard data. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }


  Color _getCardColor(String title, [double value = 0]) {
    Color defaultColor = const Color(0xFF8CD8B4);
    Color alertColor = const Color(0xFFF39393);

    switch (title) {
      case 'RPM':
        return value > 6000 ? alertColor :defaultColor;
      case '속도':
        return value > 130 ? alertColor : defaultColor;
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
    final screenSize = MediaQuery
        .of(context)
        .size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery
            .of(context)
            .textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
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
          builder: (context) =>
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.grey),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ),
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
                        valueData: double.tryParse(data["Speed"] ?? "0.0") ??
                            0.0,
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
                        valueData: double.tryParse(data["CoolantTemp"] ??
                            "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '흡기 온도',
                        '${data["IntakeTemp"] ?? "0.0"} °C',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["IntakeTemp"] ??
                            "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '엔진 부하',
                        '${data["EngineLoad"] ?? "0.0"} %',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["EngineLoad"] ??
                            "0.0") ?? 0.0,
                      ),
                      _buildCardSingleLine(
                        '흡기 압력',
                        '${data["IntakePressure"] ?? "0.0"} kPa',
                        cardWidth,
                        cardHeight,
                        isLargeFont: true,
                        valueData: double.tryParse(data["IntakePressure"] ??
                            "0.0") ?? 0.0,
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

  Widget _buildCardSingleLine(String title, String value, double cardWidth,
      double cardHeight,
      {bool isLargeFont = false, double? valueData}) {
    double numericValue = 0.0;
    double maxValue = 130.0; // 기본 최대값

    try {
      numericValue = double.parse(value.split(" ")[0]);
    } catch (e) {
      print("Error parsing value for $title: $e");
    }

    // RPM에 대한 최대값을 10000으로 설정
    if (title == 'RPM') maxValue = 10000.0;
    if (title == '속도') maxValue = 255;  // 속도의 최대값 설정
    if (title == '흡기 압력') maxValue = 255;  // 흡기 압력의 최대값 설정
    if (title == '엔진 부하') maxValue = 100;  // 흡기 압력의 최대값 설정

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
                        widthFactor: (numericValue / maxValue).clamp(0.0, 1.0),
                        // 최대값 적용
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
                      painter: GaugePainter(numericValue, maxValue), // 최대값 전달
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
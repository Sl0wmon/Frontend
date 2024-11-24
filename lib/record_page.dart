import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 사용을 위해 추가
import 'replacementCycle.dart';
import 'dashboard_page.dart';
import 'myPage.dart';
import 'notification_page.dart';
import 'obd_guide_page.dart';
import 'info_box.dart';
import 'stat_box.dart';
import 'graph_card.dart';
import 'pedal_chart.dart';
import 'speed_chart.dart';
import 'package:http/http.dart' as http;


class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  String selectedDate = '2024.09.04'; // 초기 날짜 설정

  final Map<String, dynamic> userData = {
    "userId": "test"// 서버에 보낼 사용자 데이터
  };
  String name = ""; // 이름 변수
  String phone = "";

  @override
  void initState() {
    super.initState();
    fetchUserInfo();  // 사용자 정보를 가져오는 함수 호출
  }


  Future<void> fetchUserInfo() async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/user/view');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"userId": "test"}), // "test"로 사용자 ID를 보냄
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          List<dynamic> records = jsonData['data'];  // 급발진 기록 리스트
          // 급발진 기록을 최근 시간 순으로 정렬
          records.sort((a, b) {
            DateTime aTime = DateTime(a['suaonTime'][0], a['suaonTime'][1], a['suaonTime'][2], a['suaonTime'][3], a['suaonTime'][4]);
            DateTime bTime = DateTime(b['suaonTime'][0], b['suaonTime'][1], b['suaonTime'][2], b['suaonTime'][3], b['suaonTime'][4]);
            return bTime.compareTo(aTime); // 내림차순 정렬
          });

          if (records.isNotEmpty) {
            var latestRecord = records[0]; // 최신 기록 선택
            setState(() {
              // 최신 기록의 시간을 화면에 표시
              DateTime onTime = DateTime(latestRecord['suaonTime'][0], latestRecord['suaonTime'][1], latestRecord['suaonTime'][2], latestRecord['suaonTime'][3], latestRecord['suaonTime'][4]);
              DateTime offTime = DateTime(latestRecord['suaoffTime'][0], latestRecord['suaoffTime'][1], latestRecord['suaoffTime'][2], latestRecord['suaoffTime'][3], latestRecord['suaoffTime'][4]);

              // 시간 포맷팅
              String formattedOnTime = DateFormat('yyyy.MM.dd HH:mm').format(onTime);
              String formattedOffTime = DateFormat('yyyy.MM.dd HH:mm').format(offTime);

              // 선택한 날짜와 시간을 최신 기록으로 업데이트
              selectedDate = formattedOnTime; // 선택한 날짜를 기록의 시작 시간으로 업데이트
              print("급발진 시작 시간: $formattedOnTime, 종료 시간: $formattedOffTime");
            });
          } else {
            print('급발진 기록이 없습니다.');
          }
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


  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy.MM.dd').format(pickedDate); // 선택한 날짜 포맷팅
      });
    }
  }

  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          '급발진 상황 기록',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: colorFromHex('#818585')
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Icon(Icons.notifications, color: Colors.grey),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 7,
            color: colorFromHex('#8CD8B4'),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 및 시간
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoBox(
                    icon: Icons.calendar_today,
                    text: selectedDate, // 선택한 날짜 표시
                    onTap: () => _selectDate(context), // 날짜 선택
                  ),
                  const InfoBox(icon: Icons.access_time, text: '15:30:22~15:40:56'),
                ],
              ),
            ),
            // 주행 거리
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StatBox(
                label: '주행 거리',
                value: '1.54km',
                color: colorFromHex('#8CD8B4'),
              ),
            ),
            const SizedBox(height: 16),
            // 페달 기록 그래프
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GraphCard(
                title: '페달 기록',
                child: PedalChart(),
              ),
            ),
            const SizedBox(height: 16),
            // 속도 그래프
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GraphCard(
                title: '속도',
                subtitle: '평균: 165km',
                child: SpeedChart(),
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
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF8CD8B4),
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
                const SizedBox(height: 40), // 사이드 메뉴와 이름 간격 조정
                Row(
                  children: [
                    // 프로필 이미지 위치
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'), // 이미지 경로 지정
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // 이미지와 텍스트 간격 조정
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
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const MyPage())
                        );
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
                context, MaterialPageRoute(builder: (context) => const DashboardPage())
            );
          }),
          _buildDrawerItem(context, "급발진 상황 기록", Icons.history, () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.car_repair, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReplacementCyclePage()));
          }),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.info, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const ObdGuidePage()));
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
        style: const TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:slomon/dashboard_page.dart';
import 'package:slomon/obd_guide_page.dart';
import 'package:slomon/record_page.dart';
import 'package:slomon/replacementCycle.dart';

import 'myPage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  final Map<String, dynamic> userData = {
    "userId": "test"// 서버에 보낼 사용자 데이터
  };
  String name = ""; // 이름 변수
  String phone = ""; // 이름 변수

  Future<void> fetchUserInfo() async {
    try {
      final url = Uri.parse('http://172.30.78.141:8080/api/user/view');

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

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8CD8B4)),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
    );
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();  // 사용자 정보를 가져오는 함수 호출
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const RecordPage()));
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.car_repair, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const ReplacementCyclePage()));
          }),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.info, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const ObdGuidePage()));
          }),
          _buildDrawerItem(context, "알림", Icons.notifications, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const NotificationPage()));
          }),
        ],
      ),
    );
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
          '알림',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: const Color(0xFF818585)
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
            color: const Color(0xFF8CD8B4),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        color: Colors.grey[200], // 전체 배경 회색 설정
        child: Column(
          children: [
            Container(
              height: 0.0,
              color: const Color(0xFF8CD8B4), // 경계선 색상
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0), // 둥근 모서리
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // 그림자 위치
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '알림 내용',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0), // 텍스트와 선 사이 간격
                        Container(
                          height: 2.0,
                          color: const Color(0xFF8CD8B4),
                          width: 40.0, // 텍스트 길이에 맞추기 위해 고정 폭 설정
                        ),
                        const SizedBox(height: 16.0), // 선과 다른 내용 사이의 간격
                        const Expanded(
                          child: Center(
                            child: Text(
                              '여기에 알림 내용이 표시됩니다.',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slomon/record_page.dart';
import 'package:slomon/replacementCycle.dart';
import 'package:http/http.dart' as http;


import 'dashboard_page.dart';
import 'myPage.dart';
import 'notification_page.dart';
import 'obd_guide_page.dart';

class RegisterReplacePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}


class _ReplacementCyclePageState extends State<RegisterReplacePage> {
  @override
  final Map<String, dynamic> userData = {
    "userId": "kchh0925"// 서버에 보낼 사용자 데이터
  };
  String name = ""; // 이름 변수


  final List<String> parts = [
    "엔진 오일",
    "미션 오일",
    "브레이크",
    "클러치",
    "파워스티어링",
    "냉각수",
    "연료 필터",
    "히터 필터",
    "에어컨 필터",
    "브레이크 라이닝",
    "브레이크 패드",
    "휠 얼라이먼트",
    "점화 플러그",
    "배터리",
    "걸 벨트",
    "타이밍 벨트",
  ];

  final List<String> options = [
    "6개월 이내",
    "1년 이내",
    "1년 6개월 이내",
    "2년 이후",
    "모르겠음 (선태하실 경우, 0에서부터 시작됩니다.)"
  ];

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

  Map<String, String?> selectedValues = {};

  @override
  void initState() {
    fetchUserInfo();
    super.initState();
    for (var part in parts) {
      selectedValues[part] = null;
    }
  }
  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
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
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => MyPage())
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
      leading: Icon(icon, color: Color(0xFF8CD8B4)),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.grey),
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
            color: Color(0xFF818585),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Icon(Icons.notifications, color: Colors.grey),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(
            height: 7,
            color: Color(0xFF8CD8B4),
          ),
        ),
      ),
      drawer: _buildDrawer(context), // 기존 Drawer 유지
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 7.0,
                color: Color(0xFF8CD8B4),
              ),
              SizedBox(height: 16),

              ...parts.map((part) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.grey[300], // 드롭다운 메뉴 배경색
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedValues[part],
                        items: options
                            .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValues[part] = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300], // 배경색 회색
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // 테두리 제거
                            borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: Text("선택해주세요"),
                        style: TextStyle(color: Colors.black87), // 텍스트 색상
                      ),
                    ),
                  ],
                ),
              )).toList(),

              // "앞으로의 부품 교체 주기를 예측하기 위한 기록입니다." 문구 중앙 배치
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "*첫번째 교체주기 정보는 약간의 오차가 있을 수 있습니다.*",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFEA7B7B), // 문구 색상 지정
                    ),
                  ),
                ),
              ),

              // 완료 버튼
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // 목록과 버튼 간격
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // 완료 버튼 눌렀을 때 동작
                      print("완료 버튼 눌림");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8CD8B4), // 버튼 배경색
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 버튼 크기
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 버튼
                      ),
                    ),
                    child: Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

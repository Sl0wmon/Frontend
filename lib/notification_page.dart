import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:slomon/dashboard_page.dart';
import 'package:slomon/obd_guide_page.dart';
import 'package:slomon/record_page.dart';
import 'package:slomon/replacementCycle.dart';
import 'myPage.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}


class _NotificationPageState extends State<NotificationPage> {
  String receivedData = "";

  @override
  final Map<String, dynamic> userData = {
    "userId": "test"// 서버에 보낼 사용자 데이터
  };
  String name = ""; // 이름 변수
  String phone = ""; // 이름 변수
  List<dynamic> notifications = [];
  bool isLoading = false;


  Future<void> deleteAllNotifications() async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/notification/delete');

      // 서버에 전달할 데이터
      final requestBody = {
        "userId": "kchh0925", // 사용자 ID
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true") {
          // 성공적으로 삭제되었을 경우
          print('All notifications deleted successfully.');
          setState(() {
            notifications.clear(); // UI에서 알림 목록 삭제
          });
        } else {
          print('Failed to delete notifications: ${jsonData['message']}');
        }
      } else {
        print('Failed to delete notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notifications: $e');
    }
  }



  Future<void> fetchNotifications() async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/notification/view');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"userId": "kchh0925"}), // userId 설정
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            // 데이터를 변환하여 처리
            notifications = jsonData['data'].map((notification) {
              List<dynamic> time = notification['notificationTime'];
              String formattedTime = DateTime(
                time[0],
                time[1],
                time[2],
                time.length > 3 ? time[3] : 0,
                time.length > 4 ? time[4] : 0,
              ).toString(); // 시간 데이터를 문자열로 포맷
              notification['notificationTime'] = formattedTime;
              return notification;
            }).toList();
          });
        } else {
          print('Unexpected response format: ${jsonData.toString()}');
        }
      } else {
        print('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
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

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo(); // 사용자 정보를 가져오는 함수 호출
    fetchNotifications(); // 알림 데이터를 가져오는 함수 호출
  }


  Future<void> _initializeNotifications() async {
    setState(() {
      isLoading = true; // 로딩 상태 설정
    });
    await deleteAllNotifications(); // 모든 알림 삭제
    await fetchNotifications(); // 알림 데이터 가져오기
    setState(() {
      isLoading = false; // 로딩 상태 해제
    });
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification['title'] ?? '제목 없음',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          notification['content'] ?? '내용 없음',
          style: TextStyle(fontSize: 16, color: Color(0xFF565656)),
        ),
        if (notification['code'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '진단가이드에서 ${notification['code']}를 확인해주세요!',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            notification['notificationTime'] ?? '날짜 없음',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Divider(color: Colors.grey), // 회색 경계선
      ],
    );
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
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(), // 로딩 상태 표시
      )
          : Container(
        color: Colors.grey[200], // 전체 배경 회색 설정
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0), // 둥근 모서리
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // 그림자 위치
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '알림 내용',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await deleteAllNotifications(); // 서버 호출하여 알림 삭제
                        },
                        child: Image.asset(
                          'assets/images/delete.png', // 원하는 이미지 경로
                          width: 30, // 이미지 너비
                          height: 30, // 이미지 높이
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0), // 텍스트와 선 사이 간격
                  Container(
                    height: 2.0,
                    color: Color(0xFF8CD8B4),
                    width: 40.0, // 텍스트 길이에 맞추기 위해 고정 폭 설정
                  ),
                  SizedBox(height: 16.0), // 선과 리스트뷰 사이의 간격
                  Expanded(
                    child: notifications.isEmpty
                        ? Center(
                      child: Text(
                        '알림이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero, // 리스트뷰 내부 패딩 제거
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(
                            notifications[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}

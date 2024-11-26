import 'package:flutter/material.dart';
import 'dart:convert';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'http_service.dart';
import 'drawer_widget.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}


class _NotificationPageState extends State<NotificationPage> {
  String name = "";
  String userId = "";
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      userId = user.userId ?? "";
      name = user.name?.isNotEmpty == true
          ? utf8.decode(user.name!.runes.toList())
          : '';
    });

    fetchNotifications(); // 알림 데이터 가져오기
  }




  Future<void> deleteAllNotifications() async {
    try {
      final response = await HttpService().postRequest("notification/delete", {"userId": userId});

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
      final response = await HttpService().postRequest(
        "notification/view",
        {"userId": userId},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            notifications = (jsonData['data'] as List).map((item) {
              final notification = item as Map<String, dynamic>;

              // notificationTime 배열을 DateTime으로 변환
              if (notification['notificationTime'] != null &&
                  notification['notificationTime'] is List &&
                  notification['notificationTime'].length == 5) {
                final timeArray = notification['notificationTime'] as List<dynamic>;
                notification['notificationTime'] = DateTime(
                  timeArray[0],
                  timeArray[1],
                  timeArray[2],
                  timeArray[3],
                  timeArray[4],
                ).toString(); // DateTime을 문자열로 변환
              } else {
                notification['notificationTime'] = "날짜 정보 없음";
              }

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification['title'] ?? '제목 없음',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            notification['content'] ?? '내용 없음',
            style: const TextStyle(fontSize: 16, color: Color(0xFF565656)),
          ),
          if (notification['code'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '진단가이드에서 ${notification['code']}를 확인해주세요!',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              notification['notificationTime'] ?? '날짜 없음',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const Divider(color: Colors.grey),
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
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(
            height: 7,
            color: Color(0xFF8CD8B4),
          ),
        ),
      ),
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ), // 기존 Drawer 유지
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

import 'package:flutter/material.dart';
import 'package:slomon/http_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'sua_detail_page.dart';
import 'drawer_widget.dart';
import 'notification_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<dynamic> suaRecords = [];
  String name = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      userId = user.userId ?? "";
    });
    fetchSUARecords();
  }

  Future<void> fetchSUARecords() async {
    final response = await HttpService().postRequest("SUARecord/list", {"userId": userId});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        suaRecords = data['data'];
      });
    } else {
      print('Failed to load SUA records');
    }
  }

  String formatTime(List<dynamic> time) {
    // 초가 없는 경우 처리 (초를 0으로 채움)
    while (time.length < 6) {
      time.add(0);
    }

    return '${time[3].toString().padLeft(2, '0')}:${time[4].toString().padLeft(2, '0')}:${time[5].toString().padLeft(2, '0')}';
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
          '급발진 상황 기록',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: Color(0xFF818585)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NotificationPage()));
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
      ),
      body: ListView.builder(
        itemCount: suaRecords.length,
        itemBuilder: (context, index) {
          final record = suaRecords[index];
          final suaid = record['suaid'];
          final startTime = record['suaonTime'] ?? [0, 0, 0, 0, 0, 0];
          final endTime = record['suaoffTime'] ?? [0, 0, 0, 0, 0, 0];
          final mileage = record['mileage'] ?? 0.0; // 주행 거리

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // 카드 내부 패딩 추가
                child: ListTile(
                  title: Text(
                    '${startTime[0]}.${startTime[1].toString().padLeft(2, '0')}.${startTime[2].toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'head',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatTime(startTime)} ~ ${formatTime(endTime)}', // 시간 표시
                        style: TextStyle(
                          fontFamily: 'body',
                        ),
                      ),
                    ],
                  ),
                  trailing: const Text(
                    '>',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SUADetailPage(suaid: suaid.toString()),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size *
        (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }
}

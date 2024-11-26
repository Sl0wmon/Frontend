import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slomon/dashboard_page.dart';
import 'package:slomon/record_page.dart';
import 'package:http/http.dart' as http;
import 'package:slomon/registerReplacePage.dart';
import 'package:slomon/user_provider.dart';

import 'car_provider.dart';
import 'http_service.dart';
import 'myPage.dart';
import 'notification_page.dart';
import 'obd_guide_page.dart';

class ReplacementCyclePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}

class _ReplacementCyclePageState extends State<ReplacementCyclePage> {
  String carId = ""; // carId를 저장할 변수
  String receivedData = "";


  String name = ""; // 이름 변수
  String userId = "";
  String phone = ""; // 이름 변수

  // 각 박스의 데이터를 리스트로 관리
  List<Map<String, dynamic>> boxData = [
    {'title': '엔진 오일', 'remainingDistance': '300.10km', 'lastReplacement': '2024-01-10', 'widthFactor': 0.0},
    {'title': '미션오일', 'remainingDistance': '250.50km', 'lastReplacement': '2024-03-15', 'widthFactor': 0.2},
    {'title': '브레이크', 'remainingDistance': '500.75km', 'lastReplacement': '2024-05-20', 'widthFactor': 1.0},
    {'title': '클러치', 'remainingDistance': '150.30km', 'lastReplacement': '2024-06-25', 'widthFactor': 0.5},
    {'title': '파워스티어링', 'remainingDistance': '220.90km', 'lastReplacement': '2024-07-10', 'widthFactor': 0.6},
    {'title': '냉각수', 'remainingDistance': '400.50km', 'lastReplacement': '2024-08-18', 'widthFactor': 0.7},
    {'title': '연료 필터', 'remainingDistance': '320.45km', 'lastReplacement': '2024-09-01', 'widthFactor': 0.8},
    {'title': '히터 필터', 'remainingDistance': '180.30km', 'lastReplacement': '2024-09-10', 'widthFactor': 0.9},
    {'title': '에어컨 필터', 'remainingDistance': '323.13km', 'lastReplacement': '2024-10-10', 'widthFactor': 0.2},
    {'title': '브레이크 라이닝', 'remainingDistance': '310.00km', 'lastReplacement': '2024-10-05', 'widthFactor': 0.6},
    {'title': '브레이크 패드', 'remainingDistance': '450.40km', 'lastReplacement': '2024-11-01', 'widthFactor': 0.4},
    {'title': '휠 얼라이먼트', 'remainingDistance': '360.60km', 'lastReplacement': '2024-11-15', 'widthFactor': 0.7},
    {'title': '점화플러그', 'remainingDistance': '220.75km', 'lastReplacement': '2024-12-01', 'widthFactor': 0.3},
    {'title': '배터리', 'remainingDistance': '240.90km', 'lastReplacement': '2024-12-10', 'widthFactor': 0.8},
    {'title': '걸 벨트', 'remainingDistance': '180.10km', 'lastReplacement': '2024-12-15', 'widthFactor': 0.5},
    {'title': '타이밍', 'remainingDistance': '150.60km', 'lastReplacement': '2024-12-20', 'widthFactor': 0.9},
  ];
  final Map<String, dynamic> userData = {
    "carId": "KGM31231732467313341" // 서버에 보낼 차량 데이터
  };


  Future<void> addNotification(String? userId, String? title) async {
    if (userId == null || title == null) {
      print("알림 추가 실패: userId 또는 title이 null입니다.");
      return;
    }

    try {
      final url = Uri.parse('http://172.30.78.141:8080/api/notification/add');
      final notificationData = {
        "userId": userId,
        "notificationTime": DateTime.now().toIso8601String().split('.').first, // 초 단위까지만 포함
        "code": "", // null 대신 빈 문자열
        "title": "$title의 부품 교체 주기 100% 달성!",
        "content": "$title를 교체 해 주세요!"
      };

      print("Notification Data Request: ${json.encode(notificationData)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(notificationData),
      );

      if (response.statusCode == 201) {
        print('Notification added successfully.');
      } else {
        print('Failed to add notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error adding notification: $e');
    }
  }





  void checkReplacementCycles(Map<String, dynamic> consumableData) {
    const maxDistances = {
      'engineOil': 5000,
      'transmissionOil': 40000,
      'brake': 25000,
      'clutch': 40000,
      'steering': 55000,
      'coolant': 45000,
      'fuelFilter': 40000,
      'heaterFilter': 12000,
      'airconFilter': 17500,
      'brakeLining': 35000,
      'brakePadFront': 25000,
      'brakePadBack': 45000,
      'wheelAlignment': 20000,
      'ignitionPlug': 45000,
      'battery': 50000,
      'outerBelt': 35000,
      'timing': 90000,
    };

    bool hasExceededParts = false; // 초과한 부품 여부 플래그

    maxDistances.forEach((key, maxValue) {
      double currentMileage = consumableData['${key}Mileage'] ?? 0.0;
      if (currentMileage >= maxValue) {
        hasExceededParts = true;
        String partName = _getPartNameFromKey(key);
        print("부품 초과: $partName (현재 주행 거리: ${currentMileage.toInt()}km, 최대 거리: $maxValue km)");
        addNotification(userId, partName); // 알림 추가
      }
    });

    if (!hasExceededParts) {
      print("해당 조건을 만족하는 부품이 없습니다.");
    }
  }


  Future<void> fetchConsumableData() async {
    try {
      final response = await HttpService().postRequest(
        "consumable/view",
        {"carId": carId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Response data from server: $jsonData");

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          final consumableData = jsonData['data'];

          const maxDistances = {
            'engineOil': 5000,
            'transmissionOil': 40000,
            'brake': 25000,
            'clutch': 40000,
            'steering': 55000,
            'coolant': 45000,
            'fuelFilter': 40000,
            'heaterFilter': 12000,
            'airconFilter': 17500,
            'brakeLining': 35000,
            'brakePadFront': 25000,
            'brakePadBack': 45000,
            'wheelAlignment': 20000,
            'ignitionPlug': 45000,
            'battery': 50000,
            'outerBelt': 35000,
            'timing': 90000,
          };

          setState(() {
            boxData = maxDistances.entries.map((entry) {
              final key = entry.key;
              final maxValue = entry.value;

              // 현재 mileage를 가져옵니다.
              final currentMileage = consumableData['${key}Mileage'] ?? 0.0;
              final lastReplacement = consumableData['${key}Last'] ?? [0, 0, 0];

              // widthFactor를 계산합니다. maxValue를 초과하면 1.0으로 강제 설정합니다.
              final widthFactor = currentMileage >= maxValue
                  ? 1.0
                  : (currentMileage / maxValue);

              return {
                'title': _getPartNameFromKey(key),
                'remainingDistance': '${currentMileage.toInt()}km',
                'lastReplacement': formatDate(lastReplacement),
                'widthFactor': widthFactor,
              };
            }).toList();
          });

          checkReplacementCycles(consumableData); // 알림 조건 체크
        } else {
          print('No consumable data available or failed: ${jsonData['message']}');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching consumable data: $e');
    }
  }




  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false); // listen: false로 값을 가져옴

    userId = user.userId ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      setState(() {
        carId = carProvider.carId; // CarProvider에서 carId 가져오기
      });

      if (carId.isNotEmpty) {
        // 페이지에 들어왔을 때 한 번만 데이터 가져오고 조건 체크
        fetchConsumableData().then((consumableData) {

        });
      } else {
        print("carId is not available");
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
  }



  // 날짜 배열을 읽기 쉬운 형식으로 변환하는 헬퍼 함수
  String formatDate(List<dynamic> dateArray) {
    if (dateArray != null && dateArray.length == 3) {
      return '${dateArray[0]}-${dateArray[1].toString().padLeft(2, '0')}-${dateArray[2].toString().padLeft(2, '0')}';
    }
    return "날짜 정보 없음";
  }



  String _getPartNameFromKey(String key) {
    const partNames = {
      'engineOil': '엔진 오일',
      'transmissionOil': '미션 오일',
      'brake': '브레이크',
      'clutch': '클러치',
      'steering': '파워스티어링',
      'coolant': '냉각수',
      'fuelFilter': '연료 필터',
      'heaterFilter': '히터 필터',
      'airconFilter': '에어컨 필터',
      'brakeLining': '브레이크 라이닝',
      'brakePadFront': '브레이크 패드(앞)',
      'brakePadBack': '브레이크 패드(뒤)',
      'wheelAlignment': '휠 얼라이먼트',
      'ignitionPlug': '점화 플러그',
      'battery': '배터리',
      'outerBelt': '걸 벨트',
      'timing': '타이밍 벨트',
    };
    return partNames[key] ?? '알 수 없는 부품';
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
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        carId = carProvider.carId; // CarProvider에서 carId를 가져옴

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
              '부품 교체 주기',
              style: TextStyle(
                  fontSize: _getAdaptiveFontSize(context, 28),
                  fontFamily: 'head',
                  color: Color(0xFF818585)
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
          drawer: _buildDrawer(context),

          body: carId.isEmpty || boxData.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '차량 부품 교체 정보를 등록해주세요.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'body',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterReplacePage()),
                    );
                  },
                  child: Text('부품 정보 등록하러 가기'),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: boxData.map((box) {
                  return Column(
                    children: [
                      buildGreenBox(
                        title: box['title'],
                        remainingDistance: box['remainingDistance'],
                        lastReplacement: box['lastReplacement'],
                        widthFactor: box['widthFactor'],
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget buildGreenBox({
    required String title,
    required String remainingDistance,
    required String lastReplacement,
    required double widthFactor,
  }) {
    title = title ?? "Unknown Part";
    remainingDistance = remainingDistance ?? "0km";
    lastReplacement = lastReplacement ?? "Unknown Date";

    return Container(
      width: 350,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF8CD8B4),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 130,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'head',
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '주행거리: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF696C6C),
                          fontFamily: 'body',
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        remainingDistance,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'body',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '마지막 교체: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF696C6C),
                          fontFamily: 'body',
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        lastReplacement,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'body',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(height: 16),
          Container(
            height: 10.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: widthFactor >= 0.8 ? Color(0xFFFF7E7E) : Color(0xFF60BF92),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 1),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(widthFactor * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'body',
              ),
            ),
          ),
        ],
      ),
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
}
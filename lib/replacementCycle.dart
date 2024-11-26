import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'drawer_widget.dart';
import 'car_provider.dart';
import 'http_service.dart';

class ReplacementCyclePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}



class _ReplacementCyclePageState extends State<ReplacementCyclePage> {
  String carId = ""; // carId를 저장할 변수
  String receivedData = "";

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

  String name = ""; // 이름 변수
  String phone = ""; // 이름 변수

  Future<void> addNotification(String userId, String title) async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/notification/add');
      final notificationData = {
        "userId": userId,
        "notificationTime": DateTime.now().toIso8601String(), // 현재 시간
        "code": null,
        "title": "$title의 부품 교체 주기 100% 달성!",
        "content": "$title를 교체 해 주세요!"
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(notificationData),
      );

      if (response.statusCode == 201) {
        print('Notification added successfully.');
      } else {
        print('Failed to add notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding notification: $e');
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
        print("Response data from server: $jsonData"); // 서버에서 받은 전체 데이터 출력

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          final consumableData = jsonData['data'];
          print("Consumable data from server: $consumableData"); // 서버에서 받은 consumable 데이터 출력

          setState(() {
            // 서버에서 받은 데이터를 boxData 형식으로 변환
            boxData = [
              {
                'title': '엔진 오일',
                'remainingDistance': '${consumableData['engineOilMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['engineOilLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['engineOilMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '미션오일',
                'remainingDistance': '${consumableData['missionOilMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['missionOilLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['missionOilMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '브레이크',
                'remainingDistance': '${consumableData['brakeMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['brakeLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['brakeMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '클러치',
                'remainingDistance': '${consumableData['clutchMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['clutchLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['clutchMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '파워스티어링',
                'remainingDistance': '${consumableData['steeringMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['steeringLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['steeringMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '냉각수',
                'remainingDistance': '${consumableData['coolantMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['coolantLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['coolantMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '연료 필터',
                'remainingDistance': '${consumableData['fuelFilterMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['fuelFilterLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['fuelFilterMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '히터 필터',
                'remainingDistance': '${consumableData['heaterFilterMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['heaterFilterLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['heaterFilterMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '에어컨 필터',
                'remainingDistance': '${consumableData['conditionerFilterMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['conditionerFilterLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['conditionerFilterMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '브레이크 라이닝',
                'remainingDistance': '${consumableData['brakeLiningMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['brakeLiningLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['brakeLiningMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '브레이크 패드',
                'remainingDistance': '${consumableData['brakePadFrontMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['brakePadFrontLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['brakePadFrontMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '휠 얼라이먼트',
                'remainingDistance': '${consumableData['wheelAlignmentMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['wheelAlignmentLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['wheelAlignmentMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '점화플러그',
                'remainingDistance': '${consumableData['ignitionPlugMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['ignitionPlugLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['ignitionPlugMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '배터리',
                'remainingDistance': '${consumableData['batteryMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['batteryLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['batteryMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '걸 벨트',
                'remainingDistance': '${consumableData['outerBeltMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['outerBeltLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['outerBeltMileage'] ?? 0.0) / 100.0,
              },
              {
                'title': '타이밍',
                'remainingDistance': '${consumableData['timingBeltMileage'] ?? 0.0}km',
                'lastReplacement': formatDate(consumableData['timingBeltLast'] ?? [0, 0, 0]),
                'widthFactor': (consumableData['timingBeltMileage'] ?? 0.0) / 100.0,
              },
            ];
            print("Updated boxData: $boxData"); // boxData 업데이트 확인
          });
        } else {
          print('Failed to fetch data: ${jsonData['message']}');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching consumable data: $e');
    }
  }




  // 날짜 배열을 읽기 쉬운 형식으로 변환하는 헬퍼 함수
  String formatDate(List<dynamic> dateArray) {
    if (dateArray != null && dateArray.length == 3) {
      return '${dateArray[0]}-${dateArray[1].toString().padLeft(2, '0')}-${dateArray[2].toString().padLeft(2, '0')}';
    }
    return "날짜 정보 없음";
  }

  @override
  void initState() {
    super.initState();

    // 데이터를 가져오는 메서드 호출 (사용자가 화면을 보고 있을 때 가져옴)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      setState(() {
        carId = carProvider.carId; // CarProvider에서 carId 가져오기
      });

      if (carId.isNotEmpty) {
        fetchConsumableData();
      } else {
        print("carId is not available");
      }
    });
  }




  void checkReplacementCycles() {
    for (var box in boxData) {
      if (box['widthFactor'] >= 1.0) {
        addNotification(userData['userId'], box['title']);
      }
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
          drawer: DrawerWidget(
            name: name,
            getAdaptiveFontSize: _getAdaptiveFontSize,
          ),
          body: carId.isEmpty || boxData.isEmpty
              ? Center(child: CircularProgressIndicator()) // 데이터 로딩 상태 표시
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
    // 만약 remainingDistance, lastReplacement 등이 null로 들어온다면 기본값으로 설정해 줍니다.
    title = title ?? "Unknown Part";
    remainingDistance = remainingDistance ?? "0km";
    lastReplacement = lastReplacement ?? "Unknown Date";
    widthFactor = widthFactor ?? 0.0;

    if (widthFactor >= 1.0) {
      // 알림 추가 로직 호출
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addNotification(userData['userId'], title);
      });
    }

    return Container(
      width: 350,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF8CD8B4), // 연두색
        borderRadius: BorderRadius.circular(20.0), // 둥근 모서리
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
                        '잔여 주행거리: ',
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
                  color: widthFactor >= 0.8
                      ? Color(0xFFFF7E7E)
                      : Color(0xFF60BF92),
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
}

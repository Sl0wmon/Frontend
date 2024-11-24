import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:slomon/addCarInfo_page.dart';
import 'package:slomon/dashboard_page.dart';
import 'package:slomon/notification_page.dart';
import 'package:slomon/record_page.dart';
import 'package:slomon/replacementCycle.dart';

import 'obd_guide_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {
  bool isLoading = false;
  final Map<String, dynamic> userData = {
    "userId": "kchh0925" // 서버에 보낼 사용자 데이터
  };

  String name = ""; // 이름 변수
  String phoneNumber = ""; // 전화번호 변수
  String carManufacturer = "";
  String carSize = "";
  String carType = ""; // 외형 추가 (예: SUV)
  String carFuel = "";
  String carDisplacement = "";
  String carYear = "";
  String carId = ""; // 차량 ID 저장


  // 서버에서 데이터를 받아오는 함수
  Future<void> fetchUserInfo() async {
    try {
      final url = Uri.parse('http://192.168.45.134:8080/api/user/view');

      // JSON 데이터를 POST 요청에 포함
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, // 요청 헤더 설정
        body: json.encode(userData), // JSON으로 변환하여 본문에 포함
      );

      if (response.statusCode == 200) {
        // 서버로부터 받은 데이터를 파싱
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            name = jsonData['data']['name']; // "data" 안의 "name" 값
            phoneNumber = jsonData['data']['phoneNumber']; // "data" 안의 "phoneNumber" 값
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

  Future<void> deleteCar() async {
    final url = Uri.parse('http://192.168.45.134:8080/api/car/delete');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'userId': userData['userId'],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'true') {
          print('차량 정보 삭제 완료');
          // 차량 삭제 후 최신 정보를 다시 가져오기
          fetchCarInfo();
        } else {
          print('삭제 실패: ${responseBody['message']}');
        }
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('요청 실패: $e');
    }
  }


  Future<void> fetchCarInfo() async {

    setState(() {
      isLoading = true; // 로딩 시작
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.45.134:8080/api/car/view/user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": "kchh0925"}), // 사용자 ID로 차량 정보 조회
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 적용
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          List<dynamic> carDataList = jsonData['data'];
          if (carDataList.isNotEmpty) {
            var carData = carDataList[0];
            setState(() {
              carManufacturer = carData['manufacturer'] ?? "정보 없음";
              carSize = carData['size'] ?? "정보 없음";
              carType = carData['model'] ?? "정보 없음";
              carFuel = carData['fuel'] ?? "정보 없음";
              carDisplacement = carData['displacement'] ?? "정보 없음";
              carYear = carData['year']?.toString() ?? "정보 없음";
            });
          } else {
            setState(() {
              // 차량이 없으면 값 초기화
              carManufacturer = "정보 없음";
              carSize = "정보 없음";
              carType = "정보 없음";
              carFuel = "정보 없음";
              carDisplacement = "정보 없음";
              carYear = "정보 없음";
            });
            print("차량 정보가 없습니다.");
          }
        } else {
          print("응답 형식이 잘못되었습니다.");
        }
      } else {
        throw Exception('Failed to load car info');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchCarInfo();
    fetchUserInfo();
    // 페이지 로드 시 데이터 가져오기
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
          '개인페이지',
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
            height: 2,
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
              height: 7.0,
              color: const Color(0xFF8CD8B4), // 경계선 색상
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "회원 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head',
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: const Text("수정", style: TextStyle(fontFamily: 'body', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text("이름: $name", style: const TextStyle(fontFamily: 'body')), // 이름 데이터 표시
                          const SizedBox(height: 8),
                          Text("전화번호: $phoneNumber", style: const TextStyle(fontFamily: 'body')), // 전화번호 데이터 표시
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // 차량 정보 박스
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "차량 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // 차량 정보 등록 또는 수정 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddCarInfoPage()), // AddCarInfoPage로 이동
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  carManufacturer == "정보 없음" ? "등록" : "수정",
                                  style: const TextStyle(
                                    fontFamily: 'body',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          carManufacturer == "정보 없음"
                              ? const Center(
                            child: Text(
                              "등록된 차량 정보가 없습니다.",
                              style: TextStyle(
                                fontFamily: 'body',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8CD8B4), // 연두색
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            carType,
                                            style: const TextStyle(
                                              fontSize: 29,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'body',
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await deleteCar();
                                                setState(() {
                                                  carManufacturer = "정보 없음";
                                                  carSize = "정보 없음";
                                                  carType = "정보 없음";
                                                  carFuel = "정보 없음";
                                                  carDisplacement = "정보 없음";
                                                  carYear = "정보 없음";
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF9A7A7),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                              ),
                                              child: const Text(
                                                "삭제",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("제조사: $carManufacturer",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          const SizedBox(height: 8),
                                          Text("차급: $carSize",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          const SizedBox(height: 8),
                                          Text("외형: $carType",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          const SizedBox(height: 8),
                                          Text("연료: $carFuel",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          const SizedBox(height: 8),
                                          Text("배기량: $carDisplacement",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          const SizedBox(height: 8),
                                          Text("연식: $carYear년",
                                              style: const TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 새로 추가된 박스
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity, // 너비를 전체로 설정
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "제품 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: const Text(
                                      "삭제",
                                      style: TextStyle(color: Color(0xFF60BF92), fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8CD8B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: const Text(
                                      "등록",
                                      style: TextStyle(color: Colors.white, fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 연두색 박스
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8CD8B4), // 연두색
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Center(
                              child: Text(
                                "1111 - 1111 - 1111 - 1111",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'body', // 'body' 폰트 적용
                                ),
                              ),
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
      ),
    );
  }
}
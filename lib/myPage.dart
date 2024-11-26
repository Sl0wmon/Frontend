import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_page.dart';
import 'drawer_widget.dart';
import 'addCarInfo_page.dart';
import 'user_provider.dart';
import 'car_provider.dart';
import 'package:provider/provider.dart';
import 'http_service.dart';
import 'modify_car_info_page.dart';
import 'update_user_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String receivedData = "";

  bool isLoading = false;

  String userId = "";
  String name = ""; // 이름 변수
  String phoneNumber = ""; // 전화번호 변수
  String carManufacturer = "";
  String carSize = "";
  String carType = ""; // 외형 추가 (예: SUV)
  String carFuel = "";
  String carDisplacement = "";
  String carYear = "";
  String carId = "";

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 데이터 가져오기
    final user = Provider.of<UserProvider>(context, listen: false); // listen: false로 값을 가져옴
    final car = Provider.of<CarProvider>(context, listen: false); // listen: false로 값을 가져옴

    setState(() {
      userId = user.userId ?? "";
      name = user.name != null ? utf8.decode(user.name!.codeUnits) : ""; // UTF-8 디코딩 적용
      phoneNumber = user.phoneNumber ?? ""; // UserProvider에서 phoneNumber 가져오기
      carManufacturer = utf8.decode(car.manufacturer.codeUnits); // UTF-8 디코딩 적용
      carSize = utf8.decode(car.size.codeUnits); // UTF-8 디코딩 적용
      carType = utf8.decode(car.model.codeUnits); // 외형 (model) UTF-8 디코딩 적용
      carFuel = car.fuel;
      carDisplacement = car.displacement;
      carYear = car.year.toString(); // year는 int, 문자열로 변환
      carId = car.carId;
    });
  }

  Future<void> deleteCar() async {
    try {
      final response = await HttpService().postRequest("car/delete", {"userId": userId});

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == 'true') {
          print('차량 정보 삭제 완료');
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyPage()),
          );
        } else {
          print('삭제 실패: ${jsonData['message']}');
        }
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('요청 실패: $e');
    }
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
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
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ),
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
                                onPressed: () {
                                  // update_user_page로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const UpdateUserPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: const Text(
                                  "수정",
                                  style: TextStyle(
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
                          Text("이름: $name", style: const TextStyle(fontFamily: 'body')), // 이름 데이터 표시
                          const SizedBox(height: 8),
                          Text("전화번호: $phoneNumber", style: const TextStyle(fontFamily: 'body')), // 전화번호 데이터 표시
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // 차량 정보 박스 수정
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
                                  if (carManufacturer.isEmpty) {
                                    // 차량 정보가 없을 때
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddCarInfoPage()),
                                    );
                                  } else {
                                    // 차량 정보가 있을 때
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ModifyCarInfoPage()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  carManufacturer.isEmpty ? "등록" : "수정",
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
                          carManufacturer.isEmpty
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
                                        ElevatedButton(
                                          onPressed: () async {
                                            await deleteCar();
                                            setState(() {
                                              carManufacturer = "";
                                              carSize = "";
                                              carType = "";
                                              carFuel = "";
                                              carDisplacement = "";
                                              carYear = "";
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
                                "장치 연결", // 텍스트 변경
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // 등록 버튼 누르면 BluetoothPage로 이동
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => BluetoothPage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8CD8B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: const Text(
                                      "등록",
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
                          // 연두색 박스 제거
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

  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }
}
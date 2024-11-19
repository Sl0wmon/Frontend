import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:slomon/addCarInfo.dart'; // JSON 디코딩 및 인코딩

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {
  bool isLoading = false;
  final Map<String, dynamic> userData = {
    "userId": "test" // 서버에 보낼 사용자 데이터
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
      final url = Uri.parse('http://172.30.78.141:8080/api/user/view');

      // JSON 데이터를 POST 요청에 포함
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, // 요청 헤더 설정
        body: json.encode(userData), // JSON으로 변환하여 본문에 포함
      );

      if (response.statusCode == 200) {
        // 서버로부터 받은 데이터를 파싱
        var jsonData = json.decode(response.body);

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
    final url = Uri.parse('http://172.30.78.141:8080/api/car/delete');
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
        Uri.parse('http://172.30.78.141:8080/api/car/view/user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": "test"}), // 사용자 ID로 차량 정보 조회
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            '<',
            style: TextStyle(fontSize: 24, color: Colors.black, fontFamily: 'body'),
          ),
          onPressed: () => Navigator.pop(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        title: Text(
          '개인페이지',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'head'),
        ),
      ),
      body: Container(
        color: Colors.grey[200], // 전체 배경 회색 설정
        child: Column(
          children: [
            Container(
              height: 7.0,
              color: Color(0xFF8CD8B4), // 경계선 색상
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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
                                  backgroundColor: Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text("수정", style: TextStyle(fontFamily: 'body', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("이름: $name", style: TextStyle(fontFamily: 'body')), // 이름 데이터 표시
                          SizedBox(height: 8),
                          Text("전화번호: $phoneNumber", style: TextStyle(fontFamily: 'body')), // 전화번호 데이터 표시
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    // 차량 정보 박스
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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
                            MaterialPageRoute(builder: (context) => AddCarInfoPage()), // AddCarInfoPage로 이동
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8CD8B4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          carManufacturer == "정보 없음" ? "등록" : "수정",
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
                          SizedBox(height: 16),
                          carManufacturer == "정보 없음"
                              ? Center(
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
                                  color: Color(0xFF8CD8B4), // 연두색
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            "$carType",
                                            style: TextStyle(
                                              fontSize: 29,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'body',
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: [
                                            SizedBox(width: 8),
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
                                                backgroundColor: Color(0xFFF9A7A7),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                              ),
                                              child: Text(
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
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("제조사: $carManufacturer",
                                              style: TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          SizedBox(height: 8),
                                          Text("차급: $carSize",
                                              style: TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          SizedBox(height: 8),
                                          Text("외형: $carType",
                                              style: TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          SizedBox(height: 8),
                                          Text("연료: $carFuel",
                                              style: TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          SizedBox(height: 8),
                                          Text("배기량: $carDisplacement",
                                              style: TextStyle(
                                                  fontFamily: 'body',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF595959))),
                                          SizedBox(height: 8),
                                          Text("연식: $carYear년",
                                              style: TextStyle(
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
                    SizedBox(height: 16),
                    // 새로 추가된 박스
                    Container(
                      padding: EdgeInsets.all(16.0),
                      width: double.infinity, // 너비를 전체로 설정
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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
                                    child: Text(
                                      "삭제",
                                      style: TextStyle(color: Color(0xFF60BF92), fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF8CD8B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: Text(
                                      "등록",
                                      style: TextStyle(color: Colors.white, fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // 연두색 박스
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF8CD8B4), // 연두색
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
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

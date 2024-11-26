import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slomon/replacementCycle.dart';
import 'package:http/http.dart' as http;
import 'car_provider.dart';
import 'user_provider.dart';

class RegisterReplacePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}

class _ReplacementCyclePageState extends State<RegisterReplacePage> {
  String mileageInput = ""; // 주행 거리 입력값 저장 변수

  String receivedData = "";
  String userId = "";
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

  Map<String, String?> selectedValues = {};

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

    for (var part in parts) {
      selectedValues[part] = null;
    }


  }

  final Map<String, String> consumableTypeMapping = {
    "엔진 오일": "engineOil",
    "미션 오일": "transmissionOil",
    "브레이크": "brake",
    "클러치": "clutch",
    "파워스티어링": "steering",
    "냉각수": "coolant",
    "연료 필터": "fuelFilter",
    "히터 필터": "heaterFilter",
    "에어컨 필터": "conditionerFilter",
    "브레이크 라이닝": "brakeLining",
    "브레이크 패드": "brakePadFront", // 예시로 앞쪽 패드
    "휠 얼라이먼트": "wheelAlignment",
    "점화 플러그": "ignitionPlug",
    "배터리": "battery",
    "걸 벨트": "outerBelt",
    "타이밍 벨트": "timingBelt",
  };




  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  Future<void> saveConsumableData(String mileageInput) async {
    try {
      final carProvider = Provider.of<CarProvider>(context, listen: false);

      final url = Uri.parse('http://172.30.78.141:8080/api/consumable/add');

      for (var part in selectedValues.keys) {
        if (selectedValues[part] != null) {
          // 드롭다운 값을 숫자로 변환
          int lastChangedValue = _convertLastChanged(selectedValues[part]!);

          // consumableType 매핑
          final mappedConsumableType = consumableTypeMapping[part];
          if (mappedConsumableType == null) {
            print("Invalid consumable type: $part");
            continue; // 잘못된 consumableType이면 스킵
          }

          final consumableData = {
            "carId": carProvider.carId, // 불러온 carId 값
            "consumableType": mappedConsumableType, // 매핑된 부품 이름
            "mileage": double.tryParse(mileageInput) ?? 0.0, // 입력받은 총 주행 거리
            "lastChanged": lastChangedValue, // 변환된 드롭다운 값
          };

          // 서버로 데이터 전송
          final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode(consumableData),
          );

          if (response.statusCode == 201) {
            print('${part} data saved successfully.');
          } else {
            print('Failed to save ${part} data. Status code: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print('Error saving consumable data: $e');
    }
  }







  // 드롭다운 값 변환 함수
  int _convertLastChanged(String dropdownValue) {
    switch (dropdownValue) {
      case "6개월 이내":
        return 6;
      case "1년 이내":
        return 12;
      case "1년 6개월 이내":
        return 18;
      case "2년 이후":
        return 24;
      default: // "모르겠음"
        return 0;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('부품 교체 등록'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주행 거리 입력 Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                        hintText: "총 주행 거리를 입력해주세요",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          mileageInput = value; // 입력값 저장
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8), // 간격 추가
                  Text(
                    "km",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700], // 색상 회색
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 부품 교체 주기 선택 드롭다운
              ...selectedValues.keys.map((part) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedValues[part],
                        items: [
                          "6개월 이내",
                          "1년 이내",
                          "1년 6개월 이내",
                          "2년 이후",
                          "모르겠음"
                        ].map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValues[part] = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              SizedBox(height: 16),

              // 완료 버튼
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await saveConsumableData(mileageInput); // 입력받은 주행 거리 값 전달
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ReplacementCyclePage()),
                    );
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
            ],
          ),
        ),
      ),
    );
  }
}

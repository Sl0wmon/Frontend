import 'package:flutter/material.dart';

class CarProvider with ChangeNotifier {
  String carId = "";
  String manufacturer = "";
  String size = "";
  String model = "";
  String fuel = "";
  String displacement = "";
  int year = 0;  // 기본값을 0으로 설정

  // 차량 정보 설정 함수
  void setCarInfo(Map<String, dynamic> carData) {
    // 데이터가 비어 있으면 빈 문자열로 설정
    carId = carData['carId'] ?? "";
    manufacturer = carData['manufacturer'] ?? "";
    size = carData['size'] ?? "";
    model = carData['model'] ?? "";
    fuel = carData['fuel'] ?? "";
    displacement = carData['displacement'] ?? "";
    year = carData['year'] ?? 0; // year는 int이므로 0으로 처리
    notifyListeners();
  }
}

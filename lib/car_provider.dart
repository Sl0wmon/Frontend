// lib/car_provider.dart
import 'package:flutter/material.dart';

class CarProvider with ChangeNotifier {
  String? _carId;
  String? _carModel;
  String? _carColor;

  String? get carId => _carId;
  String? get carModel => _carModel;
  String? get carColor => _carColor;

  // 차량 정보 저장
  void setCarInfo(String carId, String carModel, String carColor) {
    _carId = carId;
    _carModel = carModel;
    _carColor = carColor;
    notifyListeners(); // 값이 변경되었음을 알림
  }

  // 차량 정보 초기화
  void clearCarInfo() {
    _carId = null;
    _carModel = null;
    _carColor = null;
    notifyListeners(); // 값이 변경되었음을 알림
  }
}

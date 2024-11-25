import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  Map<String, dynamic> _data = {
    "Speed": "6.0",
    "RPM": "0.0",
    "CoolantTemp": "0.0",
    "IntakeTemp": "0.0",
    "EngineLoad": "0.0",
    "IntakePressure": "0.0",
    "PressureValues": {
      "acc": "0",
      "brk": "0",
    },
  };

  Map<String, dynamic> get data => _data;

  void updateData(Map<String, dynamic> newData) {
    _data = {..._data, ...newData};
    notifyListeners();
  }
}

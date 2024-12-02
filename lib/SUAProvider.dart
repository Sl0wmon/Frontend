import 'package:flutter/material.dart';

class SuaProvider extends ChangeNotifier {
  String SUAId = "";
  String timeStamp = "";
  String SUA = "";
  double Speed = 0;
  double RPM = 0;
  double CoolantTemp = 0;
  double IntakeTemp = 0;
  double EngineLoad = 0;
  double IntakePressure = 0;

  Map<String, int> PressureValues = {
    "acc": 0,
    "brk": 0,
  };

  Map<String, dynamic> _data = {
    "timeStamp":"2024-11-26T09:03:24",
    "SUA":"false",
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

  void setData(Map<String, dynamic> SUAData) {
    timeStamp = SUAData['timeStamp'] ?? "";
    SUA = SUAData['SUA'] ?? "";
    Speed = SUAData['Speed'] ?? "";
    RPM = SUAData['RPM'] ?? "";
    CoolantTemp = SUAData['CoolantTemp'] ?? "";
    IntakeTemp = SUAData['IntakeTemp'] ?? "";
    EngineLoad = SUAData['EngineLoad'] ?? "";
    IntakePressure = SUAData['IntakePressure'] ?? "";
    PressureValues['acc'] = SUAData['PressureValues']['acc'] ?? 0;
    PressureValues['brk'] = SUAData['PressureValues']['brk'] ?? 0;

    notifyListeners();
  }

  void setSUAId(String id) {
    SUAId = id;
  }
}

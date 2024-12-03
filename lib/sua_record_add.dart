import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SUAProvider.dart';
import 'user_provider.dart';
import 'http_service.dart';

class SuaRecordAdd extends StatefulWidget {
  @override
  _SuaRecordAddState createState() => _SuaRecordAddState();
}

class _SuaRecordAddState extends State<SuaRecordAdd> {
  String userId = "";
  String suaId = "";
  String time = "";

  bool isSUA = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    userId = user.userId ?? "";

    // Timer를 통해 상태 지속 확인
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      checkSUAState();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer 정리
    super.dispose();
  }

  void checkSUAState() {
    final sua = Provider.of<SuaProvider>(context, listen: false);
    final suaValue = sua.data['SUA']; // SUA 값 확인

    print("SUAValue: $suaValue");

    if (suaValue == "True" && !isSUA) {
      // SUA가 true이고 isSUA가 false일 때
      addSUA();
    } else if (suaValue == "True" && isSUA) {
      // SUA가 true이고 isSUA가 true일 때
      addTimeSUA();
    } else if (suaValue == "False" && isSUA) {
      // SUA가 false이고 isSUA가 true일 때
      quitSUA();
    }
  }

  Future<void> addSUA() async {
    try {
      final sua = Provider.of<SuaProvider>(context, listen: false);
      time = sua.data['timeStamp'] ?? DateTime.now().toIso8601String();

      final requestBody = {
        "userId": userId,
        "SUAOnTime": time,
      };

      final response = await HttpService().postRequest("SUARecord/add", requestBody);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          suaId = data['data']['suaid'];
          isSUA = true;
        });
        print("SUA Record added successfully. suaId: $suaId");
      } else {
        print("Failed to add SUA Record: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding SUA Record: $e");
    }
  }

  Future<void> addTimeSUA() async {
    try {
      final sua = Provider.of<SuaProvider>(context, listen: false);
      final data = sua.data;
      time = sua.data['timeStamp'] ?? DateTime.now().toIso8601String();

      final response = await HttpService().postRequest("SUARecord/timestamp/add", {
        "timestamp": time,
        "SUAId": suaId,
        "accPressure": data['PressureValues']['acc'],
        "brakePressure": data['PressureValues']['brk'],
        "speed": data['Speed'],
        "rpm": data['RPM'],
        "coolantTemperature": data['CoolantTemp'],
        "intakeTemperature": data['IntakeTemp'],
        "intakePressure": data['IntakePressure'],
        "engineLoad": data['EngineLoad'],
        "throttlePosition": data['Throttle Pos']
      });

      if (response.statusCode == 200) {
        print("TimeSUA Record added successfully.");
      } else {
        print("Failed to add SUA TimeStamp: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding SUA TimeStamp: $e");
    }
  }

  Future<void> quitSUA() async {
    try {
      final sua = Provider.of<SuaProvider>(context, listen: false);
      time = sua.data['timeStamp'] ?? DateTime.now().toIso8601String();

      final response = await HttpService().postRequest("SUARecord/quit", {
        "suaid": suaId,
        "SUAOffTime": time,
      });

      if (response.statusCode == 200) {
        setState(() {
          isSUA = false;
        });
        print("SUA Record quit successfully.");
      } else {
        print("Failed to quit SUA: ${response.statusCode}");
      }
    } catch (e) {
      print("Error quitting SUA: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add SUA Record")),
      body: Center(
        child: Text(
          "Monitoring SUA state...\n\nSUA: ${isSUA ? "Active" : "Inactive"}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SUAProvider.dart';
import 'user_provider.dart';
import 'http_service.dart';
import 'car_provider.dart';

class SuaRecordAdd extends StatefulWidget {
  @override
  _SuaRecordAddState createState() => _SuaRecordAddState();
}

class _SuaRecordAddState extends State<SuaRecordAdd> {
  String userId = "";
  String suaId = "";
  String time = "";

  bool isSUA = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    final sua = Provider.of<SuaProvider>(context, listen: false);
    final car = Provider.of<CarProvider>(context, listen: false);

    setState(() {
      userId = user.userId ?? "";
      suaId = sua.SUAId;
    });
  }

  Future<void> addSUA() async {
    try {
      if (isSUA == true) {
        return;
      }
      final sua = Provider.of<SuaProvider>(context, listen: false);
      time = sua.data['timeStamp'] ?? '2024-12-04T00:18:54';

      print("SUAOnTime: $time"); // time 값 출력

      final requestBody = {
        "userId": userId,
        "SUAOnTime": time.toString(),
      };

      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await HttpService().postRequest("SUARecord/add", requestBody);

      String res = response.body;
      int status = response.statusCode;

      print("Response Body: $res");
      print("Status: $status");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        suaId = data['data']['suaid'];
        print("suaid: $suaId");
        isSUA = true;
        print("Success to add SUA Record");
      } else {
        print("Failed to add SUA Record: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding SUA Record: $e");
    }
  }

  Future<void> addTimeSUA() async {
    try {
      final sua = Provider.of<SuaProvider>(context, listen: false); // SuaProvider 가져오기
      final data = sua.data; // SuaProvider에서 데이터를 가져옴
      time = sua.data['timeStamp'] ?? '2024-12-04T00:18:54';

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
        "engineLoad": data['EngineLoad']
      });

      String res = response.body;
      print("Response Body: $res");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // 서버 응답 처리
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
      time = sua.data['timeStamp'] ?? '2024-12-04T00:18:54';
      final response = await HttpService().postRequest("SUARecord/quit", {"suaid": suaId, "SUAOffTime": time},);

      if (response.statusCode == 200) {
        print("Success request");
        isSUA = false;
      } else {
        print("Failed to quit SUA: ${response.statusCode}");
      }
    } catch (e) {
      print("Error quiting SUA: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add SUA Record")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: addSUA, // addSUA 호출 버튼
              child: Text("Add SUA Record"),
            ),
            SizedBox(height: 16), // 버튼 간 간격
            ElevatedButton(
              onPressed: addTimeSUA, // addTimeSUA 호출 버튼
              child: Text("Add Time SUA Record"),
            ),
            SizedBox(height: 16), // 버튼 간 간격
            ElevatedButton(
              onPressed: quitSUA, // addTimeSUA 호출 버튼
              child: Text("quitSUA")
            ),
          ],
        ),
      ),
    );
  }
}

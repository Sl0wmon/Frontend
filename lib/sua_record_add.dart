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

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    final sua = Provider.of<SuaProvider>(context, listen: false);

    setState(() {
      userId = user.userId ?? "";
      suaId = sua.SUAId;
    });
  }

  Future<void> addSUA() async {
    try {
      final response = await HttpService().postRequest("SUARecord/add", {"userId": userId, "SUAOnTime": DateTime.now().toIso8601String()},);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        suaId = data['suaid'];
      } else {
        print("Failed to add SUA Record: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding SUA Record: $e");
    }
  }

  Future<void> addTimeSUA() async {
    try {
      final response = await HttpService().postRequest("SUARecord/timestamp/add", {});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 데이터.. 가져와서 보내는거.. 응..
      } else {
        print("Failed to add SUA TimeStamp: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding SUA Record: $e");
    }
  }
  
  Future<void> quitSUA() async {
    try {
      final response = await HttpService().postRequest("SUARecord/quit", {"suaid": suaId, "SUAOffTime": DateTime.now().toIso8601String()},);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
        child: ElevatedButton(
          onPressed: addSUA, // 버튼을 눌러 addSUA 호출
          child: Text("Add Record"),
        ),
      ),
    );
  }
}

// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slomon/addCarInfo_page.dart';
import 'package:slomon/myPage.dart';
import 'package:slomon/notification_page.dart';
import 'package:slomon/registerReplacePage.dart';
import 'package:slomon/replacementCycle.dart';
import 'record_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'slomon',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyPage(),
      routes: {
        '/record': (context) => RecordPage(),
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}

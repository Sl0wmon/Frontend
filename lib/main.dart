// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slomon/addCarInfo_page.dart';
import 'package:slomon/myPage.dart';
import 'package:slomon/notification_page.dart';
import 'package:slomon/registerReplacePage.dart';
import 'package:slomon/replacementCycle.dart';
import 'DataProvider.dart';
import 'record_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'ble_page.dart'; // BLE 관련 페이지 추가
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'car_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MyApp(),
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // UserProvider를 전역 상태로 등록
        ChangeNotifierProvider(create: (_) => CarProvider()),  // CarProvider를 전역 상태로 등록
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'slomon',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: BluetoothPage(),
      routes: {
        '/record': (context) => RecordPage(),
        '/dashboard': (context) => DashboardPage(),
        '/ble': (context) => BluetoothPage(), // BLE 페이지 라우트 추가
      },
    );
  }
}

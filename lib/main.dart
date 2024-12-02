import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'addCarInfo_page.dart';
import 'myPage.dart';
import 'notification_page.dart';
import 'registerReplacePage.dart';
import 'replacementCycle.dart';
import 'DataProvider.dart';
import 'SUAProvider.dart';
import 'record_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'ble_page.dart'; // BLE 관련 페이지 추가
import 'user_provider.dart';
import 'car_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()), // DataProvider 등록
        ChangeNotifierProvider(create: (_) => UserProvider()), // UserProvider 등록
        ChangeNotifierProvider(create: (_) => CarProvider()),  // CarProvider 등록
        ChangeNotifierProvider(create: (_) => SuaProvider()),
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
      debugShowCheckedModeBanner: false,
      title: 'slomon',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginPage(), // 로그인 페이지를 초기 화면으로 설정
      routes: {
        '/record': (context) => RecordPage(),
        '/dashboard': (context) => DashboardPage(),
        '/ble': (context) => BluetoothPage(), // BLE 페이지 라우트 추가
        '/notification': (context) => NotificationPage(), // 알림 페이지 라우트 추가
        '/addCarInfo': (context) => AddCarInfoPage(), // 차량 정보 추가 페이지
        '/myPage': (context) => MyPage(), // 마이 페이지 추가
        '/replacementCycle': (context) => ReplacementCyclePage(), // 교체 주기 페이지
        '/registerReplace': (context) => RegisterReplacePage(), // 교체 등록 페이지
      },
    );
  }
}

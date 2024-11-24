import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dashboard_page.dart';
import 'regist_page.dart';
import 'http_service.dart';
import 'user_provider.dart';
import 'car_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  String? _password;

  // 로그인 상태 확인 코드
  @override
  void initState() {
    super.initState();
    // 로그인 상태 확인
    Future.delayed(Duration.zero, () {
      final userProvider = context.read<UserProvider>();
      if (userProvider.userId != null && userProvider.password != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    });
  }

  Future<void> fetchData() async {
    // 아이디와 비밀번호가 null인 경우 처리
    if (_userId == null || _password == null || _userId!.isEmpty || _password!.isEmpty) {
      _showDialog("아이디와 비밀번호를 입력하세요.");
      return;
    }

    final loginData = {
      "userId": _userId,
      "pw": _password
    };

    try {
      final response = await HttpService().postRequest("user/login", loginData);

      print("LoginData: $loginData");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == "true" && data['data'] == true) {
          final userInfoResponse = await HttpService().postRequest("user/view",
            {"userId": _userId},
          );

          if (userInfoResponse.statusCode == 200) {
            final userInfo = jsonDecode(userInfoResponse.body);

            if (userInfo['success'] == "true") {
              final userData = userInfo['data'];

              context.read<UserProvider>().login(
                _userId!,
                _password!,
                name: userData['name'],
                phoneNumber: userData['phoneNumber'],
              );

              // 차량 정보 조회 요청
              final carInfoResponse = await HttpService().postRequest(
                "car/view/user",
                {"userId": _userId},
              );

              if (carInfoResponse.statusCode == 200) {
                final carInfo = jsonDecode(carInfoResponse.body);

                if (carInfo['success'] == "true" && carInfo['data'] != null && carInfo['data'].isNotEmpty) {
                  final carData = carInfo['data'][0]; // 첫 번째 차량 정보
                  context.read<CarProvider>().setCarInfo(carData); // CarProvider에 차량 정보 저장
                } else {
                  // 빈 데이터일 경우 빈 문자열로 처리
                  context.read<CarProvider>().setCarInfo({
                    'carId': "",
                    'manufacturer': "",
                    'size': "",
                    'model': "",
                    'fuel': "",
                    'displacement': "",
                    'year': 0,
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
                }
              } else {
                _showDialog("차량 정보 조회 서버 오류가 발생했습니다.");
              }
            } else {
              _showDialog("회원 정보를 가져오는 데 실패했습니다.");
            }
          } else {
            _showDialog("회원 정보 조회 서버 오류가 발생했습니다.");
          }
        } else {
          _showInputError("아이디와 비밀번호를 확인해주세요.");
        }
      } else {
        _showDialog("서버 오류가 발생했습니다.");
        int code = response.statusCode;
        print("error code: $code");
      }
    } catch (e) {
      _showDialog("네트워크 오류가 발생했습니다.");
      print("Error: $e");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("알림"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _showInputError(String message) {
    setState(() {
      if (_userId?.isEmpty ?? true) {
        _userId = '';
      }
      if (_password?.isEmpty ?? true) {
        _password = '';
      }
    });
    _showDialog(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: colorFromHex('#818585'),
              fontFamily: 'head'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: colorFromHex('#8CD8B4'),
            height: 4.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: TextStyle(
                      fontFamily: 'body',
                      fontSize: 18,
                      color: colorFromHex('#818585')),
                  filled: true,
                  fillColor: colorFromHex('#F0F0F0'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userId = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(
                      fontFamily: 'body',
                      fontSize: 18,
                      color: colorFromHex('#818585')),
                  filled: true,
                  fillColor: colorFromHex('#F0F0F0'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorFromHex('#8CD8B4'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    fetchData(); // 로그인 시 HTTP 통신
                  }
                },
                child: Text(
                  '로그인',
                  style: TextStyle(
                      color: colorFromHex('#FFFFFF'),
                      fontSize: 24,
                      fontFamily: 'head'),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '아직 회원이 아니신가요?',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: 'body'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistPage()),
                  );
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(
                      color: colorFromHex('#7CC0A0'),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontFamily: 'head'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }
}

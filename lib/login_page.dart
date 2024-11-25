import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // DashboardPage를 import합니다.
import 'regist_page.dart'; // RegistPage를 import합니다. (추가)
import 'http_service.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  String receivedData = "";

  final _formKey = GlobalKey<FormState>();
  String? _userId;  // userId로 변경
  String? _password;

  // fetchData 함수 수정
  Future<void> fetchData() async {
    final loginData = {
      "userId": _userId,
      "pw": _password
    };

    try {
      final response = await HttpService().postRequest("user/login", loginData);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 로그인 성공 시
        if (data['success'] == "true") {
          if (data['data'] == true) {

            // 로그인 성공 후 DashboardPage로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage(  )),
            );
          } else {
            // 아이디와 비밀번호 오류 표시
            _showInputError("아이디와 비밀번호를 확인해주세요.");
          }
        } else {
          // 로그인 실패 처리
          _showDialog("로그인에 실패했습니다.");
        }
      } else {
        // 서버 오류 처리
        _showDialog("서버 오류가 발생했습니다.");
      }
    } catch (e) {
      // 네트워크 오류 처리
      _showDialog("네트워크 오류가 발생했습니다.");
    }
  }

  // Dialog 메시지 표시 함수
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("알림"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 아이디와 비밀번호 필드에 오류 표시
  void _showInputError(String message) {
    setState(() {
      // 필드에 오류 표시
      if (_userId?.isEmpty ?? true) {
        _userId = '';  // 빈 값으로 만들어서 오류를 트리거
      }
      if (_password?.isEmpty ?? true) {
        _password = '';  // 빈 값으로 만들어서 오류를 트리거
      }
    });

    _showDialog(message);  // Dialog 메시지 표시
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
          preferredSize: Size.fromHeight(4.0),
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
                  _userId = value; // userId로 수정
                },
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorFromHex('#8CD8B4'), // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // 버튼 가로 길이 조정
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
              SizedBox(height: 40),
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
                    MaterialPageRoute(builder: (context) => RegistPage()), // 회원가입 페이지로 이동
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
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }
}

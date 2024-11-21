import 'package:flutter/material.dart';
import 'login_page.dart';
import 'http_service.dart';
import 'dart:convert';

class RegistPage extends StatefulWidget {
  @override
  _RegistPageState createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _userId;
  String? _name;
  String? _phoneNumber;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // 폼 검증 실패 시 함수 종료
    }

    _formKey.currentState!.save(); // 입력된 데이터 저장

    // 비밀번호와 비밀번호 확인 값이 같은지 확인
    if (_passwordController.text != _confirmPasswordController.text) {
      _showDialog("비밀번호 불일치", "비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      return;
    }

    // 아이디 중복 체크
    final checkIdData = {"userId": _userId};

    try {
      final response = await HttpService().postRequest("user/checkId", checkIdData);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["data"] == true) {
          _showDialog("중복된 아이디", "이미 사용 중인 아이디입니다. 다른 아이디를 입력하세요.");
          return;
        }
      } else {
        _showDialog("서버 오류", "서버와의 통신 중 오류가 발생했습니다.");
        return;
      }
    } catch (e) {
      _showDialog("네트워크 오류", "네트워크 연결이 원활하지 않습니다.");
      return;
    }

    // 전화번호 중복 체크
    final checkPhoneData = {"phoneNumber": _phoneNumber};

    try {
      final response =
      await HttpService().postRequest("user/checkPhoneNumber", checkPhoneData);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] == true) {
          _showDialog("중복된 전화번호", "이미 사용 중인 전화번호입니다. 전화번호를 확인해주세요");
          return;
        }
      } else {
        _showDialog('서버 오류', '서버와의 통신 중 오류가 발생했습니다.');
        return;
      }
    } catch (e) {
      _showDialog("네트워크 오류", "네트워크 연결이 원활하지 않습니다.");
      return;
    }

    // 회원가입 요청 데이터
    final data = {
      "userId": _userId,
      "pw": _passwordController.text,
      "name": _name,
      "phoneNumber": _phoneNumber,
    };

    try {
      final response = await HttpService().postRequest("user/register", data);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == "true") {
          _showDialog("회원가입 성공", "회원가입에 성공하셨습니다.");
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else {
          _showDialog("회원가입 실패", "회원가입에 실패하였습니다. 잠시 후 다시 시도해 주십시오.");
        }
      } else {
        _showDialog("서버 오류", "서버와의 통신 중 오류가 발생했습니다.");
      }
    } catch (e) {
      _showDialog("네트워크 오류", "네트워크 연결이 원활하지 않습니다.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '회원가입',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorFromHex('#818585'),
            fontSize: 30,
            fontFamily: 'head',
          ),
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
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: TextStyle(
                      fontFamily: 'body', fontSize: 18, color: colorFromHex('#818585')),
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
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(
                      fontFamily: 'body', fontSize: 18, color: colorFromHex('#818585')),
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
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: TextStyle(
                      fontFamily: 'body', fontSize: 18, color: colorFromHex('#818585')),
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
                    return '비밀번호 확인을 입력하세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이름',
                  labelStyle: TextStyle(
                      fontFamily: 'body', fontSize: 18, color: colorFromHex('#818585')),
                  filled: true,
                  fillColor: colorFromHex('#F0F0F0'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '전화번호',
                  labelStyle: TextStyle(
                      fontFamily: 'body', fontSize: 18, color: colorFromHex('#818585')),
                  filled: true,
                  fillColor: colorFromHex('#F0F0F0'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력하세요.';
                  }
                  if (value.length != 11) { // 전화번호 길이 확인
                    return '전화번호는 10자리여야 합니다.';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) { // 숫자인지 확인
                    return '전화번호는 숫자만 입력 가능합니다.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value;
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerUser,
                child: Text(
                  '등록',
                  style: TextStyle(
                      color: colorFromHex('#FFFFFF'),
                      fontSize: 24,
                      fontFamily: 'head'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorFromHex('#8CD8B4'),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

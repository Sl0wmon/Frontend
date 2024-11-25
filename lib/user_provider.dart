import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _password;
  String? _name;
  String? _phoneNumber;

  String? get userId => _userId;
  String? get password => _password;
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;

  // 로그인 처리
  void login(String userId, String password, {String? name, String? phoneNumber}) {
    _userId = userId;
    _password = password;
    _name = name;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  // 로그아웃 처리
  void logout() {
    _userId = null;
    _password = null;
    _name = null;
    _phoneNumber = null;
    notifyListeners();
  }

  void updateUser(String? name, String? phoneNumber) {
    _name = name;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }
}

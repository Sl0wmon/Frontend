import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'http_service.dart';
import 'user_provider.dart'; // UserProvider 파일 import
import 'myPage.dart'; // MyPage 파일 import

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({Key? key}) : super(key: key);

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String userId = "";
  String pw = "";

  @override
  void initState() {
    super.initState();
    // 기존 이름과 전화번호를 UserProvider에서 가져오기
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = user.name != null ? utf8.decode(user.name!.codeUnits) : ""; // 이름 기본값
    _phoneController.text = user.phoneNumber ?? ''; // 전화번호 기본값
    setState(() {
      userId = user.userId ?? "";
      pw = user.password ?? "";
    });
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size *
        (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  Future<void> _updateUser() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 필드를 입력해주세요.")),
      );
      return;
    }

    final updateData = {
      "userId": userId,
      "pw": pw,
      "name": name,
      "phoneNumber": phone,
    };

    try {
      final response = await HttpService().postRequest("user/update", updateData);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == "true") {
          // 수정 성공
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUser(name, phone); // UserProvider 업데이트

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("수정이 완료되었습니다.")),
          );

          // MyPage로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyPage()),
                (route) => false, // 이전 화면 제거
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("수정에 실패했습니다.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 오류가 발생했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "내 정보 수정",
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(context, 24),
            fontFamily: 'head',
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            color: Color(0xFF8CD8B4),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "이름",
              style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 16),
                color: Colors.grey,
                fontFamily: 'body',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEFEFEF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 16),
                fontFamily: 'body',
              ),
            ),
            SizedBox(height: 16),
            Text(
              "전화번호",
              style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 16),
                color: Colors.grey,
                fontFamily: 'body',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEFEFEF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 16),
                fontFamily: 'body',
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8CD8B4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "수정",
                style: TextStyle(
                  fontSize: _getAdaptiveFontSize(context, 16),
                  color: Colors.white,
                  fontFamily: 'body',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

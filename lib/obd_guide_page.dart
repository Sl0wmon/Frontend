import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'http_service.dart';
import 'car_provider.dart';
import 'user_provider.dart';
import 'drawer_widget.dart';

class ObdGuidePage extends StatefulWidget {
  const ObdGuidePage({super.key});

  @override
  _ObdGuidePageState createState() => _ObdGuidePageState();
}

class _ObdGuidePageState extends State<ObdGuidePage> {
  final List<Map<String, String>> diagnosticResults = [];
  final TextEditingController _errCodeController = TextEditingController();
  String name = ""; // 이름 변수
  String carType = "";

  @override
  void initState() {
    super.initState();
    // UserProvider에서 name 가져오기
    final user = Provider.of<UserProvider>(context, listen: false);
    final car = Provider.of<CarProvider>(context, listen: false);
    setState(() {
      // name을 UTF-8로 디코딩하여 처리
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      carType = car.manufacturer;
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

  Future<void> fetchData() async {
    final errCode = _errCodeController.text.trim();
    if (errCode.isEmpty) {
      setState(() {
        diagnosticResults.clear();
      });
      return;
    }

    final codeData = {
      "errCode": errCode,
      "carType": carType,
    };

    try {
      final response = await HttpService().postRequest("guide/search/code", codeData);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩

        if (data['success'] == "true") {
          setState(() {
            diagnosticResults.clear();
            for (var item in data['data']) {
              String errCodeFromApi = item['errCode'] ?? '알 수 없음';
              String description = item['description'] ?? '설명 없음';

              // 숫자+알파벳 코드와 설명 부분 분리
              final codeMatch = RegExp(r'^([A-Z0-9, 또는]+)\s+(.+)$').firstMatch(errCodeFromApi);
              if (codeMatch != null) {
                errCodeFromApi = codeMatch.group(1)!.trim(); // 코드 부분
                description = codeMatch.group(2)!.trim();   // 설명 부분
              }

              diagnosticResults.add({
                "code": errCodeFromApi,
                "description": description,
              });
            }
          });
        } else {
          setState(() {
            diagnosticResults.clear();
          });
        }
      } else {
        setState(() {
          diagnosticResults.clear();
        });
      }
    } catch (e) {
      setState(() {
        diagnosticResults.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFromHex('#ECECEC'),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          "OBD 진단 가이드",
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(context, 28),
            fontFamily: 'head',
            color: colorFromHex('#818585'),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            color: colorFromHex('#8CD8B4'),
          ),
        ),
      ),
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _errCodeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "OBD2 표준 진단코드를 입력해주세요",
                hintStyle: TextStyle(
                  fontFamily: 'body',
                  fontSize: _getAdaptiveFontSize(context, 16),
                  color: colorFromHex('#B0B0B0'),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: colorFromHex('#8CD8B4')),
                  onPressed: fetchData,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontFamily: 'body',
                fontSize: _getAdaptiveFontSize(context, 16),
              ),
            ),
          ),
          // 진단 결과 리스트
          Expanded(
            child: ListView.builder(
              itemCount: diagnosticResults.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경 색상을 흰색으로 설정
                    borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게 설정
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2), // 살짝 아래쪽으로 그림자
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      diagnosticResults[index]['code']!,
                      style: TextStyle(
                        fontFamily: 'body',
                        fontSize: _getAdaptiveFontSize(context, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      diagnosticResults[index]['description']!,
                      style: TextStyle(
                        fontFamily: 'body',
                        fontSize: _getAdaptiveFontSize(context, 18),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color colorFromHex(String hex) {
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }
}

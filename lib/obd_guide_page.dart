import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'http_service.dart';
import 'car_provider.dart';
import 'user_provider.dart';
import 'drawer_widget.dart';
import 'guide_detail.dart';

class ObdGuidePage extends StatefulWidget {
  const ObdGuidePage({super.key});

  @override
  _ObdGuidePageState createState() => _ObdGuidePageState();
}

class _ObdGuidePageState extends State<ObdGuidePage> {
  final List<Map<String, dynamic>> diagnosticResults = []; // errId 포함
  final TextEditingController _errCodeController = TextEditingController();
  String name = ""; // 이름 변수
  String carType = "";

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    final car = Provider.of<CarProvider>(context, listen: false);

    setState(() {
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      carType = car.manufacturer;
    });

    _fetchAllDiagnosticResults();
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
                "id": item['errId'], // id는 그대로 추가
                "code": errCodeFromApi, // 분리된 코드 부분 저장
                "description": description, // 분리된 설명 부분 저장
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

  Future<void> _fetchAllDiagnosticResults() async {
    try {
      final response = await HttpService().postRequest("guide/all", {"carType": carType});

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
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
                "id": item['errId'], // id는 그대로 추가
                "code": errCodeFromApi, // 분리된 코드 부분 저장
                "description": description, // 분리된 설명 부분 저장
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

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size *
        (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFromHex('#ECECEC'),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          'OBD 진단 가이드',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: Color(0xFF818585)
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Icon(Icons.notifications, color: Colors.grey),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(
            height: 7,
            color: Color(0xFF8CD8B4),
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
          Expanded(
            child: ListView.builder(
              itemCount: diagnosticResults.length,
              itemBuilder: (context, index) {
                final diagnosticItem = diagnosticResults[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      diagnosticItem['code']!,
                      style: TextStyle(
                        fontFamily: 'body',
                        fontSize: _getAdaptiveFontSize(context, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      diagnosticItem['description']!,
                      style: TextStyle(
                        fontFamily: 'body',
                        fontSize: _getAdaptiveFontSize(context, 18),
                      ),
                    ),
                    onTap: () async {
                      final errId = diagnosticItem['id']; // errId 가져오기
                      try {
                        // API 요청: 선택된 errId를 서버로 전송
                        final response = await HttpService().postRequest("guide/detail", {
                          "errId": errId, // errId 전달
                        });

                        if (response.statusCode == 200) {
                          final data = jsonDecode(utf8.decode(response.bodyBytes));

                          if (data['success'] == "true" && data['data'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuideDetailPage(
                                  guideData: data, // 서버에서 받은 상세 정보 전달
                                ),
                              ),
                            );
                          } else {
                            _showErrorDialog(context, "가이드 상세 정보를 찾을 수 없습니다.");
                          }
                        } else {
                          _showErrorDialog(context, "서버 응답에 문제가 있습니다.");
                        }
                      } catch (e) {
                        _showErrorDialog(context, "가이드 정보를 가져오는 중 오류가 발생했습니다.");
                      }
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("오류"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  Color colorFromHex(String hex) {
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }
}
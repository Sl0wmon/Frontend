import 'dart:convert';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'record_page.dart';
import 'http_service.dart';

class ObdGuidePage extends StatefulWidget {
  const ObdGuidePage({super.key});

  @override
  _ObdGuidePageState createState() => _ObdGuidePageState();
}

class _ObdGuidePageState extends State<ObdGuidePage> {
  final List<Map<String, String>> diagnosticResults = [];
  final TextEditingController _errCodeController = TextEditingController();

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

    final codeData = {"errCode": errCode};

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

              // "errCode"는 첫 번째 부분만 가져오고, 나머지는 "description"으로 처리
              final codeMatch = RegExp(r'^[A-Z0-9]+').firstMatch(errCodeFromApi);
              String code = codeMatch != null ? codeMatch.group(0)! : '알 수 없음';

              // "description"은 코드 뒤의 부분을 사용
              String desc = '${errCodeFromApi.replaceFirst(code, '').trim()} $description';

              diagnosticResults.add({
                "code": code,
                "description": desc,
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
    final searchQuery = _errCodeController.text.trim();

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
      drawer: _buildDrawer(context),
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorFromHex('#D8D8D8'),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorFromHex('#8CD8B4'),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 동적으로 검색어에 맞는 "검색 결과" 제목
                Text(
                  searchQuery.isEmpty
                      ? "검색 결과"
                      : '"$searchQuery" 검색 결과',
                  style: TextStyle(
                    fontFamily: 'head',
                    fontSize: _getAdaptiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(
                  color: colorFromHex('#8CD8B4'),
                  thickness: 2,
                  endIndent: MediaQuery.of(context).size.width * 0.7,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: diagnosticResults.isEmpty
                  ? Center(
                child: Text(
                  "조회된 결과가 없습니다.",
                  style: TextStyle(
                    fontFamily: 'body',
                    fontSize: _getAdaptiveFontSize(context, 18),
                    color: colorFromHex('#6D6D6D'),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: diagnosticResults.length,
                itemBuilder: (context, index) {
                  final result = diagnosticResults[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                        title: Text(
                          result["code"]!,
                          style: TextStyle(
                            fontFamily: 'head',
                            fontWeight: FontWeight.bold,
                            fontSize: _getAdaptiveFontSize(context, 20),
                            color: colorFromHex('#000000'),
                          ),
                        ),
                        subtitle: Text(
                          result["description"]!,
                          style: TextStyle(
                            fontFamily: 'body',
                            fontSize: _getAdaptiveFontSize(context, 16),
                            color: colorFromHex('#6D6D6D'),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: colorFromHex('#8CD8B4'),
                          size: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
            child: Text(
              '사이드 메뉴',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getAdaptiveFontSize(context, 24),
                fontFamily: 'head',
              ),
            ),
          ),
          _buildDrawerItem(context, "대시보드", Icons.dashboard, () {
            Navigator.pop(context);
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }),
          _buildDrawerItem(context, "급발진 상황 기록", Icons.history, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const RecordPage()));
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.autorenew, () {}),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.support, () {}),
          _buildDrawerItem(context, "알림", Icons.notifications, () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: colorFromHex('#8CD8B4')),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'body',
          fontSize: _getAdaptiveFontSize(context, 18),
          color: colorFromHex('#8CD8B4'),
        ),
      ),
      onTap: onTap,
    );
  }

  Color colorFromHex(String hex) {
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }
}

import 'package:flutter/material.dart';
import 'package:slomon/dashboard_page.dart';
import 'record_page.dart';

class ObdGuidePage extends StatelessWidget {
  final List<Map<String, String>> diagnosticResults = [
    {"code": "B1102", "description": "에어백 배터리 전압 낮음"},
    {"code": "B1214", "description": "후방 좌측 센서 고장"},
    {"code": "B1215", "description": "후방 중앙 좌측 센서 고장"},
    {"code": "B1216", "description": "후방 중앙 우측 센서 고장"},
    {"code": "B1322", "description": "승객 구분 시스템 센서 결함"},
    {"code": "B1324", "description": "승객 구분 시스템 통신 오류"},
  ];

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    final baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFromHex('#EFEEEE'), // 배경색 설정
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
            icon: Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {
              // 알림 버튼 클릭 이벤트 추가 가능
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
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
              decoration: InputDecoration(
                filled: true, // 배경색 활성화
                fillColor: Colors.white, // 흰색 배경
                hintText: "OBD2 표준 진단코드를 입력해주세요",
                hintStyle: TextStyle(
                  fontFamily: 'body',
                  fontSize: _getAdaptiveFontSize(context, 16),
                  color: colorFromHex('#B0B0B0'),
                ),
                suffixIcon: Icon(Icons.search, color: colorFromHex('#8CD8B4')),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorFromHex('#D8D8D8'),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorFromHex('#8CD8B4'), // 선택 시 테두리 색상
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KIA 제조사 기반 검색 결과",
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
              child: Container(
                //color: Colors.white, // 리스트 배경색 설정
                child: ListView.builder(
                  itemCount: diagnosticResults.length,
                  itemBuilder: (context, index) {
                    final result = diagnosticResults[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0), // 리스트 간 간격
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // 카드 배경색
                          borderRadius: BorderRadius.circular(12.0), // 테두리 둥글게
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2), // 그림자 위치 조정
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
                          onTap: () {
                            // 각 리스트 항목 클릭 이벤트 처리
                          },
                        ),
                      ),
                    );
                  },
                ),
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
            child: Text(
              '사이드 메뉴',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getAdaptiveFontSize(context, 24),
                fontFamily: 'head',
              ),
            ),
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
          ),
          _buildDrawerItem(context, "대시보드", Icons.dashboard, () {
            Navigator.pop(context);
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => DashboardPage())
            );
          }),
          _buildDrawerItem(context, "급발진 상황 기록", Icons.history, () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RecordPage()));
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.car_repair, () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.info, () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, "알림", Icons.notifications, () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: colorFromHex('#8CD8B4')),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
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

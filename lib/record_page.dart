import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 사용을 위해 추가
import 'package:slomon/http_service.dart';
import 'info_box.dart';
import 'stat_box.dart';
import 'graph_card.dart';
import 'pedal_chart.dart';
import 'speed_chart.dart';
import 'drawer_widget.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  String selectedDate = ''; // 날짜를 빈 문자열로 초기화
  String name = ""; // 이름 변수
  String userId = "";
  bool hasRecord = false; // 급발진 기록이 있는지 여부를 추적
  String formattedOnTime = ''; // 급발진 시작 시간
  String formattedOffTime = ''; // 급발진 종료 시간
  bool isLoading = true; // 로딩 상태를 관리하기 위한 변수 추가

  @override
  void initState() {
    super.initState();
    // UserProvider에서 name 가져오기
    final user = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      // name을 UTF-8로 디코딩하여 처리
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      userId = user.userId ?? "";
    });

    fetchData(); // 데이터 fetch
  }

  Future<void> fetchData() async {
    try {
      final response = await HttpService().postRequest("SUARecord/list", {"userId": userId});

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          List<dynamic> records = jsonData['data'];  // 급발진 기록 리스트
          records.sort((a, b) {
            DateTime aTime = DateTime(a['suaonTime'][0], a['suaonTime'][1], a['suaonTime'][2], a['suaonTime'][3], a['suaonTime'][4]);
            DateTime bTime = DateTime(b['suaonTime'][0], b['suaonTime'][1], b['suaonTime'][2], b['suaonTime'][3], b['suaonTime'][4]);
            return bTime.compareTo(aTime); // 내림차순 정렬
          });

          if (records.isNotEmpty) {
            var latestRecord = records[0];
            setState(() {
              DateTime onTime = DateTime(
                latestRecord['suaonTime'][0], // 년
                latestRecord['suaonTime'][1], // 월
                latestRecord['suaonTime'][2], // 일
                latestRecord['suaonTime'][3], // 시간
                latestRecord['suaonTime'][4], // 분
                latestRecord['suaonTime'].length > 5 ? latestRecord['suaonTime'][5] : 0,
              );

              DateTime offTime = DateTime(
                latestRecord['suaoffTime'][0], // 년
                latestRecord['suaoffTime'][1], // 월
                latestRecord['suaoffTime'][2], // 일
                latestRecord['suaoffTime'][3], // 시간
                latestRecord['suaoffTime'][4], // 분
                latestRecord['suaoffTime'].length > 5 ? latestRecord['suaoffTime'][5] : 0,
              );

              formattedOnTime = DateFormat('HH:mm:ss').format(onTime);
              formattedOffTime = DateFormat('HH:mm:ss').format(offTime);

              // 날짜 형식으로 selectedDate 설정
              selectedDate = DateFormat('yyyy.MM.dd').format(onTime);
              hasRecord = true;
            });
          } else {
            setState(() {
              selectedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
              hasRecord = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user info: $e');
    } finally {
      setState(() {
        isLoading = false; // 데이터 로드가 끝나면 로딩 상태 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '급발진 상황 기록',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: colorFromHex('#818585')),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Icon(Icons.notifications, color: Colors.grey),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 7,
            color: colorFromHex('#8CD8B4'),
          ),
        ),
      ),
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorFromHex('#8CD8B4'),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasRecord)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: colorFromHex('#8CD8B4'),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    child: Text(
                      '급발진 기록이 존재하지 않습니다.',
                      style: TextStyle(
                        fontSize: _getAdaptiveFontSize(context, 24),
                        color: colorFromHex('#818585'),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (hasRecord) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoBox(
                      icon: Icons.calendar_today,
                      text: selectedDate,
                      onTap: () => _selectDate(context),
                    ),
                    InfoBox(
                      icon: Icons.access_time,
                      text: '$formattedOnTime ~ $formattedOffTime',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StatBox(
                  label: '주행 거리',
                  value: '1.54km',
                  color: colorFromHex('#8CD8B4'),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GraphCard(
                  title: '페달 기록',
                  child: PedalChart(),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GraphCard(
                  title: '속도',
                  subtitle: '평균: 165km',
                  child: SpeedChart(),
                ),
              ),
            ],
          ],
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

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy.MM.dd').format(pickedDate); // 선택한 날짜 포맷팅
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
}

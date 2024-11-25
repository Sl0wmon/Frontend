import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 사용을 위해 추가
import 'http_service.dart';
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
  List<String> suaIds = []; // SUAId 배열 저장
  List<dynamic> records = []; // 급발진 기록 리스트

  @override
  void initState() {
    super.initState();
    // UserProvider에서 name 가져오기
    final user = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      userId = user.userId ?? "";
    });

    fetchData(); // 데이터 fetch
  }

  List<dynamic> originalRecords = []; // 원본 데이터를 저장할 리스트

  Future<void> fetchData() async {
    try {
      final response = await HttpService().postRequest("SUARecord/list", {"userId": userId});

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            // 원본 데이터를 저장
            originalRecords = jsonData['data'];
            // 화면에 표시할 records를 원본 데이터로 초기화
            records = List.from(originalRecords);
            // SUAId 추출하여 리스트에 저장
            suaIds = records.map((record) => record['SUAId'].toString()).toList();
            hasRecord = records.isNotEmpty;

            if (hasRecord) {
              var latestRecord = records[0];
              DateTime onTime = DateTime(
                latestRecord['suaonTime'][0],
                latestRecord['suaonTime'][1],
                latestRecord['suaonTime'][2],
                latestRecord['suaonTime'][3],
                latestRecord['suaonTime'][4],
                latestRecord['suaonTime'].length > 5 ? latestRecord['suaonTime'][5] : 0,
              );

              // 최근 기록 날짜를 selectedDate로 설정
              selectedDate = DateFormat('yyyy.MM.dd').format(onTime);
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching user info: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterRecordsByDate() {
    if (selectedDate.isEmpty) return;

    DateTime selectedDateTime = DateFormat('yyyy.MM.dd').parse(selectedDate);

    setState(() {
      // 필터링 전에 항상 원본 데이터를 참조
      records = originalRecords.where((record) {
        DateTime onTime = DateTime(
          record['suaonTime'][0], // 년
          record['suaonTime'][1], // 월
          record['suaonTime'][2], // 일
        );

        return onTime.year == selectedDateTime.year &&
            onTime.month == selectedDateTime.month &&
            onTime.day == selectedDateTime.day;
      }).toList();

      hasRecord = records.isNotEmpty;
    });
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
        title: Column(
          children: [
            Text(
              '급발진 상황 기록',
              style: TextStyle(
                fontSize: _getAdaptiveFontSize(context, 28),
                fontFamily: 'head',
                color: colorFromHex('#818585'),
              ),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.isNotEmpty
                      ? DateTime.parse(selectedDate.replaceAll('.', '-'))
                      : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = DateFormat('yyyy.MM.dd').format(pickedDate);
                    // 날짜 선택 후 데이터 필터링
                    filterRecordsByDate();
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedDate.isNotEmpty ? selectedDate : '날짜 선택', // 선택된 날짜로 표시
                    style: TextStyle(
                      fontSize: _getAdaptiveFontSize(context, 16),
                      color: colorFromHex('#8CD8B4'),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ],
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
          : hasRecord
          ? PageView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          var record = records[index];
          DateTime onTime = DateTime(
            record['suaonTime'][0],
            record['suaonTime'][1],
            record['suaonTime'][2],
            record['suaonTime'][3],
            record['suaonTime'][4],
            record['suaonTime'].length > 5 ? record['suaonTime'][5] : 0,
          );

          DateTime offTime = DateTime(
            record['suaoffTime'][0],
            record['suaoffTime'][1],
            record['suaoffTime'][2],
            record['suaoffTime'][3],
            record['suaoffTime'][4],
            record['suaoffTime'].length > 5 ? record['suaoffTime'][5] : 0,
          );

          String formattedOnTime = DateFormat('HH:mm:ss').format(onTime);
          String formattedOffTime = DateFormat('HH:mm:ss').format(offTime);
          String selectedDate = DateFormat('yyyy.MM.dd').format(onTime);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜와 시간을 가로로 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoBox(
                      icon: Icons.calendar_today,
                      text: selectedDate,
                    ),
                    InfoBox(
                      icon: Icons.access_time,
                      text: '$formattedOnTime ~ $formattedOffTime',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatBox(
                  label: '주행 거리',
                  value: '1.54km',
                  color: colorFromHex('#8CD8B4'),
                ),
                const SizedBox(height: 16),
                const GraphCard(
                  title: '페달 기록',
                  child: PedalChart(),
                ),
                const SizedBox(height: 16),
                const GraphCard(
                  title: '속도',
                  subtitle: '평균: 165km',
                  child: SpeedChart(),
                ),
              ],
            ),
          );
        },
      )
          : Center(
        child: Text(
          '급발진 기록이 존재하지 않습니다.',
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(context, 24),
            color: colorFromHex('#818585'),
            fontWeight: FontWeight.bold,
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

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 9.0 / 16.0;
    return size * (aspectRatio / baseAspectRatio);
  }
}
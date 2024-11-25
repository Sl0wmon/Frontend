import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 사용을 위해 추가
import 'http_service.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'sua_detail_page.dart'; // 상세 페이지 import

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
      // API 요청
      final response = await HttpService().postRequest("SUARecord/list", {"userId": userId});

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == "true" && jsonData['data'] != null) {
          setState(() {
            // records에 전체 데이터를 저장
            records = List<Map<String, dynamic>>.from(jsonData['data']);

            // suaIds에 suaid 값만 추출하여 저장
            suaIds = records.map((record) => record['suaid'].toString()).toList();

            originalRecords = records; // 원본 데이터 저장
            hasRecord = records.isNotEmpty; // 기록이 있는지 확인
          });
        } else {
          // 데이터가 없거나 성공이 아닌 경우 처리
          setState(() {
            records = [];
            suaIds = [];
            hasRecord = false;
          });
        }
      } else {
        // 응답 상태가 200이 아닌 경우 처리
        setState(() {
          records = [];
          suaIds = [];
          hasRecord = false;
        });
      }
    } catch (e) {
      // 오류 처리
      print('Error fetching user info: $e');
    } finally {
      // 로딩 상태 해제
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
        title: Text(
          '급발진 기록',
          style: TextStyle(fontSize: _getAdaptiveFontSize(context, 24)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorFromHex('#8CD8B4'),
        ),
      )
          : hasRecord
          ? ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          var record = records[index];
          String suaId = record['suaid'].toString(); // 'suaid'로 수정

          // 시작 시간 (suaonTime)
          int startSecond = record['suaonTime'].length > 5
              ? record['suaonTime'][5]
              : 0;

          DateTime startTime = DateTime(
            record['suaonTime'][0], // 년
            record['suaonTime'][1], // 월
            record['suaonTime'][2], // 일
            record['suaonTime'][3], // 시
            record['suaonTime'][4], // 분
            startSecond, // 초
          );

          // 종료 시간 (suaoffTime)
          int endSecond = record['suaoffTime'].length > 5
              ? record['suaoffTime'][5]
              : 0;

          DateTime endTime = DateTime(
            record['suaoffTime'][0], // 년
            record['suaoffTime'][1], // 월
            record['suaoffTime'][2], // 일
            record['suaoffTime'][3], // 시
            record['suaoffTime'][4], // 분
            endSecond, // 초
          );

          return ListTile(
            title: Text(
              'SUA 기록: ${DateFormat('yyyy.MM.dd').format(startTime)} ${DateFormat('HH:mm:ss').format(startTime)} ~ ${DateFormat('HH:mm:ss').format(endTime)}',
              style: TextStyle(fontSize: _getAdaptiveFontSize(context, 16)),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              String selectedSUAId = suaId.toString(); // 수정된 suaId 사용
              print('selected: $selectedSUAId');

              try {
                // API 호출
                final response = await HttpService().postRequest("SUARecord/timestamp/list", {"SUAId": selectedSUAId});
                print("response: $response");

                if (response.statusCode == 200) {
                  var jsonData = json.decode(response.body);

                  if (jsonData['success'] == "true" && jsonData['data'] != null) {
                    var SUAData = jsonData['data'];

                    // SuaDetailPage로 데이터 전달
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuaDetailPage(
                          SUAId: selectedSUAId,
                          SUAData: SUAData,
                        ),
                      ),
                    );
                  } else {
                    _showDialog("데이터를 불러오지 못했습니다.");
                  }
                } else {
                  _showDialog("서버 오류가 발생했습니다.");
                }
              } catch (e) {
                print("Error fetching SUA data: $e");
                _showDialog("데이터를 가져오는 중 문제가 발생했습니다.");
              }
            },
          );
        },
      )
          : Center(
        child: Text(
          '급발진 기록이 없습니다.',
          style: TextStyle(fontSize: _getAdaptiveFontSize(context, 18)),
        ),
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("알림"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
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

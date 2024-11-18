import 'package:flutter/material.dart';

class ReplacementCyclePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}

class _ReplacementCyclePageState extends State<ReplacementCyclePage> {
  // 각 박스의 데이터를 리스트로 관리
  final List<Map<String, dynamic>> boxData = [
    {'title': '엔진 오일', 'remainingDistance': '300.10km', 'lastReplacement': '2024-01-10', 'widthFactor': 0.21},
    {'title': '미션오일', 'remainingDistance': '250.50km', 'lastReplacement': '2024-03-15', 'widthFactor': 0.3},
    {'title': '브레이크', 'remainingDistance': '500.75km', 'lastReplacement': '2024-05-20', 'widthFactor': 0.4},
    {'title': '클러치', 'remainingDistance': '150.30km', 'lastReplacement': '2024-06-25', 'widthFactor': 0.5},
    {'title': '파워스티어링', 'remainingDistance': '220.90km', 'lastReplacement': '2024-07-10', 'widthFactor': 0.6},
    {'title': '냉각수', 'remainingDistance': '400.50km', 'lastReplacement': '2024-08-18', 'widthFactor': 0.7},
    {'title': '연료 필터', 'remainingDistance': '320.45km', 'lastReplacement': '2024-09-01', 'widthFactor': 0.8},
    {'title': '히터 필터', 'remainingDistance': '180.30km', 'lastReplacement': '2024-09-10', 'widthFactor': 0.9},
    {'title': '에어컨 필터', 'remainingDistance': '323.13km', 'lastReplacement': '2024-10-10', 'widthFactor': 0.2},
    {'title': '브레이크 라이닝', 'remainingDistance': '310.00km', 'lastReplacement': '2024-10-05', 'widthFactor': 0.6},
    {'title': '브레이크 패드', 'remainingDistance': '450.40km', 'lastReplacement': '2024-11-01', 'widthFactor': 0.4},
    {'title': '휠 얼라이먼트', 'remainingDistance': '360.60km', 'lastReplacement': '2024-11-15', 'widthFactor': 0.7},
    {'title': '점화플러그', 'remainingDistance': '220.75km', 'lastReplacement': '2024-12-01', 'widthFactor': 0.3},
    {'title': '배터리', 'remainingDistance': '240.90km', 'lastReplacement': '2024-12-10', 'widthFactor': 0.8},
    {'title': '걸 벨트', 'remainingDistance': '180.10km', 'lastReplacement': '2024-12-15', 'widthFactor': 0.5},
    {'title': '타이밍', 'remainingDistance': '150.60km', 'lastReplacement': '2024-12-20', 'widthFactor': 0.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            '<',
            style: TextStyle(fontSize: 24, color: Colors.black, fontFamily: 'body'),
          ),
          onPressed: () => Navigator.pop(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        title: Text(
          '부품 교체 주기',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'head', fontSize: 25, color: Color(0xFF696C6C)),
        ),
      ),
      body: SingleChildScrollView(  // 스크롤 추가
        child: Container(
          color: Colors.grey[200], // 전체 배경 회색 설정
          child: Column(
            children: [
              // 경계선
              Container(
                height: 7.0,
                color: Color(0xFF8CD8B4), // 경계선 색상
              ),
              // 경계선과 박스 사이의 공간 추가
              SizedBox(height: 20), // 경계선과 박스 사이의 간격

              // 연두색 박스들
              for (var box in boxData) ...[
                buildGreenBox(
                  title: box['title'],
                  remainingDistance: box['remainingDistance'],
                  lastReplacement: box['lastReplacement'],
                  widthFactor: box['widthFactor'],
                ),
                SizedBox(height: 20), // 박스 간 간격 추가
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 연두색 박스를 리팩토링하여 재사용할 수 있도록 함수로 분리
  Widget buildGreenBox({
    required String title,
    required String remainingDistance,
    required String lastReplacement,
    required double widthFactor,
  }) {
    return Container(
      width: 350, // 박스의 가로 크기 증가
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF8CD8B4), // 연두색
        borderRadius: BorderRadius.circular(20.0), // 둥근 모서리
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 행(Row)으로 배치: 제목 박스 + 잔여 주행거리 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 두 위젯 간의 공간을 균등하게 배분
            children: [
              // 상단 흰 박스 (제목)
              Container(
                width: 130,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center, // 텍스트를 중앙에 배치
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'head',
                    letterSpacing: 1.2, // 글자 간 간격을 1.2로 설정
                  ),
                ),
              ),
              // 잔여 주행거리와 마지막 교체 텍스트
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '잔여 주행거리: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF696C6C),
                          fontFamily: 'body',
                          letterSpacing: 1.2, // 글자 간 간격을 1.2로 설정
                        ),
                      ),
                      Text(
                        remainingDistance,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'body',
                          letterSpacing: 1.2, // 글자 간 간격을 1.2로 설정
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '마지막 교체: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF696C6C),
                          fontFamily: 'body',
                          letterSpacing: 1.2, // 글자 간 간격을 1.2로 설정
                        ),
                      ),
                      Text(
                        lastReplacement,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'body',
                          letterSpacing: 1.2, // 글자 간 간격을 1.2로 설정
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8), // 두 텍스트 간의 간격 조정
          SizedBox(height: 16),
          // 가로로 긴 막대 그래프
          Container(
            height: 10.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor, // widthFactor를 동적으로 사용
              child: Container(
                decoration: BoxDecoration(
                  color: widthFactor >= 0.8
                      ? Color(0xFFFF7E7E) // widthFactor가 0.8 이상일 경우 색상 변경
                      : Color(0xFF60BF92), // 기본 색상 (연두색 계열)
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 1), // 그래프와 텍스트 간의 간격
          // widthFactor 값과 % 표시
          Align(
            alignment: Alignment.centerRight, // 오른쪽 정렬
            child: Text(
              '${(widthFactor * 100).toStringAsFixed(0)}%', // 퍼센트로 변환
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'body',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

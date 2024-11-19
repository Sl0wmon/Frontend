import 'package:flutter/material.dart';

class RegisterReplacePage extends StatefulWidget {
  @override
  _ReplacementCyclePageState createState() => _ReplacementCyclePageState();
}

class _ReplacementCyclePageState extends State<RegisterReplacePage> {
  final List<String> parts = [
    "엔진 오일",
    "미션 오일",
    "브레이크",
    "클러치",
    "파워스티어링",
    "냉각수",
    "연료 필터",
    "히터 필터",
    "에어컨 필터",
    "브레이크 라이닝",
    "브레이크 패드",
    "휠 얼라이먼트",
    "점화 플러그",
    "배터리",
    "걸 벨트",
    "타이밍 벨트",
  ];

  final List<String> options = [
    "1개월 전",
    "2개월 전",
    "3개월 전",
    "4개월 전",
    "5개월 전",
    "6개월 전",
    "7개월 전",
    "10개월 전",
    "11개월 전",
    "12개월 전",
  ];

  Map<String, String?> selectedValues = {};

  @override
  void initState() {
    super.initState();
    for (var part in parts) {
      selectedValues[part] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            '<',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'body',
            ),
          ),
          onPressed: () => Navigator.pop(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        title: Text(
          '부품 교체 기간 설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'head',
            fontSize: 25,
            color: Color(0xFF696C6C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 7.0,
                color: Color(0xFF8CD8B4),
              ),
              SizedBox(height: 16),

              ...parts.map((part) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.grey[300], // 드롭다운 메뉴 배경색
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedValues[part],
                        items: options
                            .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValues[part] = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300], // 배경색 회색
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // 테두리 제거
                            borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: Text("선택해주세요"),
                        style: TextStyle(color: Colors.black87), // 텍스트 색상
                      ),
                    ),
                  ],
                ),
              )).toList(),

              // "앞으로의 부품 교체 주기를 예측하기 위한 기록입니다." 문구 중앙 배치
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "*앞으로의 부품 교체 주기를 예측하기 위한 기록입니다.*",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFEA7B7B), // 문구 색상 지정
                    ),
                  ),
                ),
              ),

              // 완료 버튼
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // 목록과 버튼 간격
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // 완료 버튼 눌렀을 때 동작
                      print("완료 버튼 눌림");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8CD8B4), // 버튼 배경색
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 버튼 크기
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 버튼
                      ),
                    ),
                    child: Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'car_provider.dart';
import 'http_service.dart';
import 'myPage.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

class ModifyCarInfoPage extends StatefulWidget {
  const ModifyCarInfoPage({super.key});

  @override
  _ModifyCarInfoPageState createState() => _ModifyCarInfoPageState();
}

class _ModifyCarInfoPageState extends State<ModifyCarInfoPage> {
  // 각 DropdownButton의 선택된 값을 저장할 변수들
  String? selectedManufacturer;
  String? selectedCarType;
  String? selectedFuelType;
  String? selectedCarColor;
  String? selectedCarYear;
  String? selectedCarStatus;
  String? selectedEngineCapacity;

  List<String> carTypeOptions = []; // 차급 옵션 리스트
  List<String> exteriorOptions = []; // 외형 옵션 리스트

  String userId = "";
  String name = ""; // 이름 변수
  String carId = "";

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    final car = Provider.of<CarProvider>(context, listen: false);
    setState(() {
      userId = user.userId ?? "";
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      carId = car.carId;
    });
  }

  String? parseManufacturer(String? manufacturer) {
    String? carManufacturer;
    if (manufacturer == "현대") {
      carManufacturer = "Hyundai";
    }
    else if (manufacturer == "기아") {
      carManufacturer = "Kia";
    }
    else if (manufacturer == "쉐보레") {
      carManufacturer = "Chevrolet";
    }
    else if (manufacturer == "르노") {
      carManufacturer = "Renault";
    }
    else if (manufacturer == "대우") {
      carManufacturer = "Daewoo";
    }
    else if (manufacturer == "제네시스") {
      carManufacturer = "Genesis";
    }
    else if (manufacturer == "벤츠") {
      carManufacturer = "Benz";
    }
    else if (manufacturer == "아우디") {
      carManufacturer = "Audi";
    }
    else {
      carManufacturer = manufacturer;
    }

    return carManufacturer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            '<', // 뒤로 가기 버튼 모양
            style: TextStyle(
              fontSize: 24,
              color: Colors.black, // 아이콘 색상
              fontFamily: 'body',
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 동작
          },
          splashColor: Colors.transparent, // 클릭 시 물결 효과 제거
          highlightColor: Colors.transparent, // 클릭 시 강조 효과 제거
        ),
        title: Text(
          '개인페이지', // 타이틀 수정
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'head', // 폰트 스타일 변경
          ),
        ),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제조사 선택
            Text(
              "제조사",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String?>(
                value: selectedManufacturer,
                hint: Text("선택 1"),
                isExpanded: true,
                underline: SizedBox(),
                items:  [null, '현대', '기아', 'KGM', '쉐보레', '르노코리아', '대우','제네시스', 'BMW', '벤츠', '아우디' ]
                    .map<DropdownMenuItem<String?>>((String? i) {
                  return DropdownMenuItem<String?>(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(i ?? '미정'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedManufacturer = value;
                    selectedCarType = null; // 차급 선택 초기화
                    exteriorOptions = []; // 외형 옵션 초기화
                    // 제조사에 따라 차급 옵션 설정
                    if (value == '현대') {
                      carTypeOptions = [
                        '세단/쿠페/해치백',
                        'CUV/SUV',
                        'MPV',
                        'N/N Line',
                        '버스',
                        '트럭'
                      ];
                    } else if (value == '기아') {
                      carTypeOptions = ['세단/해치백/왜건','SUV','MPV','전기차'];
                    } else if (value == 'KGM') {
                      carTypeOptions = ['세단','SUV', '픽업 트럭', 'MPV','버스'];
                    } else if (value == '쉐보레ㅅ') {
                      carTypeOptions = ['쉐보레','캐딜락','사브','뷰익'];
                    } else if (value == '르노') {
                      carTypeOptions = ['소형', '세단','SUV,RV','상용차','전기차'];
                    } else if (value == '대우') {
                      carTypeOptions = ['트럭', '버스'];
                    } else if (value == '제네시스') {
                      carTypeOptions = ['세단','SUV'];
                    } else if (value == 'BMW') {
                      carTypeOptions = ['세단', 'SUV', 'LCV', '로드스터', '스포츠카', '하이퍼카', '트럭', '버스'];
                    } else if (value == '벤츠') {
                      carTypeOptions = ['세단', 'SUV', 'LCV', '로드스터', '스포츠카', '하이퍼카', '트럭', '버스'];
                    } else if (value == '아우디') {
                      carTypeOptions = ['세단', '준대형', '소형', '준중형', 'SUV', '고성능모델'];
                    }else {
                      carTypeOptions = [];
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            // 차급 선택
            Text(
              "차급",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String?>(
                value: carTypeOptions.contains(selectedCarType) ? selectedCarType : null,
                hint: Text("선택 2"),
                isExpanded: true,
                underline: SizedBox(),
                items: carTypeOptions.toSet().toList().map<DropdownMenuItem<String?>>((String i) {
                  return DropdownMenuItem<String?>(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(i),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCarType = value;
                    exteriorOptions = []; // 외형 옵션 초기화
                    if(selectedManufacturer == '현대') {
                      if (selectedCarType == '세단/쿠페/해치백') {
                        exteriorOptions = [
                          'i10','아우라','HB20','엑센트','i20','아반떼','i30','라페스타','쏘나타','그랜저'
                        ];
                      } else if (selectedCarType == 'CUV/SUV') {
                        exteriorOptions = ['캐스퍼','엑스터','크레타/ix25','코나','베뉴','베이온','알카자르', '무파사','투싼','싼타페','팰리세이드'
                        ];
                      } else if (selectedCarType == 'MPV') {
                        exteriorOptions = ['스타케이저', '쿠스토/커스틴', '스타리아'];
                      } else if (selectedCarType == 'N/N Line') {
                        exteriorOptions = ['i20 N','아반떼 N','i30 N', '아이오닉 6 N', '코나 N','아이오닉 5 N', 'i10 N Line','i20 N Line','아반떼 N Line', '쏘나타 N Line','코나 N Line','투싼 N Line'];
                      } else if (selectedCarType == '버스') {
                        exteriorOptions =
                        ['쏠라티', '카운티', '일렉시티 타운', '일렉시티', '유니버스', '일렉시티 이층버스'];
                      } else if (selectedCarType == '트럭' ) {
                        exteriorOptions = [ '포터', '쏠라티', '싼타크루즈'];
                      }
                    } else if (selectedManufacturer == '기아') {
                      if (selectedCarType == '세단/해치백/왜건') {
                        exteriorOptions = [ 'K3', 'K5', '소나타', '아반떼', 'K7', 'K9'];
                      } else if (selectedCarType == 'SUV') {
                        exteriorOptions = [ '스포티지', '쏘렌토', '텔루라이드'];
                      }else if (selectedCarType == 'MPV') {
                        exteriorOptions = [ '카니발'];
                      }else if (selectedCarType == '전기차') {
                        exteriorOptions = ['EV6', '니로 EV'];
                      } else { exteriorOptions = [];}
                    } else if (selectedManufacturer == 'KGM') {
                      if (selectedCarType == '세단') {
                        exteriorOptions = [ '체어맨', '체어맨 W'];
                      } else if (selectedCarType == 'SUV') {
                        exteriorOptions = [ '코란도', '코란도 EV', '렉스턴', '액티언', '티볼리', '티볼리 에어', '토레스', '토레스 EVX', '코란도 훼미리', '무쏘', '카이런'];
                      }else if (selectedCarType == '픽업 트럭') {
                        exteriorOptions = [ '렉스턴 스포츠', '렉스턴 스포츠 칸', 'HDH 픽업트럭', '코란도 픽업', '무쏘 스포츠', '액티언 스포츠', '코란도 스포츠'];
                      }else if (selectedCarType == 'MPV') {
                        exteriorOptions = ['이스타나', '로디우스', '코란도 투리스모'];
                      }else if (selectedCarType == '버스') {
                        exteriorOptions = ['DA트럭', '동아 초대형 덤프트럭', '동아 HA/HR버스', '동아 MCI 버스', '에어로버스', 'SY트럭', '트랜스타', '메르세데스-벤츠 21.5톤 초대형 덤프트럭'];
                      } else { exteriorOptions = [];}
                    } else if (selectedManufacturer == '쉐보레') {
                      if (selectedCarType == '쉐보레') {
                        exteriorOptions = [ '스파크', '볼트 EV', '아베오', '크루즈', '말리부', '임팔라', '카마로', '콜벳', '트랙스 1세대', '볼트 EUV', '이쿼녹스', '캡티바', '올란도'];
                      } else if (selectedCarType == '캐딜락') {
                        exteriorOptions = [ 'BLS', 'ATS', 'ATS-V', 'CT4', 'CTS', 'CTS-V', 'STS', 'DTS', 'CT6', 'SRX', 'XT5'];
                      }else if (selectedCarType == '사브') {
                        exteriorOptions = [ '900', '9000', '9-5', '9-3'];
                      }else if (selectedCarType == '뷰익') {
                        exteriorOptions = ['파크 애비뉴'];
                      } else { exteriorOptions = [];}
                    } else if (selectedManufacturer == '르노코리아') {
                      if (selectedCarType == '소형') {
                        exteriorOptions = [ '클리오', '캡처', '조에'];
                      } else if (selectedCarType == '세단') {
                        exteriorOptions = [ 'SM6'];
                      }else if (selectedCarType == 'SUV,RV') {
                        exteriorOptions = ['아르카나', 'QM6', '그랑 콜레오스'];
                      }else if (selectedCarType == '상용차') {
                        exteriorOptions = ['마스터', 'QM6 퀘스트'];
                      }else if (selectedCarType == '전기차') {
                        exteriorOptions = ['트위지'];
                      } else { exteriorOptions = [];}
                    }else if (selectedManufacturer == '대우') {
                      if (selectedCarType == '트럭') {
                        exteriorOptions = ['맥쎈', '구쎈', '더쎈', '기쎈','프리마', '차세대트럭'];
                      }else if (selectedCarType == '버스') {
                        exteriorOptions = ['노부스'];
                      } else { exteriorOptions = [];}
                    }else if (selectedManufacturer == '제네시스') {
                      if (selectedCarType == '세단') {
                        exteriorOptions = ['G70', 'G80', 'G90'];
                      }else if (selectedCarType == 'SUV') {
                        exteriorOptions = ['GV60', 'GV70', 'GV80', 'GV90'];
                      } else { exteriorOptions = [];}
                    } else if (selectedManufacturer == 'BMW') {
                      if (selectedCarType == '세단') {
                        exteriorOptions = ['A클래스', 'CLA', 'C클래스', 'E클래스', 'S클래스', 'EQS', 'AMG GT 4-Door 쿠페'];
                      } else if (selectedCarType == 'SUV') {
                        exteriorOptions = ['GLA', 'GLB', 'EQA', 'GLC', 'GLE', 'GLS', 'G클래스'];
                      } else if (selectedCarType == 'LCV') {
                        exteriorOptions = ['B클래스', '시탄', 'V클래스', 'EQV', '스프린터'];
                      } else if (selectedCarType == '로드스터') {
                        exteriorOptions = ['SL', 'SLS AMG', 'AMG GT'];
                      } else if (selectedCarType == '스포츠카') {
                        exteriorOptions = ['AMG GT', 'SLR 맥라렌'];
                      } else if (selectedCarType == '하이퍼카') {
                        exteriorOptions = ['AMG 원'];
                      } else if (selectedCarType == '트럭') {
                        exteriorOptions = ['악트로스', '아록스', '아테고', '제트로스'];
                      } else if (selectedCarType == '버스') {
                        exteriorOptions = ['투리스모', '시타로'];
                      }
                    } else if (selectedManufacturer == '벤츠') {
                      if (selectedCarType == '세단') {
                        exteriorOptions = ['A클래스', 'CLA', 'C클래스', 'E클래스', 'S클래스', 'EQS', 'AMG GT 4-Door 쿠페'];
                      } else if (selectedCarType == 'SUV') {
                        exteriorOptions = ['GLA', 'GLB', 'EQA', 'GLC', 'GLE', 'GLS', 'G클래스'];
                      } else if (selectedCarType == 'LCV') {
                        exteriorOptions = ['B클래스', '시탄', 'V클래스', 'EQV', '스프린터'];
                      } else if (selectedCarType == '로드스터') {
                        exteriorOptions = ['SL', 'SLS AMG', 'AMG GT'];
                      } else if (selectedCarType == '스포츠카') {
                        exteriorOptions = ['AMG GT', 'SLR 맥라렌'];
                      } else if (selectedCarType == '하이퍼카') {
                        exteriorOptions = ['AMG 원'];
                      } else if (selectedCarType == '트럭') {
                        exteriorOptions = ['악트로스', '아록스', '아테고', '제트로스'];
                      } else if (selectedCarType == '버스') {
                        exteriorOptions = ['투리스모', '시타로'];
                      }
                    }else if (selectedManufacturer == '아우디') {
                      if (selectedCarType == '세단') {
                        exteriorOptions = ['A3', 'A4', 'A6', 'A7', 'A8', 'S3', 'S4', 'S6', 'S7', 'S8', 'RS3', 'RS4', 'RS5', 'RS6', 'RS7'];
                      } else if (selectedCarType == '준대형') {
                        exteriorOptions = ['Q6', 'Q8', 'RSQ8'];
                      } else if (selectedCarType == '소형') {
                        exteriorOptions = ['A1', 'A2', 'Q2', 'SQ2'];
                      } else if (selectedCarType == '준중형') {
                        exteriorOptions = ['A3', 'Q3', 'Q4', 'SQ5', 'RSQ3'];
                      } else if (selectedCarType == 'SUV') {
                        exteriorOptions = ['Q5', 'Q7', 'SQ7', 'SQ8', 'RS6'];
                      } else if (selectedCarType == '고성능모델') {
                        exteriorOptions = ['S1', 'S5', 'SQ7', 'RSQ8', 'R8'];
                      }else {
                        exteriorOptions = [];
                      }
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            // 외형 선택
            Text(
              "외형",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String?>(
                value: exteriorOptions.contains(selectedFuelType) ? selectedFuelType : null,
                hint: Text("선택 3"),
                isExpanded: true,
                underline: SizedBox(),
                items: exteriorOptions.toSet().toList().map<DropdownMenuItem<String?>>((String i) {
                  return DropdownMenuItem<String?>(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(i),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFuelType = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            // 연료 선택
            Text(
              "연료",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String?>(
                value: selectedCarColor,
                hint: Text("선택 4"),
                isExpanded: true,
                underline: SizedBox(),
                items: [null, '1.0L', '1.2L', '1.4L', '1.6L', '1.8L', '2.0L', '2.2L', '2.5L', '2.8L', '3.0L', '3.5L', '4.0L', '5.0L', '6.0L 이상']
                    .map<DropdownMenuItem<String?>>((String? i) {
                  return DropdownMenuItem<String?>(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(i ?? '미정'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCarColor = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            Text(
              "배기량",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String?>(
                value: selectedEngineCapacity,
                hint: Text("선택 4"),
                isExpanded: true,
                underline: SizedBox(),
                items: [null, '1000cc', '1500cc', '2000cc', '2500cc', '3000cc']
                    .map<DropdownMenuItem<String?>>((String? i) {
                  return DropdownMenuItem<String?>(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(i ?? '미정'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEngineCapacity = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            Text(
              "연식",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2, // 입력 박스 너비를 절반으로 줄임
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number, // 숫자 입력만 가능
                      maxLines: 1, // 줄바꿈 방지
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                        LengthLimitingTextInputFormatter(4), // 4글자 제한
                      ],
                      decoration: InputDecoration(
                        hintText: '연식을 입력하세요',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        counterText: "", // 입력 길이 표시 없애기
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCarYear = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '년',
                      style: TextStyle(fontWeight: FontWeight.bold), // '년' 글자에 굵은 글씨 스타일 적용
                    ),
                  ),
                ],
              ),
            ),
            if (selectedCarYear != null && selectedCarYear!.length < 4 && selectedCarYear!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '연식은 4자리로 입력해주세요.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: 16),

            Spacer(),

            // 등록 버튼
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if ([selectedManufacturer, selectedCarType, selectedFuelType, selectedCarYear].contains(null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('모든 필드를 입력해주세요!')),
                    );
                    return;
                  }

                  final parsedManufacturer = parseManufacturer(selectedManufacturer);

                  final requestData = {
                    "carId": carId,
                    "manufacturer": parsedManufacturer,
                    "size": selectedCarType,
                    "model": selectedFuelType,
                    "fuel": selectedCarColor,
                    "displacement": selectedEngineCapacity,
                    "year": selectedCarYear
                  };

                  try {
                    final response = await HttpService().postRequest("car/update", requestData);
                    var jsonData = json.decode(utf8.decode(response.bodyBytes));

                    if (response.statusCode == 200 && jsonData['success'] == 'true') {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${jsonData['message']}')),
                      );

                      final carViewResponse = await HttpService().postRequest('car/view/user',
                        {"userId": userId},
                      );

                      if (carViewResponse.statusCode == 200) {
                        final carViewData = json.decode(carViewResponse.body);

                        if (carViewData['success'] == 'true' && carViewData['data']!= null) {
                          final carData = carViewData['data'][0];
                          context.read<CarProvider>().setCarInfo(carData);
                        } else {
                          context.read<CarProvider>().setCarInfo({
                            "carId": "",
                            "manufacturer": "",
                            "size": "",
                            "model": "",
                            "fuel": "",
                            "displacement": "",
                            "year": 0,
                          });
                        }
                      }

                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('차량 수정 실패. 다시 시도해주세요.')),
                      );
                    }
                  } catch (e) {
                    // 예외 발생 시 로그에 출력
                    print("Error: $e");

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('서버 오류: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8CD8B4), // 버튼 배경색
                  minimumSize: Size(200, 50), // 버튼 크기 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
                  ),
                ),
                child: Text(
                  "수정",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // 텍스트 색상
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

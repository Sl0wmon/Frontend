import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
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
          '개인페이지',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'head'),
        ),
      ),
      body: Container(
        color: Colors.grey[200], // 전체 배경 회색 설정
        child: Column(
          children: [
            // 경계선
            Container(
              height: 7.0,
              color: Color(0xFF8CD8B4), // 경계선 색상
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 회원 정보 박스
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "회원 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text("수정", style: TextStyle(fontFamily: 'body', color: Colors.white, fontWeight: FontWeight.bold, fontSize:17)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("이름: 임나경", style: TextStyle(fontFamily: 'body')),
                          SizedBox(height: 8),
                          Text("전화번호: 010-5202-0000", style: TextStyle(fontFamily: 'body')),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    // 차량 정보 박스
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "차량 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8CD8B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text("등록", style: TextStyle(fontFamily: 'body', color: Colors.white, fontWeight: FontWeight.bold, fontSize:17)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // 연두색 박스
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF8CD8B4), // 연두색
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "SANTAFE",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'body',
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white, // 연핑크 색상
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          child: Text(
                                            "수정",
                                            style: TextStyle(color: Color(0xFF60BF92), fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFF9A7A7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          child: Text(
                                            "삭제",
                                            style: TextStyle(color: Colors.white, fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // 흰색 박스
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("제조사: 현대", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959) )),
                                      SizedBox(height: 8),
                                      Text("차급: 중형", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959))),
                                      SizedBox(height: 8),
                                      Text("외형: SUV", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959))),
                                      SizedBox(height: 8),
                                      Text("연료: 가솔린", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959))),
                                      SizedBox(height: 8),
                                      Text("배기량: 2400CC", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959))),
                                      SizedBox(height: 8),
                                      Text("연식: 2024년", style: TextStyle(fontFamily: 'body', fontWeight: FontWeight.bold, color: Color(0xFF595959))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // 새로 추가된 박스
                    Container(
                      padding: EdgeInsets.all(16.0),
                      width: double.infinity, // 너비를 전체로 설정
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "제품 정보",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'head', // 'head' 폰트 적용
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: Text(
                                      "삭제",
                                      style: TextStyle(color: Color(0xFF60BF92), fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF8CD8B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: Text(
                                      "등록",
                                      style: TextStyle(color: Colors.white, fontFamily: 'body', fontWeight: FontWeight.bold, fontSize:17),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // 연두색 박스
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF8CD8B4), // 연두색
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Text(
                                "1111 - 1111 - 1111 - 1111",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'body', // 'body' 폰트 적용
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'info_box.dart';
import 'stat_box.dart';
import 'graph_card.dart';
import 'pedal_chart.dart';
import 'speed_chart.dart';

class RecordPage extends StatelessWidget {
  Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu, color: Colors.grey),
        title: Text(
          '급발진 상황 기록',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
            height: 2,
            color: colorFromHex('#8CD8B4'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 및 시간
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoBox(icon: Icons.calendar_today, text: '2024.09.04'),
                  InfoBox(icon: Icons.access_time, text: '15:30:22~15:40:56'),
                ],
              ),
            ),
            // 주행 거리
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StatBox(
                label: '주행 거리',
                value: '1.54km',
                color: colorFromHex('#8CD8B4'),
              ),
            ),
            SizedBox(height: 16),
            // 페달 기록 그래프
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GraphCard(
                title: '페달 기록',
                child: PedalChart(),
              ),
            ),
            SizedBox(height: 16),
            // 속도 그래프
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GraphCard(
                title: '속도',
                subtitle: '평균: 165km',
                child: SpeedChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

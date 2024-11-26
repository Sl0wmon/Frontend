import 'package:flutter/material.dart';
import 'package:slomon/http_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'sua_detail_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<dynamic> suaRecords = [];
  String name = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      name = user.name?.isNotEmpty == true ? utf8.decode(user.name!.runes.toList()) : '';
      userId = user.userId ?? "";
    });
    fetchSUARecords();
  }

  Future<void> fetchSUARecords() async {
    final response = await HttpService().postRequest("SUARecord/list", {"userId": userId});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        suaRecords = data['data'];
      });
    } else {
      print('Failed to load SUA records');
    }
  }

  String formatTime(List<dynamic> time) {
    // 초가 없는 경우 처리 (초를 0으로 채움)
    while (time.length < 6) {
      time.add(0);
    }

    return '${time[3].toString().padLeft(2, '0')}:${time[4].toString().padLeft(2, '0')}:${time[5].toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('급발진 기록')),
      body: ListView.builder(
        itemCount: suaRecords.length,
        itemBuilder: (context, index) {
          final record = suaRecords[index];
          final suaid = record['suaid'];
          final startTime = record['suaonTime'] ?? [0, 0, 0, 0, 0, 0];
          final endTime = record['suaoffTime'] ?? [0, 0, 0, 0, 0, 0];

          return ListTile(
            title: Text(
              '${startTime[0]}.${startTime[1].toString().padLeft(2, '0')}.${startTime[2].toString().padLeft(2, '0')}',
            ),
            subtitle: Text(
              '${formatTime(startTime)} ~ ${formatTime(endTime)}',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SUADetailPage(suaid: suaid.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

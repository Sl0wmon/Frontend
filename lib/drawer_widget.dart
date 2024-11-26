import 'package:flutter/material.dart';
import 'obd_guide_page.dart';
import 'myPage.dart';
import 'dashboard_page.dart';
import 'record_page.dart';
import 'replacementCycle.dart';
import 'notification_page.dart';

class DrawerWidget extends StatelessWidget {
  final String name;
  final double Function(BuildContext, double) getAdaptiveFontSize;

  const DrawerWidget({
    Key? key,
    required this.name,
    required this.getAdaptiveFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorFromHex('#8CD8B4'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLOMON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getAdaptiveFontSize(context, 34),
                    fontFamily: 'head',
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$name 님',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getAdaptiveFontSize(context, 22),
                          fontFamily: 'body',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, "대시보드", Icons.dashboard, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }),
          _buildDrawerItem(context, "급발진 상황 기록", Icons.history, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordPage()),
            );
          }),
          _buildDrawerItem(context, "차량 부품 교체 주기", Icons.car_repair, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReplacementCyclePage()),
            );
          }),
          _buildDrawerItem(context, "OBD 진단 가이드", Icons.info, () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObdGuidePage()),
            );
          }),
          _buildDrawerItem(context, "알림", Icons.notifications, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
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
        style: const TextStyle(fontFamily: 'body'),
      ),
      onTap: onTap,
    );
  }

  Color colorFromHex(String hex) {
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }
}

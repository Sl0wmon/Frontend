import 'package:flutter/material.dart';
import 'record_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // Data variables for each page
  List<String> speeds = ['50', '60'];
  List<String> engineRpms = ['701', '720'];
  List<String> coolantTemps = ['110', '95'];
  List<String> intakeTemps = ['30', '32'];
  List<String> engineLoads = ['29.4', '30.0'];
  List<String> intakePressures = ['100', '102'];
  List<String> drivingDistances = ['75', '80'];
  List<String> journeyTimes = ['18:16', '20:00'];
  List<String> averageSpeeds = ['50 km/h', '60 km/h'];
  List<String> idleTimes = ['15:16', '15:30'];
  List<String> fuelEfficiencies = ['0 km/L', '10 km/L'];
  List<String> fuelRates = ['0 L/h', '1 L/h'];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // Side menu
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildDashboardPage(0),
                _buildDashboardPage(1),
              ],
            ),
          ),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0),
              SizedBox(width: 8),
              _buildPageIndicator(1),
            ],
          ),
          // Arrow buttons for page navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  if (_currentPage < 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('사이드 메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          ListTile(
            title: Text('대시보드'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('급발진 상황 기록'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordPage()), // Navigate to RecordPage
              );
            },
          ),
          ListTile(
            title: Text('차량 부품 교체 주기'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('OBD 진단 가이드'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
          ListTile(
            title: Text('알림'),
            onTap: () {
              Navigator.pop(context);
              // 다른 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage(int pageIndex) {
    // Page content divided based on index
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // First set of cards (2x3 layout)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('속도', '${speeds[pageIndex]} km/h'),
              _buildCard('엔진 RPM', '${engineRpms[pageIndex]} rpm'),
              _buildCard(
                '냉각수 온도',
                '${coolantTemps[pageIndex]} °C',
                isHighlighted: coolantTemps[pageIndex] == '110',
              ),
              _buildCard('흡입 온도', '${intakeTemps[pageIndex]} °C'),
              _buildCard('엔진 부하', '${engineLoads[pageIndex]} %'),
              _buildCard('흡입 압력', '${intakePressures[pageIndex]} kPa'),
            ],
          ),
          SizedBox(height: 16),
          // Second set of cards (3x2 layout)
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard('주행 거리', '${drivingDistances[pageIndex]} km'),
              _buildCard('주행 시간', journeyTimes[pageIndex]),
              _buildCard('평균 속도', averageSpeeds[pageIndex]),
              _buildCard('유휴 시간', idleTimes[pageIndex]),
              _buildCard('순간 연료 효율성', fuelEfficiencies[pageIndex]),
              _buildCard('순간 소비', fuelRates[pageIndex]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, {bool isHighlighted = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.red[100] : Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.black54)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, color: isHighlighted ? Colors.red : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.teal : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

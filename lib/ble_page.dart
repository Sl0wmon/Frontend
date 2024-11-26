import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:slomon/SUAProvider.dart';
import 'package:slomon/dashboard_page.dart';
import 'package:slomon/user_provider.dart';
import 'DataProvider.dart';
import 'drawer_widget.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  String name = ""; // 이름 변수
  String userId = "";


  List<BluetoothDevice> devices = [];
  bool isLoading = true;
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false); // listen: false로 값을 가져옴

    setState(() {
      userId = user.userId ?? "";
      name = user.name != null
          ? utf8.decode(user.name!.codeUnits)
          : ""; // UTF-8 디코딩 적용
    });

    discoverDevices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).updateData({
        "Speed": "0.0",
        "RPM": "0.0",
        "CoolantTemp": "0.0",
        "IntakeTemp": "0.0",
        "EngineLoad": "0.0",
        "IntakePressure": "0.0",
        "PressureValues": {
          "acc": "0",
          "brk": "0",
        },
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Suaprovider>(context, listen: false).updateData({
        "timeStamp":"2024-11-26T09:03:24",
        "SUA":"false",
        "Speed": "0.0",
        "RPM": "0.0",
        "CoolantTemp": "0.0",
        "IntakeTemp": "0.0",
        "EngineLoad": "0.0",
        "IntakePressure": "0.0",
        "PressureValues": {
          "acc": "0",
          "brk": "0",
        },
      });
    });
  }

  void connectToDeviceWithRetry(BluetoothDevice device) async {
    bool isConnected = false;

    while (!isConnected) {
      try {
        print("Attempting to connect to ${device.name}...");
        setState(() {
          isLoading = true;
        });

        final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
        setState(() {
          this.connection = connection;
          isLoading = false;
        });

        isConnected = true; // 연결 성공 시 플래그 변경
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.name ?? "Unknown Device"}'),
          ),
        );

        // 데이터 수신 시작
        startDataFetching();

        // DashboardPage로 이동, BluetoothPage를 유지한 상태로 데이터 전달
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } catch (e) {
        print('Failed to connect to ${device.name}: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retrying connection to ${device.name ?? "Unknown Device"}...'),
          ),
        );

        // 연결 실패 시 2초 대기 후 재시도
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }



  void discoverDevices() async {
    try {
      final availableDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devices = availableDevices;
        isLoading = false;
      });

      // 'raspberrypi' 장치 찾기
      final BluetoothDevice? raspberryDevice = devices.cast<BluetoothDevice?>().firstWhere(
            (device) => device?.name?.toLowerCase() == 'raspberrypi',
        orElse: () => null,
      );

      if (raspberryDevice != null) {
        connectToDeviceWithRetry(raspberryDevice);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No device named "raspberrypi" found.'),
          ),
        );
      }
    } catch (e) {
      print("Error discovering devices: $e");
      setState(() {
        devices = [];
        isLoading = false;
      });
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      setState(() {
        isLoading = true;
      });

      final BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        this.connection = connection;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name ?? "Unknown Device"}'),
        ),
      );

      startDataFetching();
    } catch (e) {
      print('Error connecting to device: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.name ?? "Unknown Device"}'),
        ),
      );
    }
  }

  void startDataFetching() {
    if (connection == null) {
      print("Bluetooth connection is not established.");
      return;
    }

    // 마지막 데이터 수신 시간 추적
    DateTime lastReceivedTime = DateTime.now();

    connection!.input?.listen((Uint8List data) {
      // 원본 Bluetooth 데이터
      String bluetoothData = String.fromCharCodes(data).trim();

      // 현재 시간과 마지막 수신 시간 차이를 계산
      DateTime now = DateTime.now();
      Duration interval = now.difference(lastReceivedTime);
      lastReceivedTime = now;

      // 콘솔에 출력
      print("Received Bluetooth Data: $bluetoothData at ${now.toIso8601String()}");
      print("Interval since last data: ${interval.inMilliseconds} ms");

      // 데이터 파싱
      Map<String, dynamic> parsedData = parseBluetoothData(bluetoothData);

      // 유효한 데이터만 업데이트
      Provider.of<DataProvider>(context, listen: false).updateData(parsedData);
      Provider.of<Suaprovider>(context, listen: false).updateData(parsedData);

      // 디버깅 로그
      print("Parsed Data: $parsedData");
      print("SUAProvider Data: ${Provider.of<Suaprovider>(context, listen: false).data}");
    }, onError: (error) {
      print("Error while receiving data: $error");
      handleConnectionLost();
    }).onDone(() {
      print("Bluetooth connection closed.");
      handleConnectionLost();
    });
  }

  void handleConnectionLost() {
    print("Connection lost. Attempting to reconnect...");

    // 연결이 끊겼을 때 자동으로 재연결 시도
    if (connection != null) {
      connection?.dispose();
      connection = null;
    }

    // 재연결 시도
    final BluetoothDevice? raspberryDevice = devices.cast<BluetoothDevice?>().firstWhere(
          (device) => device?.name?.toLowerCase() == 'raspberrypi',
      orElse: () => null,
    );

    if (raspberryDevice != null) {
      connectToDeviceWithRetry(raspberryDevice);
    } else {
      print("Device 'raspberrypi' not found. Retrying in 5 seconds...");
      Future.delayed(Duration(seconds: 5), () {
        discoverDevices();
      });
    }
  }




  void disconnect() {
    connection?.dispose();
    setState(() {
      connection = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bluetooth disconnected'),
      ),
    );
  }

  Map<String, dynamic> parseBluetoothData(String rawData) {
    Map<String, dynamic> parsedData = {
      "timeStamp": "",
      "SUA": "false",
      "Speed": "0.0",
      "RPM": "0.0",
      "CoolantTemp": "0.0",
      "IntakeTemp": "0.0",
      "EngineLoad": "0.0",
      "IntakePressure": "0.0",
      "PressureValues": {
        "acc": "0",
        "brk": "0",
      },
    };

    // 쉼표로 데이터 분리
    List<String> pairs = rawData.split(", ");
    for (int i = 0; i < pairs.length; i++) {
      String pair = pairs[i];

      // 첫 번째 항목이 타임스탬프인지 확인
      if (i == 0 && pair.contains("T")) {
        parsedData["timeStamp"] = pair.trim(); // timeStamp 추출
        continue;
      }

      // 키와 값으로 분리
      List<String> keyValue = pair.split(":");
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        if (key == "sua") {
          parsedData["SUA"] = value;
        } else if (key == "Pressure acc") {
          parsedData["PressureValues"]["acc"] = value;
        } else if (key == "Pressure brk") {
          parsedData["PressureValues"]["brk"] = value;
        } else if (key == "Speed") {
          parsedData["Speed"] = value;
        } else if (key == "RPM") {
          parsedData["RPM"] = value;
        } else if (key == "Coolant Temp") {
          parsedData["CoolantTemp"] = value;
        } else if (key == "Intake Pressure") {
          parsedData["IntakePressure"] = value;
        } else if (key == "Intake Temp") {
          parsedData["IntakeTemp"] = value;
        } else if (key == "Engine Load") {
          parsedData["EngineLoad"] = value;
        }
      }
    }

    return parsedData;
  }



  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  double _getAdaptiveFontSize(BuildContext context, double size) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    const baseAspectRatio = 375.0 / 667.0;
    return size * (aspectRatio / baseAspectRatio) *
        MediaQuery.of(context).textScaleFactor;
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
        title: Text(
          '장치 연결 중...',
          style: TextStyle(
              fontSize: _getAdaptiveFontSize(context, 28),
              fontFamily: 'head',
              color: const Color(0xFF818585)
          ),
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
            height: 2,
            color: const Color(0xFF8CD8B4),
          ),
        ),
      ),
      drawer: DrawerWidget(
        name: name,
        getAdaptiveFontSize: _getAdaptiveFontSize,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : devices.isEmpty
                ? Center(child: Text("No devices found"))
                : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name ?? "Unknown Device"),
                  subtitle: Text(device.address),
                  onTap: () {
                    connectToDevice(device);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
              child: Text("Go to Another Page"),
            ),
          ),
        ],
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another Page'),
      ),
      body: Center(
        child: Text('This is another page!'),
      ),
    );
  }
}
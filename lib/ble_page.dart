import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> devices = [];
  bool isLoading = true;
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    discoverDevices();
  }

  void discoverDevices() async {
    try {
      final availableDevices =
      await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devices = availableDevices;
        isLoading = false;
      });
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

      final BluetoothConnection connection =
      await BluetoothConnection.toAddress(device.address);
      setState(() {
        this.connection = connection;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name ?? "Unknown Device"}'),
        ),
      );

      print('Connected to the device');
      connection.input?.listen((data) {
        print('Data incoming: ${String.fromCharCodes(data)}');
      }).onDone(() {
        print('Disconnected by the remote device');
      });
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

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Communication")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중인 경우
          : devices.isEmpty
          ? Center(child: Text("장치를 찾을 수 없습니다.")) // 장치가 없는 경우
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name ?? "Unknown Device"),
            subtitle: Text(device.address),
            onTap: () {
              // 장치 클릭 시 연결 로직 실행
              connectToDevice(device);
            },
          );
        },
      ),
    );
  }
}

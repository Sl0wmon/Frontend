import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:slomon/dashboard_page.dart';
import 'DataProvider.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> devices = [];
  bool isLoading = true;
  BluetoothConnection? connection;
  Map<String, dynamic> lastParsedData = {
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

  @override
  void initState() {
    super.initState();
    discoverDevices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).updateData(lastParsedData);
    });
  }

  void discoverDevices() async {
    try {
      final availableDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
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

    connection!.input?.listen((Uint8List data) {
      String bluetoothData = String.fromCharCodes(data).trim();
      Map<String, dynamic> parsedData = parseBluetoothData(bluetoothData);
      Provider.of<DataProvider>(context, listen: false).updateData(parsedData);
      lastParsedData = parsedData;
      print("Received Bluetooth Data: $bluetoothData");
      print("Parsed Data: $parsedData");
    }, onError: (error) {
      print("Error while receiving data: $error");
      disconnect();
    }).onDone(() {
      print("Bluetooth connection closed.");
      disconnect();
    });
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
    Map<String, dynamic> parsedData = Map.from(lastParsedData);

    List<String> pairs = rawData.split(", ");

    for (String pair in pairs) {
      List<String> keyValue = pair.split(":");
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        if (key == "Pressure acc") {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
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

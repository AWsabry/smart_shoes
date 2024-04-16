import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothDevice? _device;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _weight = 'N/A';
  bool isBluetoothEnabled = false;
  // static String deviceAddress = '00:20:12:00:03:F1';
  // static String deviceName = 'smart shoes';

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    // Dispose the Bluetooth connection when the app is closed
    if (_connection != null && _connection!.isConnected) {
      _connection!.dispose();
    }
    super.dispose();
  }

  void _initBluetooth() async {
    await FlutterBluetoothSerial.instance.requestEnable();

    // Check if Bluetooth is enabled
    bool? enabled = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      isBluetoothEnabled = enabled!;
    });
    if (_connection != null && _connection!.isConnected) {
      _connection!.dispose();
    } else {
      Future.delayed(const Duration(seconds: 5)).then(
        (value) {
          _connectToDevice();
        },
      );
    }
  }

  void _connectToDevice() async {
    _device = const BluetoothDevice(
        name: "smart shoes", address: "00:20:12:00:03:F1");
    if (_device == null) {
      print('Device not found');
      return;
    }
    if (_connection != null && _connection!.isConnected) {
      _connection!.dispose();
    }
    print(_connection);
    BluetoothConnection.toAddress("00:20:12:00:03:F1").then((connection) {
      print("HEY");
      _connection = connection;
      setState(() {
        _isConnected = true;
        _listenData();
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred: $error');
    });
  }

  void _listenData() {
    _connection!.input!.listen((data) {
      String received = String.fromCharCodes(data);
      print(received);
      List<String> parts = received.split(':');
      setState(() {
        _weight = parts[1];
      });
    }).onDone(() {
      setState(() {
        _isConnected = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoes Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!_isConnected) const Text('Connecting to device...'),
            if (_isConnected)
              Column(
                children: [
                  Text('Connected to: ${_device!.name}'),
                  const SizedBox(height: 20),
                  Text('Weight: $_weight'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

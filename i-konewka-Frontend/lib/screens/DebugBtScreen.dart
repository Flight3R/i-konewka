import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:i_konewka_app/main.dart';
import 'package:i_konewka_app/screens/elements/AlertStyle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<int> sendWater(String water, BluetoothClassic BT_DEV) async {
  try {
    await BT_DEV.connect(
        "B4:E6:2D:86:FC:4F", "00001101-0000-1000-8000-00805f9b34fb");
  } on PlatformException {
    print('essa');
    return 1;
  }
  try {
    await BT_DEV.write('water $water');
  } on PlatformException {
    print('bracie');
    return 2;
  }
  return 0;
}

class DebugBtScreen extends StatefulWidget {
  const DebugBtScreen({super.key});
  static const routeName = '/DebugBtScreen';

  @override
  State<DebugBtScreen> createState() => _DebugBtScreenState();
}

class _DebugBtScreenState extends State<DebugBtScreen> {
  final String deviceAddress = 'B4:E6:2D:86:FC:4F';
  final String defaultUuid = "00001101-0000-1000-8000-00805f9b34fb";
  String _platformVersion = 'Unknown';
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  Uint8List _data = Uint8List(0);
  bool? _bluetoothPermissions;
  final BT_DEV = BluetoothClassic();
  int _DEVICE_STATUS = Device.disconnected;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initPermissionsApi34();
    if (!IS_LISTENED_TO) {
      BT_DEV.onDeviceStatusChanged().listen((event) {
        setState(() {
          _DEVICE_STATUS = event;
        });
      });
      IS_LISTENED_TO = true;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await BT_DEV.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initPermissionsApi34() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise
    ].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetoothAdvertise] == PermissionStatus.granted) {
      setState(() {
        _bluetoothPermissions = true;
      });
    }
  }

  Future<void> _getDevices() async {
    var res = await BT_DEV.getPairedDevices();
    setState(() {
      _devices = res;
    });
  }

  Future<void> _scan() async {
    if (_scanning) {
      await BT_DEV.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      await BT_DEV.startScan();
      BT_DEV.onDeviceDiscovered().listen(
        (event) {
          print('event: $event');
          setState(() {
            _discoveredDevices = [..._discoveredDevices, event];
          });
        },
      );
      setState(() {
        _scanning = true;
      });
    }
  }

  @override
  void dispose() {
    BT_DEV.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug BT screen'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Device status'),
              subtitle: Text("Device status is $_DEVICE_STATUS"),
            ),
            ListTile(
              trailing: ElevatedButton(
                  child: const Text("Check Permissions"),
                  onPressed: () async {
                    await BT_DEV.initPermissions();
                  }),
            ),
            ListTile(
              trailing: ElevatedButton(
                  child: const Text("Get Paired Devices"),
                  onPressed: () async {
                    _getDevices;
                  }),
            ),
            ListTile(
              trailing: ElevatedButton(
                onPressed: _DEVICE_STATUS == Device.connected
                    ? () async {
                        await BT_DEV.disconnect();
                      }
                    : null,
                child: const Text("disconnect"),
              ),
            ),
            ListTile(
              trailing: ElevatedButton(
                onPressed: _DEVICE_STATUS == Device.connected
                    ? () async {
                        BT_DEV.write("connect ");
                      }
                    : null,
                child: const Text("send 'connect '"),
              ),
            ),
            ListTile(
              trailing: ElevatedButton(
                onPressed: _DEVICE_STATUS == Device.connected
                    ? () async {
                        await BT_DEV.write("water 123");
                      }
                    : null,
                child: const Text("send 'water 123'"),
              ),
            ),
            ListTile(
              trailing: ElevatedButton(
                onPressed: _DEVICE_STATUS != Device.connected
                    ? () async {
                        await BT_DEV
                            .connect(deviceAddress, defaultUuid)
                            .then((result) {
                          print(
                              'ikonewka: ${result ? "connected" : "not connected"}');
                          setState(() {
                            _discoveredDevices = [];
                            _devices = [];
                          });
                        });
                      }
                    : null,
                child: const Text("connect ikonewka"),
              ),
            ),
            Divider(),
            ListTile(
              title: const Text('Platform'),
              subtitle: Text('Running on: $_platformVersion\n'),
            ),
            ...[
              for (var device in _devices)
                ListTile(
                    trailing: ElevatedButton(
                        onPressed: () async {
                          var _status =
                              await BT_DEV.connect(device.address, defaultUuid);
                          setState(() {
                            _discoveredDevices = [];
                            _devices = [];
                          });
                          if (!_status) {
                            Alert(
                              type: AlertType.error,
                              style: CustomAlertStyle.alertStyle,
                              context: context,
                              title: "Couldnt connect",
                              desc:
                                  "Please make sure the bt is enabled and redo connect.",
                              buttons: [
                                DialogButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  color: Colors.red,
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20),
                                  ),
                                ),
                              ],
                            ).show();
                          }
                        },
                        child: Text(device.name ?? device.address)))
            ],
            Divider(),
            ListTile(
                trailing: ElevatedButton(
              onPressed:
                  (_bluetoothPermissions ?? false) == true ? _scan : null,
              child: Text(_scanning ? "Stop Scan" : "Start Scan"),
            )),
            ...[
              for (var device in _discoveredDevices)
                // ListTile(trailing: Text(device.name ?? device.address))
                Text(device.name ?? device.address)
            ],
            Divider(),
            ListTile(
                trailing:
                    Text("Received data: ${String.fromCharCodes(_data)}")),
          ],
        ),
      ),
    );
  }
}

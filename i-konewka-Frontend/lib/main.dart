import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:i_konewka_app/App.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  //#############################################
  // _BT_DEV.onDeviceStatusChanged().listen((event) {
  //   DEVICE_STATUS = event;
  // });
  // IS_LISTENED_TO = true;
  // //#############################################
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final storage = new FlutterSecureStorage();
// final _BT_DEV = BluetoothClassic();

bool IS_LISTENED_TO = false;
int DEVICE_STATUS = Device.disconnected;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App();
  }
}

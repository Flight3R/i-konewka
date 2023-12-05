import 'package:flutter_blue/flutter_blue.dart';

class BluetoothUtils {
  static Future<void> pairDevice({required String deviceAddress}) async {

    FlutterBlue flutterBlue = FlutterBlue.instance;
    BluetoothDevice? device;
    var results = await flutterBlue.startScan(
                          scanMode: ScanMode.balanced,
                          withDevices: [Guid(deviceAddress)],
                          timeout: const Duration(seconds: 30)
                         ).catchError((error) {
                          print("Error starting scan for GUID: deviceAddress\n$error");
                        });

    for (ScanResult r in results) {
      if(r.device.id.toString() == deviceAddress) {
        device = r.device;
      }
    }
    assert(device != null, 'Failed to find a device with given GUID: $deviceAddress');
    try {
      // Connect to the Bluetooth device
      await device?.connect();
      print('Successfully paired with device: ${device!.name}');
    } catch (e) {
      print('Error pairing with the device: $e');
    }
  }
}

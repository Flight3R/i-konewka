import 'dart:typed_data';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:i_konewka_app/screens/DebugBtScreen.dart';
import 'package:i_konewka_app/screens/EditPlantScreen.dart';
import 'package:i_konewka_app/screens/elements/AlertStyle.dart';
import 'package:i_konewka_app/screens/elements/CustomErrorPopUp.dart';
import 'package:i_konewka_app/screens/elements/CustomLoadingPopUp.dart';
import 'package:i_konewka_app/screens/elements/PlantImage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../main.dart';

class PlantContainer extends StatefulWidget {
  const PlantContainer(
      {super.key,
      required this.height,
      required this.width,
      required this.fontSize,
      required this.name,
      required this.icon,
      required this.image,
      required this.plantId,
      required this.waterAmount});

  final double height;
  final double width;
  final double fontSize;
  final String? name;
  final Uint8List image;
  final IconData icon;
  final colorWhite = Colors.white;
  final colorGreen = Colors.green;
  final int? plantId;
  final int waterAmount;

  @override
  State<StatefulWidget> createState() => _PlantContainerState();
}

class _PlantContainerState extends State<PlantContainer> {
  bool connectionUp = false;
  final String deviceAddress = 'B4:E6:2D:86:FC:4F';
  final String defaultUuid = "00001101-0000-1000-8000-00805f9b34fb";
  bool _waterInProgress = false;
  bool _connectionInProgress = false;
  final BT_DEV = BluetoothClassic();

  @override
  void initState() {
    super.initState();
    // TODO: uncomment
    // global is not updated
    // if (DEVICE_STATUS != Device.connected) initConnection();
    initConnection();
  }

  Future<void> initConnection() async {
    await BT_DEV.connect(deviceAddress, defaultUuid).then((bool result) {
      setState(() {
        connectionUp = result;
      });
    });
  }

  @override
  void dispose() {
    BT_DEV.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: widget.width,
            height: widget.height,
            color: widget.colorGreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: PlantImage(
                    image: widget.image,
                    radius: 50,
                  ),
                ),
                Flexible(
                    child: Text(
                  widget.name!,
                  style: TextStyle(fontSize: widget.fontSize),
                )),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(widget.icon),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (connectionUp!) {
          Alert(
            type: AlertType.warning,
            style: CustomAlertStyle.alertStyle,
            context: context,
            title: "Do you want to start watering?",
            desc:
                "Watch out! If you will press START, water will begin to flow.",
            buttons: [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.green,
                child: const Text(
                  "CANCEL",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
              ),
              DialogButton(
                onPressed: !_waterInProgress ? _sendWaterProcess : null,
                color: !_waterInProgress ? Colors.green : Colors.grey,
                child: const Text(
                  "START",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
              )
            ],
          ).show();
        } else {
          Alert(
            type: AlertType.error,
            style: CustomAlertStyle.alertStyle,
            context: context,
            title: "Cannot water the plant",
            desc: "Please make sure the device is connected before watering.",
            buttons: [
              DialogButton(
                onPressed:
                    !_connectionInProgress ? _initConnectionProcess : null,
                color: !_connectionInProgress ? Colors.green : Colors.grey,
                child: const Text(
                  "Connect",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
              ),
              DialogButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.red,
                child: const Text(
                  "Cancel",
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
      onLongPress: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditPlantScreen(
                      plantId: widget.plantId,
                      startName: widget.name,
                    )));
      },
    );
  }

  Future<void> _sendWaterProcess() async {
    _waterInProgress = true;
    var popUp = CustomLoadingPopUp(context: context);
    popUp.show();
    var result = await sendWater("${widget.waterAmount}", BT_DEV);
    var errorPopUp;
    switch (result) {
      case 0:
        break;
      case 1:
        errorPopUp = CustomErrorPopUp(context: context, reason: 'connecting');
        break;
      case 2:
        errorPopUp = CustomErrorPopUp(context: context, reason: 'watering');
        break;
      default:
        break;
    }
    popUp.dismiss();

    if (!context.mounted) return;
    Navigator.pop(context);
    if (errorPopUp != null) {
      errorPopUp.show();
    }
    _waterInProgress = false;
  }

  Future<void> _initConnectionProcess() async {
    _connectionInProgress = true;
    await initConnection();
    if (!context.mounted) return;
    Navigator.pop(context);
    _connectionInProgress = false;
  }
}

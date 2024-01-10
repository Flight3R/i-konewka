import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_konewka_app/core/RequestHandler.dart';
import 'package:i_konewka_app/models/plant.dart';
import 'package:i_konewka_app/screens/AddPlantScreen.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:i_konewka_app/screens/elements/PlantContainer.dart';

import '../main.dart';
import 'elements/Bar.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  Future<List<Plant>?>? plants;
  final BT_DEV = BluetoothClassic();
  final String deviceAddress = 'B4:E6:2D:86:FC:4F';
  final String defaultUuid = "00001101-0000-1000-8000-00805f9b34fb";
  int _DEVICE_STATUS = Device.disconnected;

  @override
  void initState() {
    super.initState();
    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding?.addPostFrameCallback((callback) {
      RequestHandler requestHandler = RequestHandler();
      var plantsData = requestHandler.getPlants();
      setState(() {
        plants = plantsData;
      });
    });

    // BT init
    BT_DEV.initPermissions();
    if (!IS_LISTENED_TO) {
      BT_DEV.onDeviceStatusChanged().listen((event) {
        setState(() {
          _DEVICE_STATUS = event;
        });
      });
      IS_LISTENED_TO = true;
    }
  }

  @override
  void dispose() {
    BT_DEV.disconnect();
    super.dispose();
  }

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (0 == _DEVICE_STATUS) {
      color = Colors.red;
    } else if (_DEVICE_STATUS == 1) {
      color = Colors.orange;
    } else {
      color = Colors.greenAccent;
    }

    return Scaffold(
      appBar: const Bar(),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.01,
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01,
                      bottom: MediaQuery.of(context).size.width * 0.01),
                  minimumSize:
                      Size(MediaQuery.of(context).size.width / 1.5, 30),
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: color),
              child: Text(
                "Device status: $_DEVICE_STATUS",
                style: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(color: Colors.white, fontSize: 30)),
              )),
          Divider(),
          SingleChildScrollView(
              child: FutureBuilder<List<Plant>?>(
                  future: plants,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      return ListView.separated(
                          shrinkWrap: true,
                          reverse: false,
                          itemBuilder: (context, index) => PlantContainer(
                                height: 100,
                                width: 100,
                                fontSize: 28,
                                name: snapshot.data?[index].name,
                                icon: Icons.sentiment_very_satisfied,
                                image: snapshot.data![index].getImageWidget(),
                                plantId: snapshot.data![index].fid,
                                waterAmount:
                                    snapshot.data![index].ml_per_watering,
                              ),
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 0));
                    } else {
                      return const Text('');
                    }
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigatorKey.currentState?.pushNamed(AddPlantScreen.routeName);
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

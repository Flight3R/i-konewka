import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_konewka_app/screens/EditPlantScreen.dart';
import 'package:i_konewka_app/screens/elements/CameraPage.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:i_konewka_app/screens/elements/CustomTextFormField.dart';
import 'package:i_konewka_app/screens/elements/CustomToggleButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../core/RequestHandler.dart';
import '../main.dart';
import 'elements/AlertStyle.dart';
import 'elements/Bar.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});
  static const routeName = '/AddPlantScreen';
  @override
  State<StatefulWidget> createState() {
    return _AddPlantScreen();
  }
}

class _AddPlantScreen extends State<AddPlantScreen> {
  final _formAddPlantKey = GlobalKey<FormState>();
  late String _name = '';
  late XFile? _imgFile;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: const Bar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: size.height / 15),
            child: Center(
              child: Form(
                key: _formAddPlantKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: size.width * 0.10,
                          right: size.width * 0.10,
                          bottom: size.width * 0.10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(size.width / 2, 90),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await availableCameras().then(
                              (value) => _navigateAndGetData(context, value));
                        },
                        child: Text(
                          "Take a Picture",
                          style: GoogleFonts.nunitoSans(
                              textStyle: const TextStyle(
                                  color: Colors.green, fontSize: 22)),
                        ),
                      ),
                    ),
                    CustomTextFormField(
                        label: 'Name',
                        hintText: 'Provide name of a plant',
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Name is empty!';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          _name = val;
                        }),
                    CustomButton(
                        onPressed: () async {
                          if (_formAddPlantKey.currentState!.validate()) {
                            RequestHandler requestHandler = RequestHandler();
                            var bytes = File(_imgFile!.path).readAsBytesSync();
                            String? b64image = base64Encode(bytes);
                            int fid =
                                await requestHandler.addPlant(_name, b64image);
                            if (fid == 0) {
// ignore: use_build_context_synchronously
                              Alert(
                                type: AlertType.error,
                                style: CustomAlertStyle.alertStyle,
                                context: context,
                                title: "To nie jest kwiatek",
                                desc: "To nie jest kwiatek, Lucjan",
                              ).show();
                            } else {
                              print('fid: ' + fid.toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPlantScreen(
                                    plantId: fid,
                                    startName: _name,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        height: 50,
                        width: size.width / 2,
                        fontSize: 30,
                        textButton: 'Create'),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> _navigateAndGetData(
      BuildContext context, List<CameraDescription> cameras) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras)),
    );
    if (!mounted) return;
    _imgFile = result;
  }
}

// import 'dart:convert';
// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:i_konewka_app/screens/EditPlantScreen.dart';
// import 'package:i_konewka_app/screens/elements/CameraPage.dart';
// import 'package:i_konewka_app/screens/elements/CustomButton.dart';
// import 'package:i_konewka_app/screens/elements/CustomTextFormField.dart';
// import 'package:i_konewka_app/screens/elements/CustomToggleButton.dart';
//
// import '../core/RequestHandler.dart';
// import '../main.dart';
// import 'elements/Bar.dart';
//
// class AddPlantScreen extends StatefulWidget {
//
//   const AddPlantScreen({super.key});
//
//   static const routeName = '/AddPlantScreen';
//
//   @override
//   State<StatefulWidget> createState() {
//     return _AddPlantScreen();
//   }
// }
//
// class _AddPlantScreen extends State<AddPlantScreen>{
//
//   final _formAddPlantKey = GlobalKey<FormState>();
//   late String _name = '';
//   late XFile? _imgFile;
//   @override
//   Widget build(BuildContext context) {
//
//     Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//         appBar: const Bar(),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.only(top: size.height/15),
//             child: Center(
//               child: Form(
//                 key: _formAddPlantKey,
//                 child: Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left:size.width*0.10,
//                           right:size.width*0.10,
//                           bottom: size.width*0.10
//                       ),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           fixedSize: Size(size.width/2,90),
//                           backgroundColor: Colors.white,
//                         ),
//                         onPressed: () async {
//                           await availableCameras().then((value) => _navigateAndGetData(context,value));
//                         },
//                         child: Text("Take a Picture",
//                           style:GoogleFonts.nunitoSans(
//                               textStyle: const TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 22
//                               )
//                           ),
//                         ),
//                       ),
//                     ),
//                     CustomTextFormField(
//                         label: 'Name',
//                         hintText: 'Provide name of a plant',
//                         keyboardType: TextInputType.text,
//                         validator: (val){
//                           if (val!.isEmpty){
//                             return 'Name is empty!';
//                           }
//                           return null;
//                         },
//                         onChanged: (val){
//                           _name = val;
//                     }),
//                     CustomButton(
//                         onPressed: () async {
//                           if (_formAddPlantKey.currentState!.validate()) {
//                             RequestHandler requestHandler = RequestHandler();
//                             var bytes = File(_imgFile!.path).readAsBytesSync();
//                             String? b64image = base64Encode(bytes);
//                             int fid = await requestHandler.addPlant(_name,b64image);
//                             print('fid: ' + fid.toString());
//                             Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditPlantScreen(plantId: fid, startName: _name,),
//                             ),
//                           );}
//                         },
//                         height: 50,
//                         width: size.width/2,
//                         fontSize: 30,
//                         textButton: 'Create'
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         )
//     );
//   }
//   Future<void> _navigateAndGetData(BuildContext context,List<CameraDescription> cameras) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras)),
//     );
//
//     if (!mounted) return;
//
//     _imgFile = result;
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:i_konewka_app/core/RequestHandler.dart';
import 'package:i_konewka_app/screens/HomeScreen.dart';
import 'package:i_konewka_app/screens/elements/AlertStyle.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:i_konewka_app/screens/elements/CustomTextFormField.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';

import '../main.dart';
import 'elements/Bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/LoginScreen';

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final _formLoginKey = GlobalKey<FormState>();
  late String _email = '';
  late String _password = '';
  bool? _location;

  @override
  void initState() {
    initLocationApi34();
    checkWifiApi34();
    super.initState();
  }

  Future<void> initLocationApi34() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationWhenInUse].request();

    if (statuses[Permission.locationWhenInUse] == PermissionStatus.granted) {
      setState(() {
        _location = true;
      });
    }
  }

  Future<bool> checkWifiApi34() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // The device has internet access.
      print("Internet access available");
      return true;
    } else {
      // The device doesn't have internet access.
      print("No internet access");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: const Bar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: size.height / 4),
            child: Center(
              child: Form(
                key: _formLoginKey,
                child: Column(
                  children: <Widget>[
                    CustomTextFormField(
                        label: 'Email',
                        hintText: 'Provide email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Email is empty!';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          _email = val;
                        }),
                    CustomTextFormField(
                        label: 'Password',
                        hintText: 'Provide password',
                        keyboardType: TextInputType.visiblePassword,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Password is empty!';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          _password = val;
                        }),
                    CustomButton(
                        onPressed: () {
                          if (_formLoginKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        height: 50,
                        width: size.width / 2,
                        fontSize: 30,
                        textButton: 'Login'),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _login() async {
    RequestHandler requestHandler = RequestHandler();
    bool result = (await requestHandler.login(_email, _password));
    if (result == true) {
      navigatorKey.currentState?.pushNamed(HomeScreen.routeName);
    } else if (result == false && await checkWifiApi34() == true) {
      Alert(
        type: AlertType.error,
        style: CustomAlertStyle.alertStyle,
        context: context,
        title: "Couldnt login",
        desc: "wifi enabled",
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
    } else if (result == false && await checkWifiApi34() == false) {
      Alert(
        type: AlertType.error,
        style: CustomAlertStyle.alertStyle,
        context: context,
        title: "Couldnt login",
        desc: "wifi disabled",
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
  }
}

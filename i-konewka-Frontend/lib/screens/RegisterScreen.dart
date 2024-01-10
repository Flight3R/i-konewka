import 'package:flutter/material.dart';
import 'package:i_konewka_app/screens/HomeScreen.dart';
import 'package:i_konewka_app/screens/LoginScreen.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:i_konewka_app/screens/elements/CustomTextFormField.dart';

import '../core/RequestHandler.dart';
import '../main.dart';
import 'elements/Bar.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  static const routeName = '/RegisterScreen';

  @override
  State<StatefulWidget> createState() {
    return _RegisterScreen();
  }
}

class _RegisterScreen extends State<RegisterScreen>{

  final _formRegisterKey = GlobalKey<FormState>();
  late String _nick = '';
  late String _email = '';
  late String _password = '';
  late String _confirmPassword = '';
  late String _wateringHour = '';

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: const Bar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: size.height/20),
            child: Center(
              child: Form(
                key: _formRegisterKey,
                child: Column(
                  children: <Widget>[
                    CustomTextFormField(
                        label: 'Nickname',
                        hintText: 'Provide nickname',
                        keyboardType: TextInputType.text,
                        validator: (val){
                          if (val!.isEmpty){
                            return 'Nickname is empty!';
                          }
                          return null;
                        },
                        onChanged: (val){
                          _nick = val;
                        }),
                    CustomTextFormField(
                        label: 'Email',
                        hintText: 'Provide email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val){
                          if (val!.isEmpty){
                            return 'Email is empty!';
                          }
                          return null;
                        },
                        onChanged: (val){
                          _email = val;
                        }),
                    CustomTextFormField(
                        label: 'Password',
                        hintText: 'Provide password',
                        keyboardType: TextInputType.visiblePassword,
                        validator: (val){
                          if (val!.isEmpty){
                            return 'Password is empty!';
                          }
                          return null;
                        },
                        onChanged: (val){
                          _password = val;
                        }),
                    CustomTextFormField(
                        label: 'Confirm password',
                        hintText: 'Provide password',
                        keyboardType: TextInputType.text,
                        validator: (val){
                          if (val!.isEmpty){
                            return 'Password is empty!';
                          }
                          return null;
                        },
                        onChanged: (val){
                          _confirmPassword = val;
                        }),
                    CustomTextFormField(
                        label: 'Watering Hour',
                        hintText: 'Provide your preferred watering hour',
                        keyboardType: TextInputType.text,
                        validator: (val){
                          return null;
                        },
                        onChanged: (val){
                          _wateringHour = val;
                        }),
                    CustomButton(
                        onPressed: () {
                          if (_formRegisterKey.currentState!.validate()) {
                            _register();
                          }
                        },
                        height: 50,
                        width: size.width/2,
                        fontSize: 30,
                        textButton: 'Register'
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  void _register() async{
    RequestHandler requestHandler = RequestHandler();
    bool result = (await requestHandler.register(_email,_password,_nick,_wateringHour));
    if (result == true){
      navigatorKey.currentState?.pushNamed(LoginScreen.routeName);
    }
  }
}
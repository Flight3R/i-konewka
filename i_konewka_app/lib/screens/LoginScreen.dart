import 'package:flutter/material.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:i_konewka_app/screens/elements/CustomTextFormField.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  static const routeName = '/HomeScreen';

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen>{

  final _formLoginKey = GlobalKey<FormState>();
  late String _email = '';
  late String _password = '';

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: size.height/4),
        child: Center(
          child: Form(
            key: _formLoginKey,
            child: Column(
              children: <Widget>[
                CustomTextFormField(
                  label: 'Email',
                  hintText: 'Provide email address',
                  keyboardType: TextInputType.text,
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
                    keyboardType: TextInputType.text,
                    validator: (val){
                      if (val!.isEmpty){
                        return 'Password is empty!';
                      }
                      return null;
                    },
                    onChanged: (val){
                      _password = val;
                    }),
                CustomButton(
                  onPressed: () {
                    if (_formLoginKey.currentState!.validate()) {
                      {};
                    }
                  },
                  height: 50,
                  width: size.width/2,
                  fontSize: 30,
                  textButton: 'Login'
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}


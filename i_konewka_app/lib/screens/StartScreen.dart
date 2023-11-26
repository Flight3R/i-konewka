import 'package:flutter/material.dart';
import 'package:i_konewka_app/screens/LoginScreen.dart';
import 'package:i_konewka_app/screens/elements/CustomButton.dart';
import 'package:mysql1/mysql1.dart';

import '../main.dart';

class StartScreen extends StatelessWidget {

  const StartScreen({super.key, required this.title});

  final String title;

  static const routeName = '/StartScreen';

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: size.width*0.10,
          children:[
            CustomButton(fontSize: 30,height: 50,width: size.width/1.5,onPressed: (){navigatorKey.currentState?.pushNamed(LoginScreen.routeName);} ,textButton: 'Login'),
            CustomButton(fontSize: 30,height: 50,width: size.width/1.5,onPressed: () async {
              var test;
              var settings = ConnectionSettings(
                  host: 'sql12.freemysqlhosting.net',
                  port: 3306,
                  user: 'sql12664701',
                  password: 'altWuIKVPL',
                  db: 'sql12664701',
              );
              var conn = await MySqlConnection.connect(settings);
              test = await conn.query('SELECT * FROM USERS');
              for (var row in test) {
                print('Name: ${row[0]}, email: ${row[1]}');
              }
            } ,textButton: 'Register',),
          ],
        )
      );
  }
}
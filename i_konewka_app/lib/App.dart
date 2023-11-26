import 'package:flutter/material.dart';
import 'package:i_konewka_app/main.dart';
import 'package:i_konewka_app/screens/LoginScreen.dart';
import 'package:i_konewka_app/screens/StartScreen.dart';
import 'package:i_konewka_app/AppTheme.dart';
import 'package:i_konewka_app/screens/elements/Bar.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final String title = 'I-Konewka';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: AppTheme.theme,
      home: Scaffold(
        appBar: Bar(title: title,),
        body: StartScreen(title: title,),
      ),
      navigatorKey: navigatorKey,
      routes:{
        StartScreen.routeName: (context) =>
             StartScreen(title: title),
        LoginScreen.routeName: (context) =>
            const LoginScreen(),
      }
    );
  }
}


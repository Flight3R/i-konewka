import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _whiteColor = Colors.white;
  static const _lightGreenColor = Colors.lightGreen;
  static const _greenColor = Colors.green;
  static const _blackColor = Colors.black;

  static final ThemeData theme = ThemeData(

    textTheme: GoogleFonts.nunitoSansTextTheme(
      const TextTheme(
          bodySmall: TextStyle(
              color: _whiteColor,
              fontSize: 10,
          ),
          bodyMedium: TextStyle(
              color: _whiteColor,
              fontSize: 14
          ),
          bodyLarge: TextStyle(
              color: _whiteColor,
              fontSize: 24
          ),
          labelLarge: TextStyle(
              color: _blackColor,
          ),
      )
    ),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
          color: _whiteColor,
          fontSize: 24
      ),
      color: _greenColor,
      iconTheme: IconThemeData(color: _whiteColor)
    ),

    scaffoldBackgroundColor: _lightGreenColor,

    colorScheme: const ColorScheme.light(
      primary: _lightGreenColor
    )
  );
}
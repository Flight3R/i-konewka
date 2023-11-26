import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
  {
    required this.height,
    required this.width,
    required this.fontSize,
    super.key,
    required this.onPressed,
    required this.textButton,
  });

  final double height;
  final double width;
  final double fontSize;
  final void Function()? onPressed;
  final String textButton;
  final colorWhite = Colors.white;
  final colorGreen = Colors.green;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(width, height),
          backgroundColor: colorGreen,
        ),
        child: Text(
          textButton,
          style:GoogleFonts.nunitoSans(
            textStyle: TextStyle(
              color: colorWhite,
              fontSize: fontSize
            )
          ),
        )
    );
  }

}
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantImage extends StatelessWidget {
  const PlantImage(
      {
        super.key,
        required this.radius,
        required this.image,
      });

  final double radius;
  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
      image: DecorationImage(
        image: MemoryImage(image),
        fit: BoxFit.fill,),
        shape: BoxShape.circle,
      )
    );
  }

}
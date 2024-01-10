import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

abstract class CustomAlertStyle{
  static AlertStyle alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    descTextAlign: TextAlign.start,
    animationDuration: const Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
      side: const BorderSide(),
    ),
    titleStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 26,
      color: Colors.green,
    ),
    alertAlignment: Alignment.center,
  );
}
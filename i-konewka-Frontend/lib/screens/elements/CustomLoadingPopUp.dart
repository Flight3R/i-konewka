import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CustomLoadingPopUp extends Alert {
  CustomLoadingPopUp({required super.context});

  @override
  // TODO: implement buttons
  List<DialogButton>? get buttons => [];

  @override
  // TODO: implement title
  String? get title => "Wait till the end of watering.";

  @override
  // TODO: implement style
  AlertStyle get style => const AlertStyle(
    titleStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 26,
      color: Colors.green,
    ),
  );

  @override
  // TODO: implement content
  Widget get content => Column(
    children: [
      SizedBox(height: 30,),
      LoadingAnimationWidget.inkDrop(
      color: Colors.green,
      size: 100,
      )]
  );
}
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CustomErrorPopUp extends Alert {
  String reason;

  CustomErrorPopUp({required super.context, required this.reason});

  @override
  // TODO: implement buttons
  List<DialogButton>? get buttons => [];

  @override
  // TODO: implement title
  String? get title => "Error occurred while $reason";

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
  Widget get content => Column(children: [
        SizedBox(
          height: 30,
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
          child: const Text(
            "CANCEL",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
        ),
      ]);
}

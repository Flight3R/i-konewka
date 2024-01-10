import 'package:flutter/material.dart';
import 'package:i_konewka_app/screens/elements/PlantImage.dart';

class CustomToggleButtons extends StatefulWidget {

  final void Function(int index)? onPressed;
  final List<bool> isSelected;

  CustomToggleButtons({super.key, this.onPressed, required this.isSelected});

  @override
  State<StatefulWidget> createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons>{
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    
    const double padding = 6;
    const double fontSize = 20;
    
    
    return Padding(
      padding: EdgeInsets.only(
          left:size.width*0.10,
          right:size.width*0.10,
          bottom: size.width*0.10
      ),
      child: ToggleButtons(
          constraints: BoxConstraints.loose(Size.infinite),
          isSelected: widget.isSelected,
          borderRadius: BorderRadius.circular(10),
          fillColor: Colors.green,
          borderColor: Colors.green,
          borderWidth: 3,
        onPressed: widget.onPressed,
          children: const <Widget>[
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('MN',style: TextStyle(color: Colors.white,fontSize: fontSize),),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('TU',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('WE',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('TH',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('FR',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('SA',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Text('SU',style: TextStyle(color: Colors.white,fontSize: fontSize)),
            ),
          ],
      ),
    );
  }

}
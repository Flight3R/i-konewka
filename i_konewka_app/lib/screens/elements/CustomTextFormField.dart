import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  CustomTextFormField({
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
          left:size.width*0.10,
          right:size.width*0.10,
          bottom: size.width*0.10
      ),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green,width: 3.0)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green,width: 3.0)
          )
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: widget.onChanged,
        validator: widget.validator,

      ),
    );
  }
}

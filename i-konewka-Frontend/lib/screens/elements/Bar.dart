import 'package:flutter/material.dart';

class Bar extends StatelessWidget implements PreferredSizeWidget{
  const Bar({super.key});


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('I-Konewka'),
      centerTitle: true,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
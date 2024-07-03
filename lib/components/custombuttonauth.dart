import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed ;
  final String title;
const CustomButtonAuth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 50,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)),
      color: Color(0xffbd75329),
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text (title, style: TextStyle(fontSize: 18),),
    );
  }
}

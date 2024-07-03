import 'package:flutter/material.dart';

class CustomLogoAuth extends StatelessWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: 120,
          height: 120,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(70)),
          child: Image.asset(
            "images/Egyptian_Pyramids_with_Sphinx.png",
          )),
    );
  }
}

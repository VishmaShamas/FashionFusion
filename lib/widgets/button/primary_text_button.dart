import 'package:flutter/material.dart';

class PrimaryTextButton extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final double fontSize;
  final Color textColor;
  const PrimaryTextButton({super.key, required this.onPressed, required this.textColor, required this.title, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        title, style:TextStyle(
          fontSize:fontSize,
          fontFamily: 'Inter', fontWeight: FontWeight.bold, color:textColor,
        ),
      ),
    );
  }
}
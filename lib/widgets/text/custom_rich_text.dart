import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String title, subtitle;
  final TextStyle subtitleTextStyle;
  final VoidCallback onTab;
  const CustomRichText({
    required this.title,
    required this.subtitle,
    required this.onTab,
    required this.subtitleTextStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          children: <TextSpan>[
            TextSpan(text: subtitle, style: subtitleTextStyle),
          ],
        ),
      ),
    );
  }
}

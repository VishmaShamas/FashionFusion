import 'package:fashion_fusion/constants/images.dart';
import 'package:flutter/material.dart';

class BackgroundImageContainer extends StatelessWidget {
  const BackgroundImageContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.authBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

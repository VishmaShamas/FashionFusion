import 'package:dots_indicator/dots_indicator.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomDotsIndicator extends StatelessWidget {
  final double position;
  final int dotsCount;
  const CustomDotsIndicator({
    required this.position,
    required this.dotsCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: dotsCount,
      position: position,
      decorator: DotsDecorator(
        color: AppColors.white,
        size: const Size.square(8.0),
        activeSize: const Size(24, 8),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }
}

import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingAnimation extends StatelessWidget {
  const CustomLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackColor,
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.primary,
          size: 200,
        ),
      ),
    );
  }
}

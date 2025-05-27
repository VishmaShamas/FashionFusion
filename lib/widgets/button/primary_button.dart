// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:fashion_fusion/constants/colors.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final IconData? iconData;
  final Color? textColor, color;
  const PrimaryButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.iconData,
    this.textColor,
    this.color,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Tween<double> tween = Tween<double>(begin: 1.0, end: 0.95);

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: animationDuration)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.forward().then((_) {
          controller.reverse();
        });
        widget.onTap();
      },
      child: ScaleTransition(
        scale: tween.animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        ),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            height: widget.height ?? 50,
            alignment: Alignment.center,
            width: widget.width ?? double.maxFinite,
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.iconData != null) ...[
                  Icon(widget.iconData, color: AppColors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color:
                        widget.color == null ? AppColors.white : Colors.black,
                    fontSize: widget.fontSize ?? 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

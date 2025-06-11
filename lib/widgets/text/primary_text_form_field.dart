import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class PrimaryTextFormField extends StatelessWidget {
  final double? borderRadius;
  final Color? fillColor, hintTextColor, prefixIconColor;
  final String hintText;
  final OutlineInputBorder? border,
      enableBorder,
      focusedBorder,
      errorBorder,
      focusedErrorBorder;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(PointerDownEvent)? onTapOutside;
  final Function(String)? onChanged;
  final double height, width;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const PrimaryTextFormField({
    super.key,
    required this.hintText,
    this.border,
    this.enableBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.keyboardType,
    required this.controller,
    required this.width,
    required this.height,
    this.hintTextColor,
    this.fillColor,
    this.onChanged,
    this.onTapOutside,
    this.borderRadius = 8,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.obscureText = false, // ✅ properly assignable default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fillColor ?? AppColors.lightAccentColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText, // ✅ respects constructor argument
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.blackColor,
        ),
        decoration: InputDecoration(
          fillColor: fillColor ?? AppColors.lightAccentColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: hintTextColor ?? AppColors.blackColor,
          ),
          prefixIcon: prefixIcon,
          prefixIconColor: prefixIconColor,
          suffixIcon: suffixIcon,
          border: border,
          enabledBorder: enableBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedErrorBorder,
        ),
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        onTapOutside: onTapOutside,
      ),
    );
  }
}

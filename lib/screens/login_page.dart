import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/container/background_image_container.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 235,
                  right: 263,
                  bottom: 15,
                  left: 32,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: AppColors.lightAccentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 358,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.samiDarkColor.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.samiDarkColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        PrimaryTextFormField(
                          hintText: 'Email',
                          controller: emailController,
                          width: 326,
                          height: 48,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: AppColors.lightAccentColor,
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onTap: () {},
                          text: 'Continuer',
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          textColor: AppColors.white,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

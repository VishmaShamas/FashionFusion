// show error
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/login_page.dart';
import 'package:fashion_fusion/services/auth_service.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/container/background_image_container.dart';
import 'package:fashion_fusion/widgets/container/background_video_container.dart';
import 'package:fashion_fusion/widgets/text/custom_rich_text.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  void register() async {
    try {
      await authService.value.createAccount(
        email: emailController.text,
        password: passController.text,
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundVideoContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 235,
                  right: 240,
                  bottom: 15,
                  left: 32,
                ),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppColors.lightAccentColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
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
                        color: AppColors.samiDarkColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        CustomRichText(
                          onTab: () {},
                          title: 'Looks like you dont have an account.',
                          subtitle: 'Lets create a new account for you',
                          subtitleTextStyle: TextStyle(
                            color: AppColors.lightAccentColor,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryTextFormField(
                          hintText: 'Name',
                          controller: nameController,
                          width: 326,
                          height: 48,
                        ),
                        const SizedBox(height: 16),
                        PrimaryTextFormField(
                          hintText: 'Email',
                          controller: emailController,
                          width: 326,
                          height: 48,
                        ),
                        const SizedBox(height: 16),
                        PrimaryTextFormField(
                          hintText: 'Password',
                          controller: passController,
                          width: 326,
                          height: 48,
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.lightAccentColor,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(
                                text: 'By selected create account below',
                              ),
                              const TextSpan(text: 'I afree to'),
                              TextSpan(
                                text: '   Terms of service',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onTap: () {
                            register();
                          },
                          text: 'Create Account',
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          textColor: AppColors.white,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 24),
                        CustomRichText(
                          title: 'Log in',
                          subtitle: 'Already have an account',
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          subtitleTextStyle: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

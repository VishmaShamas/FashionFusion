import 'dart:io';

import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/constants/images.dart';
import 'package:fashion_fusion/screens/auth/forgot_pass_page.dart';
import 'package:fashion_fusion/screens/page_wrapper.dart';
import 'package:fashion_fusion/screens/auth/signup_page.dart';
import 'package:fashion_fusion/services/auth_service.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/button/secondary_button.dart';
import 'package:fashion_fusion/widgets/container/background_image_container.dart';
import 'package:fashion_fusion/widgets/text/custom_rich_text.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:fashion_fusion/widgets/ui/divider_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../widgets/button/primary_text_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errorMsg = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  void login(BuildContext context) async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      setState(() {
        errorMsg = "Email and password cannot be empty.";
      });
      return;
    }

    try {
      await authService.value.signIn(
        email: emailController.text,
        password: passController.text,
      );
      setState(() {
        errorMsg = "";
      });
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => PageWrapper()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message;
      });
    }
  }

  void loginWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => PageWrapper()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message ?? 'Something went wrong during sign in.';
      });
    }
  }

  void loginWithApple(BuildContext context) async {
    try {
      if (!Platform.isIOS) {
        setState(() {
          errorMsg = 'Apple Sign-In is only available on Apple devices';
          return;
        });
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => PageWrapper()),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      setState(() {
        errorMsg = e.message;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message ?? 'Something went wrong during sign in.';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

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
                  top: 180,
                  right: 200,
                  bottom: 15,
                  left: 0,
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
                    // ignore: deprecated_member_use
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
                        // email inout
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
                        // psss input
                        PrimaryTextFormField(
                          hintText: 'Password',
                          controller: passController,
                          width: 326,
                          height: 48,
                          obscureText: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: AppColors.lightAccentColor,
                        ),
                        const SizedBox(height: 16),
                        // logiu
                        PrimaryButton(
                          onTap: () => login(context),
                          text: 'Login',
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          textColor: AppColors.white,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        if (errorMsg != null && errorMsg!.isNotEmpty)
                          Container(
                            width: 326,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMsg!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8,),
                        //  forgot pass
                        PrimaryTextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          textColor: AppColors.primary,
                          title: 'Forgot Password',
                          fontSize: 14,
                        ),
                        const SizedBox(height: 32),
                        const DividerRow(),
                        const SizedBox(height: 32),
                        SecondaryButton(
                          onTap: () => loginWithGoogle(context),
                          text: 'Login with Google',
                          icons: AppAssets.googleLogo,
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          textColor: AppColors.blackColor,
                          bgColor: AppColors.lightAccentColor,
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          onTap: () {
                            loginWithApple(context);
                          },
                          text: 'Login with Apple',
                          icons: AppAssets.appleLogo,
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          textColor: AppColors.blackColor,
                          bgColor: AppColors.lightAccentColor,
                        ),
                        const SizedBox(height: 32),
                        CustomRichText(
                          title: "Don't have an account",
                          subtitle: ' Sign up',
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
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

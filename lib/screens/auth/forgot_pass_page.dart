import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/widgets/container/background_image_container.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import '../../widgets/ui/loader.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String? errorMsg;
  bool isError = false;
  bool isLoading = false;

  void sendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMsg = "Please enter your email";
        isError = true;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        errorMsg = "Reset email sent! Check your inbox.";
        isError = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message ?? "Something went wrong.";
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 235),
                  const Padding(
                    padding: EdgeInsets.only(left: 32, right: 150, bottom: 15),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
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
                            color: AppColors.samiDarkColor.withOpacity(0),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PrimaryTextFormField(
                            hintText: 'Enter your email',
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
                            onTap: sendResetEmail,
                            text: isLoading ? 'Sending...' : 'Send Reset Link',
                            borderRadius: 8,
                            fontSize: 14,
                            height: 48,
                            width: 326,
                            textColor: AppColors.white,
                            color: AppColors.primary,
                          ),
                          if (errorMsg != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              errorMsg!,
                              style: TextStyle(
                                color: isError ? Colors.red : Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Positioned.fill(child: CustomLoadingAnimation()),
          ],
        ),
      ),
    );
  }
}

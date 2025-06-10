import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/login_page.dart';
import 'package:fashion_fusion/services/auth_service.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/container/background_video_container.dart';
import 'package:fashion_fusion/widgets/text/custom_rich_text.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:flutter/foundation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  String errorMsg = '';
  int selectedBodyTypeIndex = 0;

  final List<Map<String, String>> bodyTypes = [
    {
      'label': 'Ectomorph',
      'image': 'bodyType/ecto.jpg', // replace with real asset
      'desc': 'Lean & slender physique'
    },
    {
      'label': 'Mesomorph',
      'image': 'bodyType/meso.jpg',
      'desc': 'Athletic build, easy muscle gain'
    },
    {
      'label': 'Endomorph',
      'image': 'bodyType/endo.jpg',
      'desc': 'Stocky build, slower metabolism'
    },
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    setState(() => errorMsg = '');

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if ([name, email, password].any((s) => s.isEmpty)) {
      setState(() => errorMsg = "All fields are required.");
      return;
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => errorMsg = "Enter a valid email address.");
      return;
    }

    try {
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        setState(() => errorMsg = "Email is already registered.");
        return;
      }

      await authService.value.createAccount(
        email: email,
        password: password,
        // optionally send name + bodyTypeIndex to your backend
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMsg = e.message ?? "Something went wrong.");
      if (kDebugMode) {
        print("Signup error: ${e.code}: ${e.message}");
      }
    } catch (e) {
      setState(() => errorMsg = "Unexpected error occurred.");
      if (kDebugMode) print("Unexpected signup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundVideoContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
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
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.samiDarkColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.samiDarkColor.withOpacity(0.5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      CustomRichText(
                        onTab: () {},
                        title: 'Looks like you don’t have an account.',
                        subtitle: 'Let’s create a new account for you.',
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
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          itemCount: bodyTypes.length,
                          controller: PageController(viewportFraction: 0.7),
                          onPageChanged: (i) {
                            setState(() => selectedBodyTypeIndex = i);
                          },
                          itemBuilder: (context, i) {
                            final bt = bodyTypes[i];
                            final isSel = i == selectedBodyTypeIndex;
                            return Column(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSel
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      bt['image']!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bt['label']!,
                                  style: TextStyle(
                                    fontWeight:
                                        isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel
                                        ? AppColors.primary
                                        : AppColors.lightAccentColor,
                                  ),
                                ),
                                if (isSel)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      bt['desc']!,
                                      style: TextStyle(
                                        color: AppColors.lightAccentColor,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMsg.isNotEmpty)
                        Container(
                          width: 326,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            errorMsg,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      PrimaryButton(
                        onTap: register,
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
                        title: 'Log in ',
                        subtitle: 'Already have an account?',
                        onTab: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_fusion/screens/page_wrapper.dart';
import 'package:fashion_fusion/widgets/container/background_image_container.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/auth/login_page.dart';
import 'package:fashion_fusion/services/auth_service.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/text/custom_rich_text.dart';
import 'package:fashion_fusion/widgets/text/primary_text_form_field.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../../widgets/ui/loader.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  String errorMsg = '';
  int selectedBodyTypeIndex = 0;

  final List<Map<String, String>> bodyTypes = [
    {
      'label': 'Ectomorph',
      'image': 'assets/bodyType/ecto.jpg',
      'desc': 'Lean & slender physique',
    },
    {
      'label': 'Mesomorph',
      'image': 'assets/bodyType/meso.jpg',
      'desc': 'Athletic build, easy muscle gain',
    },
    {
      'label': 'Endomorph',
      'image': 'assets/bodyType/endo.jpg',
      'desc': 'Stocky build, slower metabolism',
    },
    {
      'label': 'Rectangle',
      'image': 'assets/bodyType/rectangle.jpg',
      'desc': 'Shoulders & hips same width, no defined waist.',
    },
    {
      'label': 'Triangle',
      'image': 'assets/bodyType/triangle.jpg',
      'desc': 'Hips wider than shoulders, sloping shoulders.',
    },
    {
      'label': 'Oval',
      'image': 'assets/bodyType/oval.jpg',
      'desc': 'Larger midsection, rounder body shape.',
    },
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    setState(() {
      errorMsg = '';
      isLoading = true;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();

    if ([name, email, password, confirmPassword].any((s) => s.isEmpty)) {
      setState(() {
        errorMsg = "All fields are required.";
        isLoading = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        errorMsg = "Enter a valid email address.";
        isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMsg = "Password must be at least 6 characters.";
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMsg = "Passwords do not match.";
        isLoading = false;
      });
      return;
    }

    try {
      // ignore: deprecated_member_use
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );
      if (methods.isNotEmpty) {
        setState(() {
          errorMsg = "Email is already registered.";
          isLoading = false;
        });
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        // Create Firestore user document
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'bodyTypeIndex': selectedBodyTypeIndex,
          'wardrobe': [],
          'likedProds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PageWrapper()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message ?? "Something went wrong.";
        isLoading = false;
      });
      if (kDebugMode) {
        print("Signup error: ${e.code}: ${e.message}");
      }
    } catch (e) {
      setState(() {
        errorMsg = "Unexpected error occurred.";
        isLoading = false;
      });
      if (kDebugMode) print("Unexpected signup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
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
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.samiDarkColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        PrimaryTextFormField(
                          hintText: 'Name',
                          controller: nameController,
                          width: 326,
                          height: 48,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: AppColors.lightAccentColor,
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
                        PrimaryTextFormField(
                          hintText: 'Password',
                          controller: passController,
                          width: 326,
                          height: 48,
                          obscureText: !showPassword,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: AppColors.lightAccentColor,
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextFormField(
                          hintText: 'Confirm Password',
                          controller: confirmPassController,
                          width: 326,
                          height: 48,
                          obscureText: !showConfirmPassword,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: AppColors.lightAccentColor,
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Select Your Body Type",
                          style: TextStyle(
                            color: AppColors.lightAccentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 210,
                          child: PageView.builder(
                            itemCount: bodyTypes.length,
                            controller: PageController(
                              viewportFraction: 0.5,
                              initialPage: selectedBodyTypeIndex,
                            ),
                            onPageChanged: (i) {
                              setState(() => selectedBodyTypeIndex = i);
                            },
                            itemBuilder: (context, i) {
                              final bt = bodyTypes[i];
                              final isSel = i == selectedBodyTypeIndex;
                              double scale = isSel ? 1.0 : 0.8;
                              double blur = isSel ? 0.0 : 2.0;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  children: [
                                    Transform.scale(
                                      scale: scale,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    isSel
                                                        ? AppColors.primary
                                                        : Colors.transparent,
                                                width: 3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                bt['image']!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          if (!isSel)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: blur,
                                                  sigmaY: blur,
                                                ),
                                                child: Container(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      bt['label']!,
                                      style: TextStyle(
                                        fontWeight:
                                            isSel
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        color:
                                            isSel
                                                ? AppColors.primary
                                                : AppColors.lightAccentColor,
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      height: isSel ? 48 : 0,
                                      curve: Curves.ease,
                                      child:
                                          isSel
                                              ? Container(
                                                width: 150,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 6.0,
                                                    ),
                                                child: Text(
                                                  bt['desc']!,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors
                                                            .lightAccentColor,
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 16),
                        CustomRichText(
                          title: 'Log in ',
                          subtitle: 'Already have an account?',
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
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
            if (isLoading)
              const Positioned.fill(child: CustomLoadingAnimation()),
          ],
        ),
      ),
    );
  }
}

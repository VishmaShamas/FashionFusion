import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/auth/login_page.dart';
import 'package:fashion_fusion/widgets/button/primary_button.dart';
import 'package:fashion_fusion/widgets/cards/custom_gradient_card.dart';
import 'package:fashion_fusion/widgets/cards/onboarding_card.dart';
import 'package:fashion_fusion/widgets/getStarted/onboarding.dart';
import 'package:flutter/material.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  int currentIndex = 0;
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(onboardingList[currentIndex].bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomGradientCard(
          gradient: AppColors.customOnBoardingGradient,
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: onboardingList.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingCard(onboarding: onboardingList[index]);
                  },
                ),
              ),
              const SizedBox(height: 20),
              // CustomDotsIndicator(
              //   position: currentIndex.toDouble(),
              //   dotsCount: onboardingList.length,
              // ),
              const SizedBox(height: 30),
              PrimaryButton(
                onTap: () {
                  if (currentIndex == onboardingList.length - 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );
                  }
                },
                text: "Get Started",
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

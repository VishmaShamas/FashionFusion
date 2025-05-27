import 'package:fashion_fusion/constants/images.dart';

class Onboarding {
  String bgImage;
  String title;
  String info;
  Onboarding({required this.bgImage, required this.title, required this.info});
}

List<Onboarding> onboardingList = [
  Onboarding(
    bgImage: AppAssets.onboardingFirst,
    title: "Onboarding 1",
    info: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  ),
  Onboarding(
    bgImage: AppAssets.onboardingSecond,
    title: "Onboarding 2",
    info: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  ),
  // Onboarding(
  //   bgImage: AppAssets.onboardingThird,
  //   title: "Onboarding 3",
  //   info: "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
  // ),
];

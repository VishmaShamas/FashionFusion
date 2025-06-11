import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/liked_products.dart';
import 'package:fashion_fusion/screens/product_page.dart';
import 'package:fashion_fusion/screens/auth/profile_page.dart';
import 'package:fashion_fusion/screens/home_page.dart';
import 'package:fashion_fusion/screens/wardrobe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PageWrapper extends StatefulWidget {
  const PageWrapper({super.key});

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> {
  int _currentIndex = 2; // Start with Home selected (center item)

  static final List<Widget> _pages = [
    const LikedProducts(),
    const ProductPage(),
    const HomePage(),
    const WardrobePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final Color defaultColor;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.selectedColor = AppColors.primary,
    this.defaultColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Increased height to accommodate all elements
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: CupertinoIcons.heart_fill,
                    label: "Likes",
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.bag_fill,
                    label: "Shop",
                    index: 1,
                  ),
                  const SizedBox(width: 48), // Space for center FAB
                  _buildNavItem(
                    icon: CupertinoIcons.square_grid_2x2_fill,
                    label: "Wardrobe",
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.person_fill,
                    label: "Profile",
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
          // Centered home button
          Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.house_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? selectedColor : defaultColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? selectedColor : defaultColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
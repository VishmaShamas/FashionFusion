import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomFloatingNavBar extends StatefulWidget {
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
  State<CustomFloatingNavBar> createState() => _CustomFloatingNavBarState();
}

class _CustomFloatingNavBarState extends State<CustomFloatingNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Slightly increased height to prevent overflow
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // Important to prevent clipping of FAB
        children: [
          // Horizontal divider
          const Align(
            alignment: Alignment.topCenter,
            child: Divider(height: 1, thickness: 0.5, color: Colors.black12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side items
                _buildNavItem(
                  icon: Icons.favorite,
                  index: 0,
                  label: 'Wishlist',
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  index: 1,
                  label: 'Cart',
                ),

                // Right side items
                _buildNavItem(
                  icon: Icons.recommend,
                  index: 3,
                  label: 'For You',
                ),
                _buildNavItem(icon: Icons.person, index: 4, label: 'Profile'),
              ],
            ),
          ),

          // Centered home button
          Positioned(
            left: 0,
            right: 0,
            top: -20, // Adjust this to position the FAB properly
            child: Center(
              child: FloatingActionButton(
                mini: true,
                elevation: 4,
                shape: const CircleBorder(),
                backgroundColor: widget.selectedColor,
                onPressed: () => widget.onTap(2),
                child: const Icon(Icons.home, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = widget.currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60, // Fixed width to prevent overflow
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? widget.selectedColor : widget.defaultColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isSelected ? widget.selectedColor : widget.defaultColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

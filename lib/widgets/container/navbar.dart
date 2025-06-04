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
      height: 50, // Reduced height
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(
          25,
        ), // Smaller radius for straighter look
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Horizontal divider
          const Align(
            alignment: Alignment.topCenter,
            child: Divider(height: 1, thickness: 0.5, color: Colors.black12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side items
              _buildNavItem(icon: Icons.favorite, index: 0),
              _buildNavItem(icon: Icons.shopping_bag, index: 1),

              // Center spacer for the home button
              const SizedBox(width: 48),

              // Right side items
              _buildNavItem(icon: Icons.checkroom, index: 3),
              _buildNavItem(icon: Icons.person, index: 4),
            ],
          ),

          // Centered home button\
          Center(
            child: Transform.translate(
              offset: const Offset(0, 0), // Move up slightly
              child: FloatingActionButton(
                mini: true,
                elevation: 0,
                shape: CircleBorder(),
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

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = widget.currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? widget.selectedColor : widget.defaultColor,
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/liked_products.dart';
import 'package:fashion_fusion/screens/product_page.dart';
import 'package:fashion_fusion/screens/profile_page.dart';
import 'package:fashion_fusion/screens/home_page.dart';
import 'package:fashion_fusion/screens/wardrobe_page.dart';
import 'package:fashion_fusion/widgets/button/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:fashion_fusion/widgets/container/navbar.dart';

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
        pages: _pages,
      ),
    );
  }
}



// class CustomFloatingNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final Color backgroundColor;
//   final Color selectedColor;
//   final Color defaultColor;

//   const CustomFloatingNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     this.backgroundColor = Colors.transparent,
//     this.selectedColor = AppColors.primary,
//     this.defaultColor = AppColors.primary,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 2,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: Stack(
//           children: [
//             CustomPaint(
//               size: Size(MediaQuery.of(context).size.width, 70),
//               painter: BottomNavCurvePainter(
//                 backgroundColor: backgroundColor,
//                 insetRadius: 38,
//               ),
//             ),
//             Center(
//               heightFactor: 0.6,
//               child: FloatingActionButton(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(100.0),
//                 ),
//                 backgroundColor: selectedColor,
//                 elevation: 0.1,
//                 onPressed: () => onTap(2), // Home is center item
//                 child: const Icon(CupertinoIcons.home, color: Colors.black),
//               ),
//             ),
//             SizedBox(
//               height: 70,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   // Left side items (Recommendation and Products)
//                   _buildNavItem(icon: Icons.thumb_up, label: "Rec", index: 0),
//                   _buildNavItem(
//                     icon: Icons.shopping_bag,
//                     label: "Products",
//                     index: 1,
//                   ),
//                   const SizedBox(width: 56), // Space for center FAB
//                   // Right side items (Wardrobe and Profile)
//                   _buildNavItem(
//                     icon: Icons.checkroom,
//                     label: "Wardrobe",
//                     index: 3,
//                   ),
//                   _buildNavItem(
//                     icon: CupertinoIcons.person,
//                     label: "Profile",
//                     index: 4,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = currentIndex == index;
//     return InkWell(
//       onTap: () => onTap(index),
//       borderRadius: BorderRadius.circular(30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             backgroundColor: isSelected ? Colors.white : Colors.transparent,
//             child: Icon(
//               icon,
//               size: 25,
//               color: isSelected ? Colors.black : defaultColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? selectedColor : defaultColor,
//               fontSize: 12,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class BottomNavCurvePainter extends CustomPainter {
  BottomNavCurvePainter({
    this.backgroundColor = Colors.black,
    this.insetRadius = 38,
  });

  final Color backgroundColor;
  final double insetRadius;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      insetCurveBeginnningX - transitionToInsetCurveWidth,
      0,
    );

    path.quadraticBezierTo(
      insetCurveBeginnningX,
      0,
      insetCurveBeginnningX,
      insetRadius / 2,
    );

    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );

    path.quadraticBezierTo(
      insetCurveEndX,
      0,
      insetCurveEndX + transitionToInsetCurveWidth,
      0,
    );

    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fashion Fusion",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CustomIconButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedProducts(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            CustomIconButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: TextFormField(
          autofocus: false,
          cursorHeight: 15,
          cursorColor: Colors.grey,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(15),
            border: InputBorder.none,
            hintText: 'Search',
            suffixIcon: Icon(Icons.search),
            suffixIconColor: Colors.black,
          ),
        ),
      ),
    );
  }
}

class ChoiceChipWidget extends StatefulWidget {
  const ChoiceChipWidget({super.key});

  @override
  State<ChoiceChipWidget> createState() => _ChoiceChipWidgetState();
}

class _ChoiceChipWidgetState extends State<ChoiceChipWidget> {
  List<String>? _choices;
  int? _defaultChoiceIndex;
  Color? iColor;

  @override
  void initState() {
    _choices = ['All', 'Flight', 'Cruise', 'Train', 'Bus'];
    _defaultChoiceIndex = 0;
    iColor = Colors.grey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _choices!.length,
        itemBuilder: (BuildContext context, int index) {
          return ChoiceChip(
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            label: Text(
              _choices![index],
              style: TextStyle(fontSize: 20).copyWith(
                color: _defaultChoiceIndex == index ? Colors.white : iColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            selected: _defaultChoiceIndex == index,
            selectedColor: AppColors.pinkColor,
            // ignore: deprecated_member_use
            backgroundColor: Colors.grey.withOpacity(0.2),
            onSelected: (bool selected) {
              setState(() {
                _defaultChoiceIndex = selected ? index : 0;
              });
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 10);
        },
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  final Cities city;
  const CityCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Hero(
        tag: city.imagePath,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(city.imagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                bottom: 20,
                child: Text(
                  city.cityName,
                  style: TextStyle(fontSize: 20).copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 15,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.white,
                  ),
                  height: 40,
                  width: 60,
                  child: Center(
                    child: Text(
                      "${city.priceInDollars}".toString(),
                      style: TextStyle(fontSize: 15).copyWith(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
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

class Cities {
  String cityName;
  String imagePath;
  int priceInDollars;
  Cities({
    required this.cityName,
    required this.imagePath,
    required this.priceInDollars,
  });
}

Cities newYork = Cities(
  cityName: 'New York',
  imagePath:
      'https://images.unsplash.com/photo-1511527661048-7fe73d85e9a4?q=80&w=1965&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  priceInDollars: 100,
);

Cities paris = Cities(
  cityName: 'Paris',
  imagePath:
      'https://images.unsplash.com/photo-1554939437-ecc492c67b78?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  priceInDollars: 120,
);

Cities italy = Cities(
  cityName: 'Italy',
  imagePath:
      'https://images.unsplash.com/photo-1549643276-fdf2fab574f5?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  priceInDollars: 150,
);

Cities rome = Cities(
  cityName: 'Rome',
  imagePath:
      'https://images.unsplash.com/photo-1504019347908-b45f9b0b8dd5?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  priceInDollars: 225,
);

Cities spain = Cities(
  cityName: 'Spain',
  imagePath:
      'https://images.unsplash.com/photo-1509840841025-9088ba78a826?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  priceInDollars: 150,
);

List<Cities> citiesList = [newYork, paris, italy, rome, spain];

import 'package:fashion_fusion/screens/page_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FashionFusion',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto', // Customize your font
      ),
      home: MenuList(),
    );
  }
}

class MenuList extends StatelessWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageWrapper(),
      // Center(
      //   // This centers the Column on the screen
      //   child: Column(
      //     mainAxisSize:
      //         MainAxisSize.min, // Shrinks the column to fit the children
      //     children: [
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => LoginScreen()),
      //           );
      //         },
      //         child: Text('Login Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => SignUpScreen()),
      //           );
      //         },
      //         child: Text('Signup Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => HomePage()),
      //           );
      //         },
      //         child: Text('Home Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
      //           );
      //         },
      //         child: Text('Forgot Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => ProductDetailPage()),
      //           );
      //         },
      //         child: Text('Product Detail Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => PersonalizedRecommendationPage(),
      //             ),
      //           );
      //         },
      //         child: Text('Recommendation Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => WardrobePage()),
      //           );
      //         },
      //         child: Text('Wardrobe Page'),
      //       ),
      //       SizedBox(height: 50),
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => GetStartedPage()),
      //           );
      //         },
      //         child: Text('Get Started Page'),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

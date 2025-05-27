import 'package:fashion_fusion/screens/login_page.dart';
import 'package:fashion_fusion/screens/signup_page.dart';
import 'package:fashion_fusion/screens/home_page.dart';
import 'package:fashion_fusion/screens/forgot_pass_page.dart';
import 'package:fashion_fusion/screens/product_detail.dart';
import 'package:fashion_fusion/screens/recommendation.dart';
import 'package:fashion_fusion/screens/wardrobe.dart';
import 'package:fashion_fusion/screens/get_started.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // If using the FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Or manually configure
  );
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
      body: Center(
        // This centers the Column on the screen
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Shrinks the column to fit the children
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Signup Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Home Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text('Forgot Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailPage()),
                );
              },
              child: Text('Product Detail Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalizedRecommendationPage(),
                  ),
                );
              },
              child: Text('Recommendation Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WardrobePage()),
                );
              },
              child: Text('Wardrobe Page'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetStartedPage()),
                );
              },
              child: Text('Get Started Page'),
            ),
          ],
        ),
      ),
    );
  }
}

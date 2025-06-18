import 'package:fashion_fusion/screens/auth/get_started.dart';
import 'package:fashion_fusion/screens/auth/login_page.dart';
import 'package:fashion_fusion/screens/page_wrapper.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Roboto'),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isFirstLaunch = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('isFirstLaunch') ?? true;
    // final isFirst = true;

    if (isFirst) {
      await prefs.setBool('isFirstLaunch', false);
      setState(() {
        isFirstLaunch = true;
        loading = false;
      });
    } else {
      setState(() {
        isFirstLaunch = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CustomLoadingAnimation()));
    }

    if (isFirstLaunch) {
      return const GetStartedPage();
      // return const PageWrapper();
    }

    // Not first launch: now check FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const PageWrapper(); // Logged in
    } else {
      return const LoginScreen(); // Not logged in
    }
  }
}

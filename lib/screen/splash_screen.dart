import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/login_screen.dart';
import 'package:attendenceapp/widget/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  void _checkLoggedInUser() async {

    User? user = FirebaseAuth.instance.currentUser;

    // Delay the navigation slightly to show the splash screen.
    await Future.delayed(Duration(seconds: 2));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => user != null ? NavBar() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Image.asset('assets/logo.jpg', height: 300, width: 300),
      ),
    );
  }
}


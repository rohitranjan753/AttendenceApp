import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/login_screen.dart';
import 'package:attendenceapp/widget/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
    await Future.delayed(Duration(seconds: 4));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => user != null ? NavBar() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Lottie.asset(
              'assets/facial_logo.json',
              height: MediaQuery.of(context).size.height * 0.6,
              repeat: true,
              reverse: true,
            ),
            Text('AttendEase',style: TextStyle(fontSize: 30,letterSpacing: 3),)
          ],
        ),
      ),
    );
  }
}


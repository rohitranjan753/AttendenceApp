import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Image.asset('assets/logo.jpg',height: 300,width: 300,),
        nextScreen: LoginPage(),

        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.blue);
  }
}

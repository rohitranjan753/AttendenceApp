import 'package:attendenceapp/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileSState();
}

class _ProfileSState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          height: 70,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
          child: MaterialButton(onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
            } catch (e) {
              print('Error during logout: $e');
              // Handle error, show a snackbar, etc.
            }

          },child: Text('LOGOUT',style: TextStyle(letterSpacing: 3,fontSize: 25,color: Colors.white),),),
        ),
      ),
    );
  }
}

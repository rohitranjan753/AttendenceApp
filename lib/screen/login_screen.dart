import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/signup_screen.dart';
import 'package:attendenceapp/widget/navbar.dart';
import 'package:attendenceapp/widget/scaffold_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = true;

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signInWithEmailAndPassword(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );

        if (userCredential.user != null) {
          // Create a new user document in Firestore
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => NavBar()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String? message = "An error occured, Check credential";
      if (e.message != null) {
        message = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message!),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/welcome_hi.json',
                height: MediaQuery.of(context).size.height * 0.2,
                repeat: true,
                reverse: true,
              ),
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (_emailController.text == null ||
                            _emailController.text == "") {
                          return 'Email empty';
                        }
                      },
                      controller: _emailController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: "Type your email",
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (_passController.text == null ||
                            _passController.text == "") {
                          return 'Password empty';
                        } else if (_passController.text.length <= 6) {
                          return 'Password length must be greater than 6';
                        }
                      },
                      controller: _passController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.fingerprint_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                          hintText: "Type your password",
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      keyboardType: TextInputType.text,
                      obscureText: passwordVisible,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(6),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.purple),
                child: MaterialButton(
                  onPressed: () {
                    _signInWithEmailAndPassword(context);
                  },
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                        letterSpacing: 3, fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.purple),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

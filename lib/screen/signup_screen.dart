import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/login_screen.dart';
import 'package:attendenceapp/widget/navbar.dart';
import 'package:attendenceapp/widget/scaffold_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool passwordVisible = true;

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signUpWithEmailAndPassword(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );

        if (userCredential.user != null) {
          // Create a new user document in Firestore
          await _firestore
              .collection('Users')
              .doc(userCredential.user!.uid)
              .set({
            'email': _emailController.text,
          });
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
                'assets/signup_lottie.json',
                height: MediaQuery.of(context).size.height * 0.2,
                repeat: true,
                reverse: true,
              ),
              Text(
                "Sign up",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Create an account, It's free",
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              SizedBox(height: 50,),
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
                          labelText: "Enter email",
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
                          return 'Password must be greater than 6';
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
                          labelText: "Enter password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      keyboardType: TextInputType.text,
                      obscureText: passwordVisible,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Container(
                padding: EdgeInsets.all(6),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.purple),
                child: MaterialButton(
                  onPressed: () {
                    _signUpWithEmailAndPassword(context);
                  },
                  child: Text('SIGN UP',style: TextStyle(
                      letterSpacing: 3, fontSize: 20, color: Colors.white),),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      " Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18,color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

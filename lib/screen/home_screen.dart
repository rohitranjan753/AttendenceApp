import 'package:attendenceapp/screen/upload_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  String buttonText = 'CHECK-IN';
  Color buttonColor = Colors.black;

  Future<bool> hasCheckedInToday() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final querySnapshot = await userDocRef
        .collection('attendance')
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(

        // appBar: AppBar(
        //   // backgroundColor: Colors.purple,
        //   title: Text('Home Screen'),
        //   centerTitle: true,
        // ),
        body: SingleChildScrollView(
          child: Column(

            children: [
              Text('Welcome,',style: TextStyle(
                fontSize: 30
              ),textAlign: TextAlign.start,),

              Container(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                      text: DateTime.now().day.toString(),
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 30,
                      ),
                      children: [
                        TextSpan(
                            text: DateFormat(' MMM yy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ))
                      ]),
                ),
              ),
              StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('hh:mm:ss a').format(DateTime.now()),
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                    );
                  }),
              SizedBox(
                height: 50,
              ),
              Container(
                height: 60,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: MaterialButton(
                  onPressed: buttonColor == Colors.black
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UploadScreen()));
                        }
                      : () {
                          print(buttonColor);
                        },
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, letterSpacing: 3),
                  ),
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didPopNext() {
    super.didPopNext();
    checkCheckInStatus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkCheckInStatus();
  }

  void checkCheckInStatus() async {
    final hasCheckedIn = await hasCheckedInToday();

    if (hasCheckedIn) {
      setState(() {
        buttonColor = Colors.grey;
        buttonText = 'ALREADY CHECKED IN';
      });
    }
  }
}

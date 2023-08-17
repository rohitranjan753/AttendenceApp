
import 'package:attendenceapp/screen/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Welcome,'),
            Text(
              'Rohit',
              style: TextStyle(fontSize: 20),
            ),
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

                child: MaterialButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadScreen()));
                }, child: Text('CHECK-IN',style: TextStyle(color: Colors.white,fontSize: 20,letterSpacing: 3),))),


          ],
        ),
      ),
    );
  }
}

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
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/logo.jpg')),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
                border: Border(),
                borderRadius: BorderRadius.circular(40),
              ),
              height: 200,
              width: 200,
            )
          ],
        ),
      ),
    );
  }
}

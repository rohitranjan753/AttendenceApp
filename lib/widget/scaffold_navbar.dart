import 'package:attendenceapp/screen/home_screen.dart';
import 'package:attendenceapp/screen/profile_screen.dart';
import 'package:attendenceapp/screen/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ScaffoldNavBar extends StatefulWidget {
  const ScaffoldNavBar({Key? key}) : super(key: key);

  @override
  State<ScaffoldNavBar> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ScaffoldNavBar> {
  int currrentIndex=0;
  List<IconData> navigationIcons=[
    Icons.home_filled,
    Icons.person,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currrentIndex,
        children: [
          HomeScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2,2)
              )
            ]
        ),
        child: ClipRRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for(int i=0;i<navigationIcons.length;i++)...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        currrentIndex=i;
                      });
                    },
                    child: Center(
                      child: Icon(navigationIcons[i],
                        size: i==currrentIndex? 40:30,
                        color: i==currrentIndex? Colors.lightBlue : Colors.black45,),

                    ),
                  ),
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}

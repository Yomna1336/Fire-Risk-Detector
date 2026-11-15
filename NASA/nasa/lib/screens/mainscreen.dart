import 'package:flutter/material.dart';
import 'package:nasa/screens/firstScreen.dart';
import 'package:nasa/screens/fourthScreen.dart';
import 'package:nasa/screens/myWidget.dart';
import 'package:nasa/screens/predictFires.dart';
import 'package:nasa/screens/secondScreen.dart';
import 'package:nasa/screens/thirdScreen.dart';
 

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(221, 6, 10, 12),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            children: [
              mytext(
                text: "FIRE RISKS DETACTOR",
                fontsize: 25,
                fontWeight: FontWeight.w400,
              ),

              TabBar(
                onTap: (selectedTabIndx) {},
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelColor: const Color.fromARGB(255, 234, 23, 23),
                unselectedLabelColor: Colors.white,
                indicatorColor: const Color.fromARGB(255, 234, 23, 23),

                tabs: [
                  Tab(child: Text("Home")),
                  Tab(child: Text("Live Map")),
                  Tab(child: Text("Analytics")),
                  Tab(child: Text("Predict Fires")),
                  Tab(child: Text("About")),
                ],
              ),
            ],
          ),
          actions: [logo()],
        ),

        body: TabBarView(
          children: [
            Firstscreen(),
            Secondscreen(isActive:  true,),
            Thirdscreen(),
            Predictfires(),
            Fourthscreen(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nasa/screens/detailsofFirst.dart';

 

class Firstscreen extends StatelessWidget {
  const Firstscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
             Gap( 10),
              
              Stack(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      "assets/mainscreen.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 650,
                    ),
                  ),

                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: -300.0, end: 0.0),
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(value, 0.0),
                        child: child,
                      );
                    },
                    child: Details(),
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

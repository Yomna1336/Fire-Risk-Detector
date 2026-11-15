import 'package:flutter/material.dart';
import 'package:nasa/screens/mainscreen.dart';
 
  
 

void main() {
  runApp(const LandsatApp());
}

class LandsatApp extends StatelessWidget {
  const LandsatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landsat Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005B96),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home:   MainHomeScreen(),
    );
  }
}

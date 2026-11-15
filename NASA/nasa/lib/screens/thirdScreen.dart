import 'package:flutter/material.dart';
import 'package:nasa/theAnalysismap/presentation/screen/map_screen.dart';

class  Thirdscreen extends StatefulWidget {
  const  Thirdscreen({super.key});

  @override
  State< Thirdscreen> createState() => _ThirdscreenState();
}

class _ThirdscreenState extends State< Thirdscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   MapScreen()
    );
  }
}
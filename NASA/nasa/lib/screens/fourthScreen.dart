// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Fourthscreen extends StatelessWidget {
  const Fourthscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(10),
              Row(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      "assets/about.jpg",
                      fit: BoxFit.cover,
                      height: 150,
                      width: 200,
                    ),
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                  Gap(18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ABOUT FIRE RISKS DETACTOR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FIRE RISKS DETACTOR is a SATELLITE-BASED FIRE MONITORING platform that uses VIIRS and MODIS satellite\ndata to FIRE PREDICTION, track, manitor, analyze world fires in real time,OUR MISSION is to provide accurate,\nreliadle and accessible information to support faster response and better decision-making for a safer and\nmore sustainable future.",
                      ),
                    ],
                  ),
                ],
              ),
              Gap(30),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DATA SOURCES",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 10, 115, 164),
                        ),
                      ),
                      Gap(6),
                      Text(
                        "VIIRS & MODIS Satellite Data",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(6),

                      Text(
                        "We use data from NASA’s VIIRS and MODIS satellites to predict, detect and monitor world fires.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 10, 115, 164),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Image.asset( "assets/screen.jpg" , fit: BoxFit.cover,width: 400,height: 150,)
                ],
              ),
               
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Box(
                    number1: -360,
                    photo: "assets/VIIRS.jpg",
                    tex1: "VIIRS",
                    tex2: 'Visible Infrared Imaging Radiometer Suite',
                    tex3:
                        '* Launched: 2011\n* Spatial Resolution: 375 m\n* Spectral Bands: 22\n* Revisit Time: ~12 hours\n* Best for: Small fires, high detail',
                  ),

                  Box(
                    number1: 360,
                    photo: "assets/MODIS.jpg",
                    tex1: "MODIS",
                    tex2: 'Moderate Resolution Imaging Spectroradiometer',
                    tex3:
                        '* Launched: 1999 (Terra) / 2002 (Aqua)\n* Spatial Resolution: 1 km\n* Spectral Bands: 36\n* Revisit Time: ~1-2 days\n* Best for: Large-scale fires, long-term trends',
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

class Box extends StatelessWidget {
  const Box({
    super.key,
    required this.number1,
    required this.photo,
    required this.tex1,
    required this.tex2,
    required this.tex3,
  });
  final double number1;
  final String photo;
  final String tex1;
  final String tex2;
  final String tex3;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: number1, end: 0.0),
      duration: const Duration(seconds: 3),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value, 0.0), child: child);
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      photo,
                      fit: BoxFit.cover,
                      height: 75,
                      width: 90,
                    ),
                    borderRadius: BorderRadiusGeometry.circular(50),
                  ),
                  Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tex1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        tex2,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 10, 115, 164),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Gap(30),
              Text(tex3, style: TextStyle(fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        height: 250,
        width: 550,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: BoxBorder.all(color: const Color.fromARGB(255, 10, 115, 164)),
        ),
      ),
    );
  }
}

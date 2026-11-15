import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
 
 
import 'package:nasa/screens/myWidget.dart';

class Details extends StatelessWidget {
  const Details({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SATELLITE-BASED FIRE MONITORING",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Gap(10),
          Text(
            "Detecting World Fires",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "From Space",
            style: TextStyle(
              color: const Color.fromARGB(255, 234, 23, 23),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(10),
          Text(
            "Using VIIRS and MODIS satellite data to FIRE PREDICTION, track,\nmanitor, analyze world fires in real time, helping build a safer planet",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Gap(15),
          Row(
            children: [
              button(),
              Gap(15),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (c) => MainScreen()),
                  // );
                },

                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 207, 210, 207),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(6),
                    ),
                  ),
                ),

                child: Container(
                  width: 110,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 234, 23, 23),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
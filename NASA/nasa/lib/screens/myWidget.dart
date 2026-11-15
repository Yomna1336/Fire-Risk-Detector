import 'package:flutter/material.dart';
import 'package:nasa/screens/secondScreen.dart';


class mytext extends StatelessWidget {
  const mytext({
    super.key,
    required this.text,
    required this.fontsize,
    required this.fontWeight,
  });
  final String text;
  final double fontsize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: fontWeight,
        color: const Color.fromARGB(255, 234, 23, 23),
      ),
    );
  }
}

class logo extends StatelessWidget {
  const logo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Image.asset(
        "assets/NASA space apps.jpg",
        fit: BoxFit.cover,
        height: 55,
        width: 55,
      ),

      borderRadius: BorderRadiusGeometry.circular(40),
    );
  }
}

class button extends StatelessWidget {
  const button({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => Secondscreen(isActive:  true,)),
        );
      },

      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color.fromARGB(255, 234, 23, 23),
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
            "View Live Map",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

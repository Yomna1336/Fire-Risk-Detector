import 'package:flutter/material.dart';

class ContainerBar extends StatelessWidget {
  const ContainerBar({super.key, required this.text , required this.onTap , required this.isActive});
  final String text;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color:isActive?   const Color.fromARGB(255, 10, 115, 164 ):Colors.white ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color:isActive?   const Color.fromARGB(255, 10, 115, 164 ):Colors.white 
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}

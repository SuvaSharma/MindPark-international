import 'package:flutter/material.dart';

class TMTNode extends StatelessWidget {
  final int number;
  final String text;
  final double xPosition;
  final double yPosition;
  final Function(int) onTap;
  final Color color; // Add this line
  final Color textcolor;

  const TMTNode({
    super.key,
    required this.number,
    required this.text,
    required this.xPosition,
    required this.yPosition,
    required this.onTap,
    this.color = const Color(0xFF309092), // Default color
    this.textcolor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double radius =
        screenWidth * 0.035; // Adjust the radius relative to screen width
    double fontSize =
        radius * 0.9; // Adjust the font size relative to the radius
    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onTap: () {
          onTap(number); // Call the onTap callback with the node number
        },
        child: Material(
          elevation: 15,
          borderRadius: BorderRadius.circular(100),
          child: CircleAvatar(
            backgroundColor: color,
            radius: radius,
            child: Center(
              child: Text(
                text.toString(),
                style: TextStyle(
                    fontSize: fontSize,
                    color: textcolor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

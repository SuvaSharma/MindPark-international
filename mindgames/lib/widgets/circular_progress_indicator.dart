import 'package:flutter/material.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';

Widget buildProgressIndicator(BuildContext context, String label, double value,
    Color backgroundColor, double screenWidth) {
  // Determine the color based on the value
  Color color;
  if (value < 50) {
    color = Colors.red;
  } else if (value >= 50 && value < 75) {
    color = Colors.orange;
  } else {
    color = Colors.green;
  }

  final mediaQuery = MediaQuery.of(context);
  final screenWidth = mediaQuery.size.width;
  final screenHeight = mediaQuery.size.height;
  double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: baseSize * 0.18,
            height: baseSize * 0.18,
            child: CircularProgressIndicator(
              backgroundColor: backgroundColor,
              value: value / 100,
              color: color, // Use the dynamic color here
              strokeWidth: 6.0,
            ),
          ),
          Text(
            '${convertToNepaliNumbers(value.round().toString())}%',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

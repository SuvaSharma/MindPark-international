import 'package:flutter/material.dart';

class NumberOptions extends StatelessWidget {
  final double size;
  final int correctNumber;
  final void Function(int) onNumberSelected;

  const NumberOptions({
    Key? key,
    required this.correctNumber,
    required this.onNumberSelected,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize =
        screenWidth * 0.13; // Adjust the size relative to screen width
    final List<int> options = [
      correctNumber,
      (correctNumber + 1) % 31,
      (correctNumber + 2) % 31,
      (correctNumber + 3) % 31,
    ]..shuffle(); // Shuffle to randomize option positions

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((number) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => onNumberSelected(number),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    offset: Offset(4, 4),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-1, -1),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

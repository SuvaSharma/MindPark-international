import 'package:flutter/material.dart';

class MiniatureGrid extends StatefulWidget {
  final List<Map<String, dynamic>> config;
  final int gridSize;

  MiniatureGrid({
    required this.config,
    required this.gridSize,
  });

  @override
  State<MiniatureGrid> createState() => _MiniatureGridState();
}

class _MiniatureGridState extends State<MiniatureGrid> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the size of each circle based on screen width
    final circleSize =
        screenWidth / (widget.gridSize + 2); // Access widget.gridSize

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridSize, // Access widget.gridSize
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: widget.gridSize * widget.gridSize, // Access widget.gridSize
      itemBuilder: (context, index) {
        int row = index ~/ widget.gridSize; // Access widget.gridSize
        int col = index % widget.gridSize; // Access widget.gridSize
        Color? color;

        for (var filledCircle in widget.config) {
          if (filledCircle['row'] == row && filledCircle['column'] == col) {
            color = filledCircle['color'];
            break;
          }
        }

        return Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            shape: BoxShape.circle,
            border: Border.all(width: 2),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  final Color color;
  final int remainingCount;

  const CircleWidget(
      {Key? key, required this.color, required this.remainingCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize =
        screenWidth * 0.11; // Adjust the size relative to screen width

    return remainingCount > 0
        ? Draggable<Color>(
            data: color,
            feedback: Material(
              type: MaterialType.transparency,
              child: CircleContainer(color: color, size: circleSize),
            ),
            childWhenDragging:
                CircleContainer(color: Colors.grey, size: circleSize),
            child: CircleContainer(color: color, size: circleSize),
            onDragStarted: () {},
            onDragEnd: (details) {},
          )
        : CircleContainer(
            color: Colors.grey,
            size: circleSize); // Display grey circle when count is zero
  }
}

class CircleContainer extends StatelessWidget {
  final Color color;
  final double size;

  const CircleContainer({Key? key, required this.color, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
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
            offset: Offset(-4, -4),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

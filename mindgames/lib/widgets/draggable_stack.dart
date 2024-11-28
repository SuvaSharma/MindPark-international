import 'dart:developer';

import 'package:flutter/material.dart';

class DraggableStack extends StatefulWidget {
  final Function(String) onDragCompleted;
  final Function(String) onImagePlaced;
  final List<String> gridImages; // List of images displayed in the grid
  final int numImages;

  const DraggableStack({
    super.key,
    required this.onDragCompleted,
    required this.onImagePlaced,
    required this.gridImages, // Pass the grid images
    required this.numImages,
  });

  @override
  DraggableStackState createState() => DraggableStackState();
}

class DraggableStackState extends State<DraggableStack> {
  late List<String> _stackImages;

  @override
  void initState() {
    super.initState();
    // Populate the draggable stack using only the grid images
    _stackImages =
        _generateDraggableImages(widget.gridImages, widget.numImages);
    _stackImages.shuffle(); // Shuffle the stack to add randomness
    log('$_stackImages');
  }

  // Function to generate the draggable images from the grid images
  List<String> _generateDraggableImages(List<String> gridImages, int count) {
    List<String> draggableImages = [];
    for (int i = 0; i < count; i++) {
      draggableImages.add(
          gridImages[i % gridImages.length]); // Cycle through the grid images
    }
    return draggableImages;
  }

  void removeImage(String image) {
    setState(() {
      int lastIndex = _stackImages.lastIndexOf(image);
      if (lastIndex != -1) {
        _stackImages.removeAt(lastIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = screenWidth * 0.2;
    final horizontalOffset = screenWidth * 0.02;
    final verticalOffset = screenHeight * 0.02;

    return SizedBox(
      height: screenHeight * 0.3,
      child: Stack(
        children: List.generate(_stackImages.length, (index) {
          final image = _stackImages[index];
          return Positioned(
            left: (index % 5) * (imageSize * 0.03) + horizontalOffset,
            top: (index % 5) * (imageSize * 0.03) + verticalOffset,
            child: Draggable<String>(
              data: image,
              feedback: Image.asset(image, width: imageSize, height: imageSize),
              childWhenDragging: Container(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Image.asset(image, width: imageSize, height: imageSize),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MotorbikeCard extends StatelessWidget {
  final int imageCount;
  final String imagePath;

  const MotorbikeCard({
    Key? key,
    required this.imageCount,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final baseSize = mediaQuery.size.width > mediaQuery.size.height
        ? mediaQuery.size.height
        : mediaQuery.size.width;

    // Container dimensions
    double containerWidth = baseSize * 0.83;
    double containerHeight = baseSize * 0.83;

    // Determine the number of columns and rows based on the image count
    int columns = imageCount == 0
        ? 1
        : (imageCount < 5)
            ? imageCount
            : 5; // Maximum of 5 columns
    int rows = (imageCount / columns).ceil();

    // Calculate the size of each image based on the number of rows and columns
    double imageSize =
        imageCount == 0 ? containerWidth : containerWidth / columns;
    double margin = 4.0;

    // Calculate vertical padding to center the grid vertically if there are fewer rows
    double verticalPadding =
        (containerHeight - (rows * imageSize) - ((rows - 3) * margin)) / 2.2;

    // Ensure the padding is non-negative
    if (verticalPadding < 0) {
      verticalPadding = 0;
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: imageCount == 0
            ? SizedBox()
            : GridView.builder(
                padding: EdgeInsets.all(margin),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns, // Dynamic number of columns
                  mainAxisSpacing: margin,
                  crossAxisSpacing: margin,
                  childAspectRatio: 0.8, // To keep images square
                ),
                itemCount:
                    imageCount, // Only display the actual number of images
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

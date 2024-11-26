import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSlide extends StatelessWidget {
  final List<Map<String, dynamic>> carouselItems;
  final double screenHeight;
  final double screenWidth;
  final Function(int, CarouselPageChangedReason) onPageChanged;
  final int currentIndex;

  const CarouselSlide({
    super.key,
    required this.carouselItems,
    required this.screenHeight,
    required this.screenWidth,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: carouselItems.length,
      itemBuilder: (context, index, realIndex) {
        final item = carouselItems[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => item['navigateTo']),
            );
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: AssetImage(carouselItems[index]['imagePath']),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   width: double.infinity,
                //   height: screenHeight * 0.085,
                //   padding: EdgeInsets.only(top: 6),
                //   decoration: BoxDecoration(
                //     color: Colors.black.withOpacity(0.7),
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(25),
                //       bottomRight: Radius.circular(25),
                //     ),
                //   ),
                //   child: Text(
                //     carouselItems[index]['name'],
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: screenWidth * 0.06,
                //       fontWeight: FontWeight.bold,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                Container(
                  width: double.infinity,
                  height: _getResponsiveHeight(carouselItems[index]['name']),
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(23),
                      bottomRight: Radius.circular(23),
                    ),
                  ),
                  child: Text(
                    carouselItems[index]['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: screenHeight * 0.33,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.77,
        onPageChanged: onPageChanged,
      ),
    );
  }

  double _getResponsiveHeight(String text) {
    double baseHeight = screenHeight * 0.065; // Default height

    // Calculate height based on text length
    int textLength = text.length;

    // For instance, if the text length exceeds a threshold, increase the height
    if (textLength > 21) {
      // Adjust the threshold based on your preference
      return baseHeight * 1.5; // Increase height for longer text
    } else {
      return baseHeight; // Default height for shorter text
    }
  }
}

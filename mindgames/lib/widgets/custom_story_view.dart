import 'package:flutter/material.dart';

class CustomStoryView extends StatelessWidget {
  final List<String> imageUrls;

  const CustomStoryView({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrls[index]),
                fit: BoxFit.cover, // Make the image cover the entire screen
              ),
            ),
          );
        },
      ),
    );
  }
}

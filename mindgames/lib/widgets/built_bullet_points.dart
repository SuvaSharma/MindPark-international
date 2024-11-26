import 'package:flutter/material.dart';

class BuildBulletPoints extends StatelessWidget {
  final List<String> texts;
  final double screenWidth;

  const BuildBulletPoints({
    super.key,
    required this.texts,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: texts.map((text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 9),
                child: Icon(
                  Icons.circle,
                  size: screenWidth * 0.025,
                  color: const Color(0xFF309092),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

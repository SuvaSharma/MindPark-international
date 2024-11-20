import 'package:flutter/material.dart';
import 'package:mindgames/Data/anxiety_text.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';

class AnxietyPage extends StatefulWidget {
  const AnxietyPage({super.key});

  @override
  State<AnxietyPage> createState() => _AnxietyPageState();
}

class _AnxietyPageState extends State<AnxietyPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Dealing With Anxiety',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF309092),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Image.asset('assets/images/anxiety.jpeg'),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: anxietyTexts.map((text) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "Try to find out why your child's feeling anxious.",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF309092),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    "It might be because of:",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF309092),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: BuildBulletPoints(
                  texts: anxietyBulletPoints,
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

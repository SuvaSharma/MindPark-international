import 'package:flutter/material.dart';

class CognitiveTrainingPage extends StatefulWidget {
  const CognitiveTrainingPage({super.key});

  @override
  State<CognitiveTrainingPage> createState() => _CognitiveTrainingPageState();
}

class _CognitiveTrainingPageState extends State<CognitiveTrainingPage> {
  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.07;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image widget goes here
              Image.asset(
                'assets/images/comingsoon.gif',
                width: screenWidth * 0.8,
              ),
              SizedBox(height: 20),
              Text(
                'COMING SOON.........',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mindgames/Data/problem_sleeping_text.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';

class SleepingProblemPage extends StatefulWidget {
  const SleepingProblemPage({super.key});

  @override
  State<SleepingProblemPage> createState() => _SleepingProblemPageState();
}

class _SleepingProblemPageState extends State<SleepingProblemPage> {
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
                  'Problems sleeping',
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
              Image.asset('assets/images/sleeping.jpeg'),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  'Many autistic children find it hard to get to sleep, or wake up several times during the night.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'This may be because of:',
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
                  texts: SleepCauseBulletPoints,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'You can help your child by:',
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
                  texts: SolveBulletPoints,
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

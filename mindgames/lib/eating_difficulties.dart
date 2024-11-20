import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mindgames/Data/eating_difficulty_text.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';
import 'package:url_launcher/url_launcher.dart';

class EatingDifficultiesPage extends StatefulWidget {
  const EatingDifficultiesPage({super.key});

  @override
  State<EatingDifficultiesPage> createState() => _EatingDifficultiesPageState();
}

class _EatingDifficultiesPageState extends State<EatingDifficultiesPage> {
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
                  'Eating difficulties',
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
              Image.asset('assets/images/eating.jpeg'),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'Many children are "fussy eaters"',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF309092),
                    ),
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
                    "Autistic children may:",
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
                  texts: EatingDifficultyBulletPoints,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "If your child has these behaviours, ",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'ShantellSans',
                        ),
                      ),
                      TextSpan(
                        text: "read our advice",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF309092),
                          decoration: TextDecoration.underline,
                          fontFamily: 'ShantellSans',
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            const link =
                                "https://www.autism.org.uk/advice-and-guidance/topics/behaviour/eating/all-audiences";
                            launchUrl(Uri.parse(link),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

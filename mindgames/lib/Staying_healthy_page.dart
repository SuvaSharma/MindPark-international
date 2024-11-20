import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mindgames/Data/staying_healthy_text.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';
import 'package:url_launcher/url_launcher.dart';

class StayingHealthyPage extends StatefulWidget {
  const StayingHealthyPage({super.key});

  @override
  State<StayingHealthyPage> createState() => _StayingHealthyPageState();
}

class _StayingHealthyPageState extends State<StayingHealthyPage> {
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
                'Staying Healthy',
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
            Image.asset('assets/images/healthy.jpeg'),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "It's important that your child has regular check-ups with the:",
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
                texts: StayingHealthyBulletPoints,
                screenWidth: screenWidth,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "Children over 14 who also have a learning disability are entitled to an ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'ShantellSans',
                      ),
                    ),
                    TextSpan(
                      text: "annual health check.",
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
                              "https://www.autism.org.uk/advice-and-guidance/topics/physical-health";
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
      )),
    );
  }
}

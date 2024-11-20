import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mindgames/Data/behaviour_text.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';
import 'package:url_launcher/url_launcher.dart';

class BehaviourPage extends StatefulWidget {
  const BehaviourPage({super.key});

  @override
  State<BehaviourPage> createState() => _BehaviourPageState();
}

class _BehaviourPageState extends State<BehaviourPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: Text(
                "Helping With Your Child's Behaviour",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF309092),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Image.asset('assets/images/behaviour.jpeg'),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Some autistic children have behaviours such as:',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF309092),
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
                texts: BehaviourBulletPoints,
                screenWidth: screenWidth,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                              "https://www.nhs.uk/conditions/autism/autism-and-everyday-life/help-with-behaviour/";
                          launchUrl(Uri.parse(link),
                              mode: LaunchMode.externalApplication);
                        },
                    ),
                  ],
                ),
              ),
            )
          ]),
        )));
  }
}

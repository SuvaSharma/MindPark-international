import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/cognitive_skills_page.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/mathskills.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/verbalskills.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';
import 'package:transparent_image/transparent_image.dart';

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  // List of individual texts for each container
  final List<String> containerTexts = [
    'fine_motors',
    'socials',
    'verbals',
    'maths',
    'cognitives',
    'executives',
  ];

  // List of corresponding pages for each skill
  final List<Widget> pages = const [
    MotorskillsPage(),
    SocialskillsPage(),
    VerbalskillsPage(),
    MathSkillsPage(),
    CognitiveSkillsPage(),
    ExecutiveskillsPage(),
  ];

  // List of corresponding images for each skill
  final List<String> images = [
    'assets/images/motorskills.jpg',
    'assets/images/executiveskills.jpeg',
    'assets/images/socialskills.jpeg',
    'assets/images/verbalskills.jpeg',
    'assets/images/mathskills.jpeg',
    'assets/images/cognitiveskills.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    // Obtain screen size
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.04; // Responsive padding
    final double gridSpacing = size.width * 0.03; // Responsive grid spacing
    final double fontSize = size.width * 0.052; // Responsive font size

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage('assets/images/levelscreen.png'),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    Text(
                      'Help your child with these skills:'.tr,
                      style: TextStyle(
                          fontSize: fontSize * 1.06,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 51, 106, 134)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                        ),
                        itemCount: containerTexts.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pages[index],
                                ),
                              );
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(25),
                              elevation: 15,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 51, 106, 134),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: size.height * 0.05,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(25),
                                            bottomRight: Radius.circular(25)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          containerTexts[index].tr,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 51, 106, 134),
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

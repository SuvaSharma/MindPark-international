import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindgames/language_screen.dart';
import 'package:mindgames/registration_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final LiquidController _liquidController = LiquidController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages(context),
            enableLoop: false,
            fullTransitionValue: 300,
            enableSideReveal: true,
            slideIconWidget: Icon(
              Icons.arrow_back_ios,
              size: 40,
            ),
            waveType: WaveType.liquidReveal,
            positionSlideIcon: 0.5,
            liquidController: _liquidController,
            onPageChangeCallback: (index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
          Positioned(
            top: 30,
            right: 20,
            child: TextButton(
              onPressed: () {
                _completeOnboarding();
              },
              child: Text(
                'Skip',
                style: TextStyle(
                    fontSize: screenHeight * 0.025, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: currentPage,
                count: pages(context).length,
                effect: ExpandingDotsEffect(
                  dotHeight: 6,
                  activeDotColor: Colors.black,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: currentPage == pages(context).length - 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1),
                        ),
                      ),
                      onPressed: () {
                        _completeOnboarding();
                      },
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: screenHeight * 0.025,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_shown', true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Get.off(() => LanguageScreen());
    } else {
      Get.off(() => RegistrationPage());
    }
  }
}

List<Widget> pages(BuildContext context) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;

  return [
    Container(
      width: screenWidth,
      height: screenHeight,
      color: Color.fromARGB(255, 254, 233, 204),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.1),
            child: Image.asset(
              "assets/images/ob1.png",
              height: screenHeight * 0.5,
              width: screenWidth * 0.9,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text.rich(
                TextSpan(
                  text: "Boost Your Child's MindPower \n with ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\nSuperFun',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: ' Activities!',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.white,
      width: screenWidth,
      height: screenHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.1),
            child: Image.asset(
              "assets/images/ob2.png",
              height: screenHeight * 0.4,
              width: screenWidth * 0.9,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text.rich(
                TextSpan(
                  text: "Track Your Child's ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Awesome',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: " Cognitive Growth and Discover ",
                    ),
                    TextSpan(
                      text: 'New Things',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: '!',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Color(0xFFC5EAEA),
      width: screenWidth,
      height: screenHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.1),
            child: Image.asset(
              "assets/images/ob3.png",
              height: screenHeight * 0.4,
              width: screenWidth * 0.8,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text.rich(
                TextSpan(
                  text: "Get ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Cool',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text:
                          " Personalized Insights \n and \n Watch Your Child's Progress ",
                    ),
                    TextSpan(
                      text: 'Shine',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: '!',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  ];
}

import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/tmt_demo_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TMTinfoscreen extends StatefulWidget {
  final String shownWhen;

  const TMTinfoscreen({super.key, required this.shownWhen});

  @override
  State<TMTinfoscreen> createState() => _TMTinfoscreenState();
}

class _TMTinfoscreenState extends State<TMTinfoscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  bool _soundEnabled = true;

  Introduction() {
    // Preload the audio file during app initialization
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      log('right sound pre-initialized'); // Log a message when preloading is complete
    });
  }

  @override
  void initState() {
    super.initState();

    _loadSoundSetting();
    _preloadAudio();
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _preloadAudio() {
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      log('Sound pre-initialized');
    });
  }

  void _playSound(String fileName) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    if (widget.shownWhen == 'in-game') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _goToNextPage() {
    _playSound('Instruction_Swipe.mp3');

    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _playSound('playbutton.mp3');
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TMTDemoPage()),
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _playSound('Instruction_Swipe.mp3');
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      if (widget.shownWhen == 'before-game') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MotorskillsPage()));
      } else {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildOnboardingPage(
      String imagePath, String title, String centerText, String imageUrl) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              height: screenHeight *
                  0.1), // Add some space between the top of the screen and the text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                key: ValueKey<String>(title),
                style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.1),
          Image.asset(
            imageUrl,
            width: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.1),
          Center(
            child: Text(
              centerText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.025),
          topRight: Radius.circular(screenWidth * 0.025),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.05, horizontal: screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.shownWhen == 'before-game' && _currentPage >= 0)
              Material(
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.1),
                ),
                child: ElevatedButton(
                  onPressed: _goToPreviousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 15, // Remove button elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back,
                          color: Colors.black, size: screenWidth * 0.05),
                      const SizedBox(width: 8),
                      Text(
                        'Back'.tr,
                        style: TextStyle(
                            fontSize: screenWidth * 0.05, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.shownWhen == 'before-game')
              ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 15, // Remove button elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentPage == 1 ? 'Try Now'.tr : 'Next'.tr,
                      style: TextStyle(
                          fontSize: screenWidth * 0.05, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward,
                        color: Colors.black, size: screenWidth * 0.05),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ]);

          return Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  _playSound('Instruction_Swipe.mp3');

                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildOnboardingPage(
                      'assets/images/homepage.png',
                      'How To Play'.tr,
                      'In Part A, tap the numbers in this order: 1 → 2 → 3 → 4 → 5 → 6 and so on'
                          .tr,
                      'assets/images/tmtinfo.gif'),
                  _buildOnboardingPage(
                      'assets/images/homepage.png',
                      'How To Play'.tr,
                      'In Part B, tap the numbers in this order: 1 → A → 2 → B → 3 → C and so on'
                          .tr,
                      'assets/images/tmt2info.gif'),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomBar(),
              ),
            ],
          );
        },
      ),
    );
  }
}

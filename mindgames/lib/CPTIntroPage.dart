import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/CPTdemopage.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CPTIntroPage extends StatefulWidget {
  final String shownWhen;
  const CPTIntroPage({super.key, required this.shownWhen});

  @override
  State<CPTIntroPage> createState() => _CPTIntroPageState();
}

class _CPTIntroPageState extends State<CPTIntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  bool _soundEnabled = true;

  CPTIntroPage() {
    // Preload the audio file during app initialization
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      log('Sound pre-initialized'); // Log a message when preloading is complete
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
  }

  void _goToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CPTdemoPage()),
    );
  }

  void _goToPreviousPage() {
    if (widget.shownWhen == 'before-game') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ExecutiveskillsPage()));
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildCPTIntroPage(String imagePath, String instructionImage,
      String title, String centerText) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    title,
                    key: ValueKey<String>(title),
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Image.asset(
                  instructionImage,
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.5,
                  scale: 0.4,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  centerText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            if (widget.shownWhen == 'before-game' && _currentPage == 0)
              ElevatedButton(
                onPressed: _goToPreviousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
            if (widget.shownWhen == 'before-game')
              ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentPage == 0 ? 'Try Now'.tr : 'Play',
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExecutiveskillsPage()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
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
                _buildCPTIntroPage(
                  'assets/images/homepage.png',
                  'assets/images/cpt-intro.gif',
                  'How To Play'.tr,
                  "Press the buzzer for every letter except \"X\".".tr,
                ),
              ],
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.4,
              right: MediaQuery.of(context).size.width * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.1,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 1,
                effect: WormEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.5),
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/ERTdemopage.dart';
import 'package:mindgames/socialskills.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ERTInfoScreen extends StatefulWidget {
  final String shownWhen;

  const ERTInfoScreen({super.key, required this.shownWhen});

  @override
  _ERTInfoScreenState createState() => _ERTInfoScreenState();
}

class _ERTInfoScreenState extends State<ERTInfoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final player = AudioPlayer();
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _playSound(String fileName) {
    if (_soundEnabled) {
      player.play(AssetSource('Instruction_Swipe.mp3'));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _playSound('playbutton.mp3');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ERTdemo()),
    );
  }

  void _goToPreviousPage() {
    if (widget.shownWhen == 'before-game') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SocialskillsPage()));
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildOnboardingPage(String imagePath, String instructionImage,
      String title, String centerText) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                title,
                key: ValueKey<String>(title),
                style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 45),
            Image.asset(
              instructionImage,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            Text(
              centerText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
          MaterialPageRoute(builder: (context) => const SocialskillsPage()),
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
                _buildOnboardingPage(
                  'assets/images/homepage.png',
                  'assets/images/ertins.gif',
                  'How To Play'.tr,
                  'Tap on how the person in the picture feels!'.tr,
                ),
              ],
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.4,
              right: MediaQuery.of(context).size.width * 0.1,
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

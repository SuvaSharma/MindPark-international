import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mindgames/Level8demopage.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Introduction extends StatefulWidget {
  final String shownWhen;
  const Introduction({super.key, required this.shownWhen});

  @override
  _IntroductionState createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  bool _soundEnabled = true;

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
      print('Sound pre-initialized');
    });
  }

  void _playSound(String fileName) {
    if (_soundEnabled) {
      player.play(AssetSource('Instruction_swipe.mp3'));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    if (widget.shownWhen == 'in-game') {
      print('switching dispose landscape');
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _goToNextPage() {
    _playSound('playbutton.mp3');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Level8demo()),
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
          SizedBox(height: screenHeight * 0.1),
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
          SizedBox(height: screenHeight * 0.1),
          Image.asset(
            imageUrl,
            width: screenWidth,
            scale: 0.5,
          ),
          SizedBox(height: screenWidth * 0.1),
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
            if (widget.shownWhen == 'before-game' && _currentPage == 0)
              Material(
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.1),
                ),
                child: ElevatedButton(
                  onPressed: _goToPreviousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 15,
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
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentPage == 0 ? 'Try Now'.tr : 'Play'.tr,
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
          print('switching info build portrait');
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
                      'Match the symbols with numbers'.tr,
                      'assets/images/sdmt-intro.gif'),
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

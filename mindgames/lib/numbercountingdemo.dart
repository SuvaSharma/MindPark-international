import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/mathskills.dart';
import 'package:mindgames/number_counting_game.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/image_card.dart';
import 'package:mindgames/widgets/number_options.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/widgets/skipbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class NumberCountingDemoPage extends StatefulWidget {
  const NumberCountingDemoPage({super.key});

  @override
  State<NumberCountingDemoPage> createState() => _NumberCountingDemoPageState();
}

class _NumberCountingDemoPageState extends State<NumberCountingDemoPage> {
  int _imageCount = 0;
  int _selectedNumber = -1;
  final Random _random = Random();
  int _roundsPlayed = 0;
  String? _feedbackImagePath;
  bool _showFeedback = false;
  bool _showGame = false;
  bool _isPaused = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _generateNewImageCount();
    _preloadAudio();
  }

  /// Load sound and vibration settings
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true; // Default: true
      _vibrationEnabled =
          prefs.getBool('vibration_enabled') ?? false; // Default: false
    });
  }

  /// Preload all audio files
  void _preloadAudio() {
    _audioCache.loadAll([
      'correct.mp3',
      'wrong.mp3',
      'GameOverDialog.mp3',
      'PauseTap.mp3',
      'playbutton.mp3',
    ]);
  }

  /// Play a sound if sound is enabled
  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      SoundManager.playSound(fileName);
    }
  }

  /// Generate a new image count
  void _generateNewImageCount() {
    if (_roundsPlayed >= 2) {
      _showCongratsDialog();
      _playSound('GameOverDialog.mp3', player1);
    } else {
      setState(() {
        _imageCount = _random.nextInt(16) + 5;
        _selectedNumber = -1;
        _showFeedback = false;
      });
    }
  }

  /// Handle number selection
  void _onNumberSelected(int number) {
    setState(() {
      _feedbackImagePath = number == _imageCount
          ? 'assets/images/25.png'
          : 'assets/images/54.png';
      _showFeedback = true;

      if (number == _imageCount) {
        if (_vibrationEnabled) {
          Vibration.vibrate(duration: 100, amplitude: 10);
        }
        _playSound('correct.mp3', player1);
      } else {
        _playSound('wrong.mp3', player2);
      }

      _roundsPlayed++;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_roundsPlayed < 2) {
        setState(() {
          _showFeedback = false;
          _generateNewImageCount();
        });
      } else {
        _showCongratsDialog();
      }
    });
  }

  /// Show the congratulatory dialog
  Future<void> _showCongratsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const NumberCountingGame()),
            );
          },
        );
      },
    );
  }

  /// Start the game
  void _startGame() {
    setState(() {
      _showGame = true;
    });
  }

  /// Pause the game
  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _showPauseMenu();
  }

  /// Show the pause menu
  void _showPauseMenu() {
    _playSound('PauseTap.mp3', player1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PauseMenu(
          onResume: () {
            Navigator.of(context).pop();
            setState(() {
              _isPaused = false;
            });
          },
          onQuit: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MathSkillsPage()),
            );
          },
          quitDestinationPage: const MathSkillsPage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

    return WillPopScope(
      onWillPop: () async {
        if (_showGame) {
          _pauseGame();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MathSkillsPage()),
          );
        }
        return false;
      },
      child: Scaffold(
        body: Stack(children: [
          Image.asset(
            'assets/images/balloon_background.jpeg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          !_showGame
              ? SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: baseSize * 0.05,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Welcome to".tr,
                                style: TextStyle(
                                  fontSize: baseSize * 0.06,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Counting Castle".tr,
                                style: TextStyle(
                                  fontSize: baseSize * 0.07,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: baseSize * 0.03),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius:
                                        BorderRadius.circular(baseSize * 0.05),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(baseSize * 0.05),
                                    child: Image.asset(
                                      'assets/images/numberscounting.jpeg',
                                      width: baseSize * 0.6,
                                      height: baseSize * 0.6,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: baseSize * 0.03),
                                child: AnimatedButton(
                                  height: baseSize * 0.15,
                                  width: baseSize * 0.5,
                                  color: Colors.blue,
                                  onPressed: () {
                                    _playSound('playbutton.mp3', player);

                                    // Start the game
                                    _startGame();
                                  },
                                  child: Text('Start Trial'.tr,
                                      style: TextStyle(
                                        fontSize: baseSize * 0.06,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: baseSize * 0.03),
                                child: AnimatedButton(
                                  height: baseSize * 0.15,
                                  width: baseSize * 0.5,
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NumberCountingGame()));
                                  },
                                  child: Text('Skip Trial'.tr,
                                      style: TextStyle(
                                          fontSize: baseSize * 0.06,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[200])),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: _showGame
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!_showFeedback && !_isPaused)
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isPaused =
                                              true; // Trigger the pause menu
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Material(
                                            elevation: 10,
                                            borderRadius: BorderRadius.circular(
                                                baseSize * 0.03),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        baseSize * 0.03),
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.pause),
                                                iconSize: baseSize * 0.07,
                                                onPressed: _showPauseMenu,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: baseSize * 0.02),
                                    Container(
                                      width: baseSize * 0.87,
                                      height: baseSize * 1.27,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.black, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(3, 3),
                                          ),
                                        ],
                                      ),
                                      child: MotorbikeCard(
                                        imageCount: _imageCount,
                                        imagePath:
                                            'assets/images/motorbike.png',
                                      ),
                                    ),
                                    SizedBox(height: baseSize * 0.10),
                                    NumberOptions(
                                      size: baseSize * 0.19,
                                      correctNumber: _imageCount,
                                      onNumberSelected: _onNumberSelected,
                                    ),
                                    SizedBox(height: baseSize * 0.05),
                                  ],
                                ),
                              if (_showFeedback && _feedbackImagePath != null)
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.16),
                                    child: Image.asset(
                                      _feedbackImagePath!,
                                      width: baseSize * 0.8,
                                      height: baseSize * 0.8,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SkipButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NumberCountingGame()),
                                  );
                                },
                                height: screenHeight * 0.05,
                                width: screenWidth * 0.19,
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  'Counting Castle Demo',
                                  style: TextStyle(
                                    fontSize: baseSize * 0.09,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: baseSize * 0.05),
                              GestureDetector(
                                onTap: () async {},
                                child: Container(
                                  width: mediaQuery.size.width * 0.3,
                                  height: mediaQuery.size.width * 0.15,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          'assets/images/Play.png',
                                          fit: BoxFit.cover,
                                          width: mediaQuery.size.width * 0.3,
                                          height: mediaQuery.size.width * 0.15,
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: mediaQuery.size.height *
                                                  0.01),
                                          child: Text(
                                            "Start",
                                            style: TextStyle(
                                              fontSize:
                                                  mediaQuery.size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
        ]),
      ),
    );
  }
}

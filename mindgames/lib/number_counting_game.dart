import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/mathskills.dart';
import 'package:mindgames/models/number_counting_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/image_card.dart';
import 'package:mindgames/widgets/number_options.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart'; // Import your pause menu widget

class NumberCountingGame extends ConsumerStatefulWidget {
  const NumberCountingGame({super.key});

  @override
  ConsumerState<NumberCountingGame> createState() => _NumberCountingGameState();
}

class _NumberCountingGameState extends ConsumerState<NumberCountingGame> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  int _imageCount = 0;
  int itemCount = 0;

  int score = 0;
  final math.Random _random = math.Random();
  int _roundsPlayed = 0;
  String? _feedbackImagePath;
  bool _showFeedback = false;
  bool _showGame = false;
  bool _isPaused = false; // Flag to control the display of the pause menu
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  int numberOfRounds = 5;
  late Difficulty _selectedDifficulty;

  final List<String> _imagePaths = [
    'assets/images/motorbike.png',
    'assets/images/boat.png',
    'assets/images/flower.png',
    'assets/images/car.png',
    'assets/images/animals/bat.png'
  ];
  String selectedImagePath = 'assets/images/motorbike.png';

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
    _loadSettings().then((_) {
      final selectedChild = ref.read(selectedChildDataProvider);
      selectedChildUserId = selectedChild!.childId;
      _preloadAudio();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDifficultyDialog();
      });
    });
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true; // Default: true
      // Update SoundManager with the new sound setting
      SoundManager.isSoundEnabled = _soundEnabled;
      _vibrationEnabled =
          prefs.getBool('vibration_enabled') ?? false; // Default: false
    });
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  void _preloadAudio() {
    _audioCache.loadAll([
      'correct.mp3',
      'wrong.mp3',
      'GameOverDialog.mp3',
      'PauseTap.mp3',
      'playbutton.mp3',
      'bounce.mp3'
    ]);
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
  }

  void _showDifficultyDialog() {
    _playSound('bounce.mp3', player);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: DifficultyDialog(
            onDifficultySelected: (Difficulty difficulty) {
              _startGameWithDifficulty(difficulty);
              _generateNewImageCount();
            },
            onBackPressed: () {},
          ),
        );
      },
    );
  }

  void _startGameWithDifficulty(Difficulty difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _showGame = true;
    });
    _setGameParameters(_selectedDifficulty);
    _playSound('playbutton.mp3', player);
  }

  void _setGameParameters(Difficulty difficulty) {
    setState(() {
      if (difficulty == Difficulty.easy) {
        itemCount = 0;
        numberOfRounds = 7;
      } else if (difficulty == Difficulty.medium) {
        itemCount = 10;
        numberOfRounds = 14;
      } else if (difficulty == Difficulty.hard) {
        itemCount = 20;
        numberOfRounds = 20;
      }
    });
  }

  void storeData() {
    double accuracy = score / numberOfRounds * 100;
    cloudStoreService.addNumberCountingData(NumberCountingModel(
        userId: selectedChildUserId,
        level: 'Number Counting',
        difficulty: _selectedDifficulty,
        sessionId: sessionId,
        accuracy: accuracy,
        score: score));
  }

  void _generateNewImageCount() {
    setState(() {
      _imageCount = itemCount + math.Random().nextInt(11);

      _showFeedback = false;
      selectedImagePath = _imagePaths[_random.nextInt(_imagePaths.length)];
    });
  }

  void _onNumberSelected(int number) async {
    setState(() {
      _feedbackImagePath = number == _imageCount
          ? 'assets/images/25.png'
          : 'assets/images/54.png';
      _showFeedback = true;

      // Play sound based on feedback
      if (number == _imageCount) {
        setState(() {
          score += 1;
          _roundsPlayed++;
        });
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }

        // Check if sound is enabled

        _playSound('right.mp3', player1); // Play the sound only if enabled
      } else {
        // Check if sound is enabled for the "wrong" sound

        _playSound('wrong.mp3', player);

        setState(() {
          _roundsPlayed++; // Increment the number of rounds played
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_roundsPlayed < numberOfRounds) {
        log('number of rounds played: $_roundsPlayed');
        setState(() {
          _showFeedback = false;
          _generateNewImageCount();
        });
      } else {
        storeData();
        _showCongratsDialog();
        // Show the congratulatory dialog after 20 rounds
      }
    });
  }

  Future<void> _showCongratsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MathSkillsPage()));
            setState(() {
              _isPaused = false;
            });
          },
        );
      },
    );
  }

  void _startGame() {
    setState(() {
      _showGame = true;
    });
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _showPauseMenu();
  }

  void _showPauseMenu() {
    _playSound('PauseTap.mp3', player);
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
          onQuit: () {},
          quitDestinationPage: const MathSkillsPage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final baseSize = mediaQuery.size.width > mediaQuery.size.height
        ? mediaQuery.size.height
        : mediaQuery.size.width;

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
          if (_showGame)
            SafeArea(
              child: SingleChildScrollView(
                  child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_showFeedback && !_isPaused)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPaused = true; // Trigger the pause menu
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Material(
                                elevation: 10,
                                borderRadius:
                                    BorderRadius.circular(baseSize * 0.03),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(baseSize * 0.03),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.pause),
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
                            border: Border.all(color: Colors.black, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: MotorbikeCard(
                              imageCount: _imageCount,
                              imagePath: selectedImagePath),
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
                            top: MediaQuery.of(context).size.height * 0.16),
                        child: Image.asset(
                          _feedbackImagePath!,
                          width: baseSize * 0.8,
                          height: baseSize * 0.8,
                        ),
                      ),
                    ),
                ],
              )),
            ),
        ]),
      ),
    );
  }
}

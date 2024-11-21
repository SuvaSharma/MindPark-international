import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/gaze_maze_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class GazeMazePage extends ConsumerStatefulWidget {
  const GazeMazePage({super.key});

  @override
  ConsumerState<GazeMazePage> createState() => _GazeMazePageState();
}

class _GazeMazePageState extends ConsumerState<GazeMazePage> {
  int timeLimit = 0; // Time limit for growing animation
  int shrinkTime = 5;
  int timeRemaining = 0;
  int shrinkTimeRemaining = 0;
  bool _isPaused = false;
  final AudioPlayer player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  double promptTextOpacity = 1.0;
  double lookAwayOpacity = 0.0;
  Timer? timer;
  Timer? shrinkTimer;
  int cycleCount = 0;
  int totalCycles = 5;

  double containerSize = 0.25;
  final double minContainerSize = 0.25;
  final double maxContainerSize = 0.5;
  String growState = "";

  List<Map<String, dynamic>> gameData = [];
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  int score = 0;
  bool isButtonVisible = false;
  bool _showGame = false;
  late Difficulty _selectedDifficulty;
  bool _vibrationEnabled = false;

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();

    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultyDialog();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    shrinkTimer?.cancel();
    player.dispose();
    player1.dispose();
    super.dispose();
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
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
              gameFlow();
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
        timeLimit = 3;
        shrinkTime = 5;
      } else if (difficulty == Difficulty.medium) {
        timeLimit = 5;
        shrinkTime = 5;
      } else if (difficulty == Difficulty.hard) {
        timeLimit = 8;
        shrinkTime = 5;
      }
      timeRemaining = timeLimit;
      shrinkTimeRemaining = shrinkTime;
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    player.play(AssetSource(fileName));
  }

  Future<bool> _onBackPressed() async {
    _playSound('PauseTap.mp3', player1);
    bool? result;

    Future<bool?> displayPauseMenu() async {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: PauseMenu(
            onResume: () {
              print("Resumed");
              Navigator.pop(context, false);
            },
            onQuit: () {
              storeData();
            },
            quitDestinationPage: const SocialskillsPage(),
          ),
        ),
      );
    }

    setState(() {
      _isPaused = true;
    });
    result = await displayPauseMenu();
    setState(() {
      _isPaused = false;
    });

    return result ?? false;
  }

  void gameFlow() {
    _playSound('look_in.mp3', player);
    disappearText();
  }

  void disappearText() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      promptTextOpacity = 0.0;
      isButtonVisible = true;
    });
    startTimer();
  }

  void startTimer() async {
    if (_vibrationEnabled) {
      Vibration.vibrate(
        duration: 100,
        amplitude: 10,
      );
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        if (timeRemaining > 0) {
          animateContainer("growing");
          _playSound('clock_tick.mp3', player);
          setState(() {
            timeRemaining -= 1;
          });
        } else {
          gameData.add({
            "cycleNumber": cycleCount,
            "stareDuration": timeLimit,
          });
          setState(() {
            score += 1;
            isButtonVisible = false;
          });
          _playSound('look_away.mp3', player);
          _playSound('task_completed.mp3', player1);
          timer?.cancel();
          shrinkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            print("I shrink every second");
            if (!_isPaused) {
              if (shrinkTimeRemaining > 0) {
                animateContainer("shrinking");
                setState(() {
                  shrinkTimeRemaining -= 1;
                  lookAwayOpacity = 1.0;
                });
              } else {
                shrinkTimer?.cancel();
                showAndHideLookAway();
              }
            }
          });
        }
      }
    });
  }

  void animateContainer(String grow) {
    setState(() {
      growState = grow;
      if (grow == "growing") {
        containerSize += (maxContainerSize - minContainerSize) / timeLimit;
        print("Container size: $containerSize");
      } else if (grow == "shrinking") {
        containerSize -= (maxContainerSize - minContainerSize) / shrinkTime;
        print("Container size: $containerSize");
      } else if (grow == "reset") {
        containerSize = minContainerSize;
        print("Container size: $containerSize");
      }
    });
  }

  void showAndHideLookAway() async {
    print("show and hide look away");
    setState(() {
      lookAwayOpacity = 1.0;
    });

    setState(() {
      lookAwayOpacity = 0.0;
      cycleCount += 1;
    });

    if (cycleCount < totalCycles) {
      setState(() {
        timeRemaining = timeLimit;
        shrinkTimeRemaining = shrinkTime;
        promptTextOpacity = 1.0;
      });
      gameFlow();
    } else {
      // all cycles were completed
      await Future.delayed(const Duration(milliseconds: 10));
      _isPaused = true;
      showCongratsDialog();
      storeData();
    }
  }

  void showCongratsDialog() async {
    _playSound('yahoo.mp3', player);
    _playSound('GameOverDialog.mp3', player1);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SocialskillsPage()));
            setState(() {
              // You can reset the state here if needed.
            });
          },
        );
      },
    );
  }

  void skipCycle() async {
    // timer cancels
    timer?.cancel();
    //

    gameData.add({
      "cycleNumber": cycleCount,
      "stareDuration": timeLimit - timeRemaining,
    });
    setState(() {
      cycleCount += 1;
    });

    animateContainer("reset");

    if (cycleCount < totalCycles) {
      setState(() {
        timeRemaining = timeLimit;
        promptTextOpacity = 1.0;
        isButtonVisible = false;
      });
      gameFlow();
    } else {
      // all cycles were completed
      _isPaused = true;
      showCongratsDialog();
      storeData();
    }
  }

  void storeData() async {
    if (gameData.isNotEmpty) {
      double averageStareTime =
          gameData.map((map) => map["stareDuration"]!).reduce((a, b) => a + b) /
              gameData.length;
      double accuracy =
          double.parse((averageStareTime / timeLimit * 100).toStringAsFixed(2));
      cloudStoreService.addGazeMazeData(GazeMazeModel(
        userId: selectedChildUserId,
        sessionId: sessionId,
        level: "Gaze Maze",
        difficulty: _selectedDifficulty,
        score: score,
        averageStareTime: averageStareTime,
        accuracy: accuracy,
        gameData: gameData,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            if (_showGame)
              SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        right: screenWidth * 0.02,
                      ),
                      child: GestureDetector(
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
                                  icon: Icon(Icons.pause),
                                  iconSize: baseSize * 0.07,
                                  onPressed: _onBackPressed,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Image.asset(
                          lookAwayOpacity == 1.0
                              ? 'assets/images/side_look.png'
                              : 'assets/images/look_in.png',
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.35,
                        ),
                        Stack(
                          children: [
                            Center(
                              child: AnimatedOpacity(
                                opacity: promptTextOpacity,
                                duration: const Duration(seconds: 1),
                                child: Text(
                                  'Look each other in the eyes!'.tr,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: AnimatedOpacity(
                                opacity: lookAwayOpacity,
                                duration: const Duration(milliseconds: 1),
                                child: Text(
                                  'Look away gently!'.tr,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: screenWidth * 0.505,
                            width: screenWidth * 0.505,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // circular bar
                                CircularProgressIndicator(
                                  strokeWidth: screenWidth * 0.006,
                                  value: cycleCount / totalCycles,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.blue[400]),
                                  backgroundColor: Colors.blue[100],
                                ),

                                Center(
                                  child: AnimatedContainer(
                                    duration: growState == "growing"
                                        ? const Duration(seconds: 1)
                                        : growState == "shrinking"
                                            ? const Duration(seconds: 1)
                                            : const Duration(seconds: 0),
                                    height: screenWidth * containerSize,
                                    width: screenWidth * containerSize,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100]?.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blue[300],
                                        shape: BoxShape.circle),
                                    height: screenWidth * 0.25,
                                    width: screenWidth * 0.25,
                                    child: Center(
                                      child: timeRemaining == 0
                                          ? Icon(
                                              Icons.done,
                                              color: Colors.white,
                                              size: screenWidth * 0.2,
                                            )
                                          : Text(
                                              '$timeRemaining',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.1,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Visibility(
                          visible: isButtonVisible,
                          child: AnimatedButton(
                            color: Colors.blue,
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.08,
                            onPressed: skipCycle,
                            child: Text('Child looked away!'.tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/gaze_maze_page.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/disclaimer_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class GazeMazeDemoPage extends ConsumerStatefulWidget {
  const GazeMazeDemoPage({super.key});

  @override
  ConsumerState<GazeMazeDemoPage> createState() => _GazeMazeDemoPageState();
}

class _GazeMazeDemoPageState extends ConsumerState<GazeMazeDemoPage> {
  int timeLimit = 3;
  int shrinkTime = 5;
  int timeRemaining = 3;
  int shrinkTimeRemaining = 5;
  bool _isPaused = false;
  final AudioPlayer player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  double promptTextOpacity = 1.0;
  double lookAwayOpacity = 0.0;
  Timer? timer;
  Timer? shrinkTimer;
  int cycleCount = 0;
  int totalCycles = 2;

  double containerSize = 0.25;
  final double minContainerSize = 0.25;
  final double maxContainerSize = 0.5;
  String growState = "";

  bool isButtonVisible = false;
  bool _showGame = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  void initState() {
    super.initState();

    _loadSoundSetting();
    _loadVibrationSetting();
    _playSound('playbutton.mp3', player);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
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

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  void _showDisclaimerDialog() {
    _playSound('bounce.mp3', player);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DisclaimerDialog(
          onConfirmation: () {
            Navigator.pop(context);
          },
        );
      },
    );
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
            onQuit: () {},
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
    setState(() {
      _showGame = true;
    });
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
          setState(() {
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const GazeMazePage()));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: () async {
        if (_showGame) {
          bool result = await _onBackPressed();
          return result;
        } else {
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SocialskillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
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
                                  "Gaze Maze".tr,
                                  style: TextStyle(
                                    fontSize: baseSize * 0.07,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: baseSize * 0.03),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          baseSize * 0.05),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          baseSize * 0.05),
                                      child: Image.asset(
                                        'assets/images/gaze-maze.jpeg',
                                        width: baseSize * 0.6,
                                        height: baseSize * 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: baseSize * 0.03),
                                  child: AnimatedButton(
                                    height: baseSize * 0.15,
                                    width: baseSize * 0.5,
                                    color: Colors.blue,
                                    onPressed: () {
                                      gameFlow();
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
                                  padding:
                                      EdgeInsets.only(top: baseSize * 0.03),
                                  child: AnimatedButton(
                                    height: baseSize * 0.15,
                                    width: baseSize * 0.5,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const GazeMazePage()));
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
                                      borderRadius: BorderRadius.circular(
                                          baseSize * 0.03),
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
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.blue[400]),
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
                                          color: Colors.blue[100]
                                              ?.withOpacity(0.8),
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

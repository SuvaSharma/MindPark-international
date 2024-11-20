import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/config/miniature_grid_config.dart';
import 'package:mindgames/config/miniature_grid_demo.dart';
import 'package:mindgames/lego_game.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/circle_widget.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/gameover_dialog.dart';
import 'package:mindgames/widgets/miniature_grid.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/widgets/skipbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class LogiGameDemoPage extends StatefulWidget {
  const LogiGameDemoPage({super.key});

  @override
  State<LogiGameDemoPage> createState() => _LogiGameDemoPageState();
}

class _LogiGameDemoPageState extends State<LogiGameDemoPage> {
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  int gridSize = 7;

  List<Color?> gridColors = List.filled(49, Colors.white);
  List<bool> isIncorrectPlacement = List.filled(49, false);
  int correctPlacements = 0;
  final int totalColoredCircles = DemofilledCircles.length;
  Timer? _timer; // Make _timer nullable
  int _seconds = 0; // Stopwatch in milliseconds
  DateTime? _startTime;
  double accuracy = 0;
  final AudioCache _audioCache = AudioCache();
  final AudioPlayer player = AudioPlayer();
  bool _showGame = false;
  bool _isPaused = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  Map<Color, int> remainingCirclesCount = {
    Colors.blue: 10,
    Colors.red: 10,
    Colors.green: 10,
    Colors.black: 10,
    Colors.orange: 10,
  };
  List<Color> miniatureGrid =
      List<Color>.filled(49, Colors.white, growable: false);
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVibrationSetting();
    createMiniatureGridList();
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

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    player.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showGame = true;
    });
    _startStopwatch();
  }

  void createMiniatureGridList() {
    for (int i = 0; i < 49; i++) {
      int row = i ~/ 7;
      int col = i % 7;

      for (var filledCircle in DemofilledCircles) {
        if (filledCircle['row'] == row && filledCircle['column'] == col) {
          miniatureGrid[i] = filledCircle['color'];
        }
      }
    }
    print(miniatureGrid);
  }

  void _startStopwatch() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (!_isPaused) {
          _seconds++;
        }
      });
    });
  }

  void _stopStopwatch() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  void _resetGame() {
    setState(() {
      _seconds = 0;
      correctPlacements = 0;
      gridColors = List.filled(49, Colors.white);
      isIncorrectPlacement = List.filled(49, false);
      remainingCirclesCount = {
        Colors.blue: 10,
        Colors.red: 10,
        Colors.green: 10,
        Colors.black: 10,
        Colors.orange: 10,
      };
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
  }

  void checkCorrectPlacement(int index, Color newColor) {
    int row = index ~/ gridSize;
    int col = index % gridSize;
    bool isCorrect = false;

    if (gridColors[index] != Colors.white &&
        gridColors[index] != null &&
        !isIncorrectPlacement[index]) {
      return;
    }

    // checks to see if any placement matches any of the filled circles
    for (var filledCircle in filledCircles) {
      if (filledCircle['row'] == row &&
          filledCircle['column'] == col &&
          filledCircle['color'] == newColor) {
        isCorrect = true;
        break;
      }
    }

    setState(() {
      gridColors[index] = newColor;
    });

    // if correct, increse the counter and lock the placement
    if (isCorrect) {
      if (_vibrationEnabled) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 10,
        );
      }
      setState(() {
        correctPlacements++;
        isIncorrectPlacement[index] = false;

        // officially locked!
      });

      if (correctPlacements == totalColoredCircles) {
        _stopStopwatch();
        calculateAccuracy();
        _showCongratsDialog();
      }
    } else {
      // If incorrect just mark it out!
      setState(() {
        isIncorrectPlacement[index] = true;
      });
    }
  }

  void calculateAccuracy() {
    int correctTiles = 0;
    for (int i = 0; i < 49; i++) {
      if (miniatureGrid[i] == gridColors[i]) {
        correctTiles += 1;
      }
    }

    setState(() {
      accuracy = (correctTiles / 49 * 100).toPrecision(2);
      print(accuracy);
    });
  }

  void _showCongratsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const LegoGame()), // Navigate back to LegoGame
            );
          },
        );
      },
    );
  }

  Future<bool> _onBackPressed() async {
    _playSound('PauseTap.mp3', player);

    bool? result;

    Future<bool?> displayPauseMenu() async {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: PauseMenu(
            onResume: () {
              Navigator.pop(context, false);
              _resumeGame();
            },
            onQuit: () {},
            quitDestinationPage: MotorskillsPage(),
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

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    double progress = correctPlacements / totalColoredCircles;

    if (!_showGame) {
      return WillPopScope(
        onWillPop: () async {
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MotorskillsPage()),
          );
          return false; // Prevents the default back button action
        },
        child: Scaffold(
          body: Stack(
            children: [
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
                                    "Pixel Puzzle".tr,
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
                                          'assets/images/pixel_puzzle.jpeg',
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
                                                    const LegoGame()));
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
                      child: Column(
                        children: [
                          SkipButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LegoGame()),
                              );
                            },
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.19,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Pixel Puzzle Demo'.tr,
                              style: TextStyle(
                                fontSize: baseSize * 0.1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: baseSize * 0.05),
                          GestureDetector(
                            onTap: () {
                              _playSound('playbutton.mp3', player);
                              _startGame();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        'assets/images/Play.png',
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        child: Text(
                                          "Start".tr,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: Stack(children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Time: ${_seconds} s',
                              style: TextStyle(
                                fontSize: baseSize * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
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
                                    icon: Icon(Icons.pause),
                                    iconSize: baseSize * 0.07,
                                    onPressed: _onBackPressed,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: baseSize * 0.02),
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(baseSize * 0.03),
                      child: Container(
                        width: screenWidth * 0.42,
                        height: screenWidth * 0.42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(baseSize * 0.03),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(baseSize * 0.02),
                          child: MiniatureGrid(
                            config: DemofilledCircles,
                            gridSize: gridSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize * 0.07),
                    Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.44,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: baseSize * 0.01,
                          mainAxisSpacing: baseSize * 0.01,
                        ),
                        itemCount: 49,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (isIncorrectPlacement[index]) {
                                setState(() {
                                  if (gridColors[index] != null) {
                                    remainingCirclesCount[gridColors[
                                        index]!] = (remainingCirclesCount[
                                                gridColors[index]] ??
                                            0) +
                                        1; // Increment remaining circles count
                                    gridColors[index] = Colors.white;
                                    isIncorrectPlacement[index] = false;
                                  }
                                });
                              }
                            },
                            child: DragTarget<Color>(
                              onWillAccept: (color) {
                                return gridColors[index] == Colors.white ||
                                    gridColors[index] != color;
                              },
                              onAccept: (color) {
                                setState(() {
                                  checkCorrectPlacement(index, color);
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: gridColors[index],
                                    shape: BoxShape.circle,
                                    border: Border.all(width: baseSize * 0.01),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: baseSize * 0.038),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleWidget(
                              color: Colors.blue,
                              remainingCount:
                                  remainingCirclesCount[Colors.blue] ?? 0),
                          CircleWidget(
                              color: Colors.red,
                              remainingCount:
                                  remainingCirclesCount[Colors.red] ?? 0),
                          CircleWidget(
                              color: Colors.green,
                              remainingCount:
                                  remainingCirclesCount[Colors.green] ?? 0),
                          CircleWidget(
                              color: Colors.black,
                              remainingCount:
                                  remainingCirclesCount[Colors.black] ?? 0),
                          CircleWidget(
                              color: Colors.orange,
                              remainingCount:
                                  remainingCirclesCount[Colors.orange] ?? 0),
                        ],
                      ),
                    ),
                    SizedBox(height: baseSize * 0.07),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: baseSize * 0.18,
                          height: baseSize * 0.18,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: baseSize * 0.02,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Text(
                          '$correctPlacements/$totalColoredCircles',
                          style: TextStyle(
                            fontSize: baseSize * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}

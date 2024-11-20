import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/config/easy_lego_config.dart';
import 'package:mindgames/config/hard_lego_config.dart';
import 'package:mindgames/config/medium_lego_config.dart';
import 'package:mindgames/models/LegoGameData.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'widgets/circle_widget.dart';
import 'widgets/miniature_grid.dart';

import 'package:audioplayers/audioplayers.dart';

class LegoGame extends ConsumerStatefulWidget {
  const LegoGame({super.key});

  @override
  ConsumerState<LegoGame> createState() => _LegoGameState();
}

class _LegoGameState extends ConsumerState<LegoGame> {
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  List<Color?> gridColors = [];
  List<bool> isIncorrectPlacement = [];
  int correctPlacements = 0;
  int totalColoredCircles = 0;
  Timer? _timer;
  int _seconds = 0;
  DateTime? _startTime;
  double accuracy = 0;
  final AudioCache _audioCache = AudioCache();
  final AudioPlayer player = AudioPlayer();
  bool _showGame = false;
  int gridSize = 7;
  List<Map<String, dynamic>> filledCircles = [];
  Difficulty _selectedDifficulty = Difficulty.hard;
  bool _isPaused = false;
  bool _vibrationEnabled = false;
  bool _soundEnabled = true;
  Map<Color, int> remainingCirclesCount = {
    Colors.blue: 10,
    Colors.red: 10,
    Colors.green: 10,
    Colors.black: 10,
    Colors.orange: 10,
  };
  CloudStoreService _cloudStoreService = CloudStoreService();

  List<Color> miniatureGrid = [];

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
    _loadSettings().then((_) {
      final selectedChild = ref.read(selectedChildDataProvider);
      selectedChildUserId = selectedChild!.childId;
      // Show difficulty dialog as soon as the page appears
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDifficultyDialog();
      });
    });
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    player.dispose();
    super.dispose();
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
      'Instruction_Swipe.mp3'
    ]);
  }

  void _startGame() {
    setState(() {
      _showGame = true;
    });
    _startStopwatch();
  }

  void createMiniatureGridList() {
    miniatureGrid =
        List<Color>.filled(gridSize * gridSize, Colors.white, growable: false);
    for (int i = 0; i < gridSize * gridSize; i++) {
      int row = i ~/ gridSize;
      int col = i % gridSize;

      for (var filledCircle in filledCircles) {
        if (filledCircle['row'] == row && filledCircle['column'] == col) {
          miniatureGrid[i] = filledCircle['color'];
        }
      }
    }
    print(miniatureGrid);
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      gridColors = List.filled(gridSize * gridSize, Colors.white);
      isIncorrectPlacement = List.filled(gridSize * gridSize, false);
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
    for (int i = 0; i < gridSize * gridSize; i++) {
      if (miniatureGrid[i] == gridColors[i]) {
        correctTiles += 1;
      }
    }

    setState(() {
      accuracy = (correctTiles / (gridSize * gridSize) * 100).toPrecision(2);
      print(accuracy);
    });
  }

  void _showCongratsDialog() async {
    // setState(() {
    //   _isPaused = true;
    // });
    _cloudStoreService.addLegoGameData(LegoGameData(
      userId: selectedChildUserId,
      sessionId: sessionId,
      level: 'Lego Game',
      difficulty: _selectedDifficulty,
      accuracy: accuracy,
      elapsedTime: _seconds,
    ));
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MotorskillsPage()));
            setState(() {
              _isPaused = false;
            });
          },
        );
      },
    );
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

      if (difficulty == Difficulty.easy) {
        gridSize = 3;
        filledCircles = easyFilledCircles;
      } else if (difficulty == Difficulty.medium) {
        gridSize = 5;
        filledCircles = mediumFilledCircles;
      } else if (difficulty == Difficulty.hard) {
        gridSize = 7;
        filledCircles = hardFilledCircles;
      }

      // Set totalColoredCircles after filledCircles is set
      totalColoredCircles = filledCircles.length;

      // Reset gridColors and isIncorrectPlacement
      gridColors = List.filled(gridSize * gridSize, Colors.white);
      isIncorrectPlacement = List.filled(gridSize * gridSize, false);
      _showGame = true;

      // Initialize miniature grid
      createMiniatureGridList();
    });
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
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Pixel Puzzle'.tr,
                        style: TextStyle(
                          fontSize: baseSize * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize * 0.05),
                    GestureDetector(
                      onTap: _showDifficultyDialog,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.15,
                          child: Stack(
                            children: [],
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          alignment: Alignment
                              .center, // Center the text over the circular indicator
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      baseSize * 0.05), // Horizontal padding
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.12, // Responsive width
                                height: MediaQuery.of(context).size.width *
                                    0.12, // Responsive height
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: baseSize * 0.02,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '$correctPlacements/$totalColoredCircles',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.03, // Responsive font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Time: ${_seconds} s',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.045, // Responsive font size
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .transparent, // You might want to change this color
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
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(baseSize * 0.03),
                      child: Container(
                        width: screenWidth * 0.35,
                        height: screenWidth * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(baseSize * 0.03),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(baseSize * 0.02),
                          child: MiniatureGrid(
                            config: filledCircles,
                            gridSize: gridSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize * 0.07),
                    Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.58,
                      child: GridView.count(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: baseSize * 0.01,
                        mainAxisSpacing: baseSize * 0.01,
                        shrinkWrap: true, // Prevents scrolling
                        physics:
                            NeverScrollableScrollPhysics(), // Disables scrolling
                        children: List.generate(gridSize * gridSize, (index) {
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
                        }),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
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
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}

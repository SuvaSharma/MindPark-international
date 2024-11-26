import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/PictureSortingGamedata.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/draggable_stack.dart';
import 'package:mindgames/utils/image_paths.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class PictureSortingGame extends ConsumerStatefulWidget {
  const PictureSortingGame({super.key});

  @override
  ConsumerState<PictureSortingGame> createState() => _PictureSortingGameState();
}

class _PictureSortingGameState extends ConsumerState<PictureSortingGame> {
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  int _correctAttempts = 0;
  int _incorrectAttempts = 0;
  int _totalAttempts = 0;
  bool _hasStarted = false;
  bool _isPaused = false; // Flag to control timer pause/resume
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  List<Color> _containerColors =
      List.generate(imagePaths.length, (index) => Colors.transparent);
  final GlobalKey<DraggableStackState> _draggableStackKey2 =
      GlobalKey<DraggableStackState>();
  int _seconds = 0; // Stopwatch in milliseconds
  late final Timer _timer;
  int _correctlyPlacedImages = 0;
  double accuracy = 0;
  int _numImgInGrid = 2;
  late Difficulty _selectedDifficulty;
  List<String> _gridImages = [];
  CloudStoreService _cloudStoreService = CloudStoreService();
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
    _loadSettings().then((_) {
      final selectedChild = ref.read(selectedChildDataProvider);
      selectedChildUserId = selectedChild!.childId;
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

  void _playSound(String fileName, AudioPlayer plyer) {
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
              // _generateNewImageCount();
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
      _hasStarted = true; // Start the game
    });
    _setGameParameters(_selectedDifficulty);
    _startStopwatch(); // Start the stopwatch
  }

  void _setGameParameters(Difficulty difficulty) {
    setState(() {
      if (difficulty == Difficulty.easy) {
        _numImgInGrid = 2;
        _gridImages = [imagePaths[0], imagePaths[1]]; // Example: fish and horse
      } else if (difficulty == Difficulty.medium) {
        _numImgInGrid = 4;
        _gridImages = [
          imagePaths[0],
          imagePaths[1],
          imagePaths[2],
          imagePaths[3]
        ];
      } else if (difficulty == Difficulty.hard) {
        _numImgInGrid = 6;
        _gridImages = [
          imagePaths[0],
          imagePaths[1],
          imagePaths[2],
          imagePaths[3],
          imagePaths[4],
          imagePaths[5]
        ];
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
  }

  void _showCongratsDialog() async {
    setState(() {
      _isPaused = true;
    });
    log('$accuracy');
    _cloudStoreService.addPictureSortingGameData(PictureSortingGameData(
      userId: selectedChildUserId,
      sessionId: sessionId,
      level: 'Picture Sorting Game',
      difficulty: _selectedDifficulty,
      accuracy: accuracy,
      elapsedTime: _seconds,
    ));
    _playSound('GameOverDailog.mp3', player);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MotorskillsPage()),
            );
          },
        );
      },
    );
  }

  void _onImagePlaced(String image) {
    setState(() {
      _correctlyPlacedImages++;
      _correctAttempts++;
      _totalAttempts = _correctAttempts + _incorrectAttempts;

      int requiredCorrectImages = _selectedDifficulty == Difficulty.easy
          ? 5
          : _selectedDifficulty == Difficulty.medium
              ? 10
              : 20;

      if (_correctlyPlacedImages == requiredCorrectImages) {
        _stopStopwatch(); // Stop the stopwatch
        _showCongratsDialog();
      }
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
            quitDestinationPage: const MotorskillsPage(),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/balloon_background.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: _hasStarted ? _buildGamePage() : _buildIntroPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Picture Playtime'.tr,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF309092)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGamePage() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

    // Calculate the padding based on screen width
    final double leftPadding = screenWidth * 0.33;
    final double rightPadding = screenWidth * 0.05;

    log('total attempts: $_totalAttempts');
    setState(() {
      accuracy =
          _totalAttempts > 0 ? (_correctAttempts / _totalAttempts) * 100 : 0;
    });

    log('Accuracy aaya: ${accuracy.toStringAsFixed(2)}%');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: Text(
                'Timer: $_seconds seconds'.tr,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: baseSize * 0.02),
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(baseSize * 0.03),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(baseSize * 0.03),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    iconSize: baseSize * 0.07,
                    onPressed: _onBackPressed,
                  ),
                ),
              ),
            ),
          ],
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Dynamically calculate the number of columns
                int crossAxisCount;
                double itemSize;

                // Determine the grid configuration based on difficulty
                if (_selectedDifficulty == Difficulty.easy) {
                  crossAxisCount = 2;
                } else if (_selectedDifficulty == Difficulty.medium) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 3; // Hard difficulty
                }

                // Calculate item size based on screen width and height
                double gridWidth = constraints.maxWidth;
                double gridHeight = constraints.maxHeight;
                double maxItemWidth = gridWidth / crossAxisCount;
                double maxItemHeight =
                    gridHeight / (_numImgInGrid / crossAxisCount).ceil();
                itemSize =
                    maxItemWidth < maxItemHeight ? maxItemWidth : maxItemHeight;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _numImgInGrid,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15.0,
                    childAspectRatio: 1, // Keep square items
                  ),
                  itemBuilder: (context, index) {
                    return DragTarget<String>(
                      onAccept: (data) {
                        if (data == imagePaths[index]) {
                          if (_vibrationEnabled) {
                            Vibration.vibrate(
                              duration: 100,
                              amplitude: 10,
                            );
                          }
                          // Correct match
                          setState(() {
                            _containerColors[index] = Colors.green;
                            _correctAttempts++;
                            _playSound('right.mp3', player1);
                          });

                          _draggableStackKey2.currentState?.removeImage(data);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              _containerColors[index] = Colors.transparent;
                            });

                            _onImagePlaced(data);
                          });
                        } else {
                          // Incorrect match
                          setState(() {
                            _containerColors[index] = Colors.red;
                            _incorrectAttempts++;
                            _playSound('wrong.mp3', player);
                          });

                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              _containerColors[index] = Colors.transparent;
                            });
                          });
                        }
                        // Update total attempts
                        _totalAttempts = _correctAttempts + _incorrectAttempts;
                      },
                      onWillAccept: (data) => true,
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: itemSize,
                          height: itemSize,
                          decoration: BoxDecoration(
                            color: _containerColors[index],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Image.asset(
                              imagePaths[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: leftPadding,
            right: rightPadding,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: DraggableStack(
                key: _draggableStackKey2,
                onDragCompleted: (image) {
                  log('Drag completed with image: $image');
                },
                onImagePlaced: _onImagePlaced,
                gridImages: _gridImages,
                numImages: _selectedDifficulty == Difficulty.easy
                    ? 5
                    : _selectedDifficulty == Difficulty.medium
                        ? 10
                        : 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

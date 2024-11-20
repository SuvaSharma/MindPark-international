import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/picture_sorting_game.dart';
import 'package:mindgames/utils/image_paths.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/draggable_stack.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class PictureSortingDemoPage extends StatefulWidget {
  const PictureSortingDemoPage({super.key});

  @override
  State<PictureSortingDemoPage> createState() => _PictureSortingDemoPageState();
}

class _PictureSortingDemoPageState extends State<PictureSortingDemoPage> {
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
  final GlobalKey<DraggableStackState> _draggableStackKey1 =
      GlobalKey<DraggableStackState>();
  int _seconds = 0; // Stopwatch in milliseconds
  late final Timer _timer;
  int _correctlyPlacedImages = 0;
  double accuracy = 0;
  List<String> _gridImages = imagePaths;
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();

  @override
  void initState() {
    _loadSettings();
    _loadVibrationSetting();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel(); // Cancel the timer when the widget is disposed
    }
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
    ]);
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
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
    _playSound('GameOverDialog.mp3', player);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PictureSortingGame()), // Navigate back to LegoGame
            );
          },
        );
      },
    );
  }

  void _onImagePlaced(String image) {
    print('I was triggered');

    setState(() {
      _correctlyPlacedImages++;
      _correctAttempts++;
      _totalAttempts = _correctAttempts + _incorrectAttempts;

      // Check if all images are correctly placed
      if (_correctlyPlacedImages == 2) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasStarted) {
          bool result = await _onBackPressed();
          return result;
        } else {
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MotorskillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return SafeArea(
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
                    "Picture Playtime".tr,
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
                        borderRadius: BorderRadius.circular(baseSize * 0.05),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(baseSize * 0.05),
                        child: Image.asset(
                          'assets/images/picturesortinggame.jpeg',
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
                        setState(() {
                          _hasStarted = true;
                          _startStopwatch();
                        });
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
                                    const PictureSortingGame()));
                      },
                      child: Text('Skip Trial'.tr,
                          style: TextStyle(
                              fontSize: baseSize * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[200])),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

    print('total attempts: $_totalAttempts');
    setState(() {
      accuracy =
          _totalAttempts > 0 ? (_correctAttempts / _totalAttempts) * 100 : 0;
    });

    print('Accuracy aaya: ${accuracy.toStringAsFixed(2)}%');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: Text(
                'Timer: $_seconds seconds',
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 35.0,
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

                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          _containerColors[index] = Colors.transparent;
                        });
                        _draggableStackKey1.currentState?.removeImage(data);
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
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.width * 0.0001,
              left: leftPadding,
              right: rightPadding),
          child: Center(
            child: DraggableStack(
              key: _draggableStackKey1,
              onDragCompleted: (image) {
                print('Drag completed with image: $image');
              },
              onImagePlaced: _onImagePlaced,
              gridImages: _gridImages, // Pass the grid images to the stack
              numImages: 2,
            ),
          ),
        ),
      ],
    );
  }
}

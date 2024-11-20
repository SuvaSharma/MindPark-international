import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/puzzle_paradise_page.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/gameover_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/widgets/puzzle/jigsaw_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuzzleDemoWidget extends ConsumerStatefulWidget {
  const PuzzleDemoWidget({super.key});

  @override
  PuzzleDemoWidgetState createState() => PuzzleDemoWidgetState();
}

class PuzzleDemoWidgetState extends ConsumerState<PuzzleDemoWidget> {
  bool _isPaused = false;
  bool _isStarted = false;
  final AudioCache _audioCache = AudioCache();
  final AudioPlayer player = AudioPlayer();
  final GlobalKey<JigsawWidgetState> jigKey = GlobalKey<JigsawWidgetState>();
  bool _showGame = false;
  bool _vibrationEnabled = false;
  bool _soundEnabled = true;

  @override
  void initState() {
    _loadSettings();
    _loadVibrationSetting();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
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

  void startGame() {
    _playSound('playbutton.mp3', player);
    setState(() {
      _isStarted = true;
      _showGame = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () async {
        await jigKey.currentState?.generateJigsawCropImage();
      });
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
  }

  Future<bool> onBackPressed() async {
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

  void showCongratsDialog() async {
    _playSound('GameOverDialog.mp3', player);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const PuzzleWidget()));
            setState(() {
              // You can reset the state here if needed.
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: () async {
        if (_isStarted) {
          bool result = await onBackPressed();
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
        body: Stack(
          children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            !_isStarted
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
                                  "Puzzle Paradise".tr,
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
                                        'assets/images/puzzle_paradise.jpg',
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
                                      startGame();
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
                                                  const PuzzleWidget()));
                                    },
                                    child: Text(
                                      'Skip Trial'.tr,
                                      style: TextStyle(
                                        fontSize: baseSize * 0.06,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red[200],
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
                  )
                : SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenWidth * 0.02,
                                right: screenWidth * 0.02,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPaused = true;
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
                                          borderRadius: BorderRadius.circular(
                                              baseSize * 0.03),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.pause),
                                          iconSize: baseSize * 0.07,
                                          onPressed: onBackPressed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: JigsawWidget(
                                xSplitCount: 2,
                                ySplitCount: 1,
                                callbackFinish: () {
                                  setState(() {
                                    _isPaused = true;
                                  });

                                  showCongratsDialog();
                                },
                                callbackSuccess: () {
                                  print("callbackSuccess");
                                  // lets fix error size
                                },
                                key: jigKey,
                                // set container for our jigsaw image
                                child: SizedBox(
                                  height: screenWidth * 0.8,
                                  width: screenWidth * 0.8,
                                  child: const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/images/fish.jpg',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: _isStarted,
                                  child: Image.asset('assets/images/fish.jpg',
                                      height: screenWidth * 0.3,
                                      width: screenWidth * 0.3),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

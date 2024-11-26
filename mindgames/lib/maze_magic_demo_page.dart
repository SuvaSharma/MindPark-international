import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/cognitive_skills_page.dart';
import 'package:mindgames/maze_magic_page.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/maze/maze.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MazeMagicDemoPage extends ConsumerStatefulWidget {
  const MazeMagicDemoPage({super.key});

  @override
  ConsumerState<MazeMagicDemoPage> createState() => _MazeMagicDemoPageState();
}

class _MazeMagicDemoPageState extends ConsumerState<MazeMagicDemoPage> {
  bool isPaused = false;

  final AudioPlayer player = AudioPlayer();
  bool _showGame = false;
  int gridSize = 3;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _playSound('playbutton.mp3', player);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true; // Default: true
      // Update SoundManager with the new sound setting
      SoundManager.isSoundEnabled = _soundEnabled;
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
  }

  void startGame() {
    setState(() {
      _showGame = true;
    });
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
            quitDestinationPage: const CognitiveSkillsPage(),
          ),
        ),
      );
    }

    setState(() {
      isPaused = true;
    });
    result = await displayPauseMenu();
    setState(() {
      isPaused = false;
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
                MaterialPageRoute(builder: (context) => const MazeMagicPage()));
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: () async {
        if (_showGame) {
          bool result = await onBackPressed();
          return result;
        } else {
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const CognitiveSkillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/images/balloon_background.jpeg",
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
                                  "Maze Magic".tr,
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
                                        'assets/images/maze_magic.jpeg',
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
                                                  const MazeMagicPage()));
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
                                    isPaused = true; // Trigger the pause menu
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
                            SizedBox(
                              height: screenHeight * 0.8,
                              child: Stack(
                                children: [
                                  Maze(
                                    player: MazeItem(
                                      'assets/images/mouse.png',
                                      ImageType.asset,
                                    ),
                                    columns: gridSize,
                                    rows: gridSize,
                                    wallThickness: screenWidth * 0.008,
                                    wallColor: Colors.white,
                                    finish: MazeItem('assets/images/cheese.png',
                                        ImageType.asset),
                                    onFinish: () {
                                      setState(() {
                                        isPaused = true;
                                      });

                                      showCongratsDialog();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

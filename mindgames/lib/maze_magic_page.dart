import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/cognitive_skills_page.dart';
import 'package:mindgames/models/maze_magic_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/gameover_dialog.dart';
import 'package:mindgames/widgets/maze/maze.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MazeMagicPage extends ConsumerStatefulWidget {
  const MazeMagicPage({super.key});

  @override
  ConsumerState<MazeMagicPage> createState() => _MazeMagicPageState();
}

class _MazeMagicPageState extends ConsumerState<MazeMagicPage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  bool _isPaused = false;
  Timer? timer;
  int timeTaken = 0;
  int timeLimit = 0;
  int timeRemaining = 0;
  late Difficulty _selectedDifficulty;
  final AudioPlayer player = AudioPlayer();
  bool _showGame = false;
  int gridSize = 0;
  bool _soundEnabled = true;

  @override
  void initState() {
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
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (!_isPaused) {
          timeTaken += 1;
          timeRemaining -= 1;
        }
      });
      if (timeRemaining == 0) {
        timer?.cancel();
        setState(() {
          _isPaused = true;
          storeData();
          _showGameOverDialog();
        });
      }
    });
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
              startTimer();
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
        gridSize = 3;
        timeLimit = 3600;
      } else if (difficulty == Difficulty.medium) {
        gridSize = 5;
        timeLimit = 60;
      } else if (difficulty == Difficulty.hard) {
        gridSize = 7;
        timeLimit = 120;
      }
      timeRemaining = timeLimit;
    });
  }

  void storeData() async {
    cloudStoreService.addMazeMagicData(MazeMagicModel(
      userId: selectedChildUserId,
      sessionId: sessionId,
      level: 'Maze Magic',
      status: timeRemaining == 0 ? 'Not completed' : 'Completed',
      difficulty: _selectedDifficulty,
      timeTaken: timeTaken,
    ));
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
      _isPaused = true;
    });
    result = await displayPauseMenu();
    setState(() {
      _isPaused = false;
    });

    return result ?? false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GameOverDialog(
          onOkPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CognitiveSkillsPage()));
          },
        );
      },
    );
  }

  void showCongratsDialog() async {
    _playSound('GameOverDialog.mp3', player);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CognitiveSkillsPage()));
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
      onWillPop: onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/images/balloon_background.jpeg",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            if (_showGame)
              SafeArea(
                child: Stack(
                  children: [
                    if (_selectedDifficulty != Difficulty.easy)
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenWidth * 0.02,
                          left: screenWidth * 0.02,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            height: screenWidth * 0.15,
                            width: screenWidth * 0.15,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/timer_container.svg',
                                  fit: BoxFit.cover,
                                  width: screenWidth * 0.06,
                                  color: Color.fromARGB(255, 21, 173, 184),
                                  // Ensure the image covers the entire area of the Container
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight * 0.018,
                                      left: screenWidth * 0.03),
                                  child: Text(
                                    '${convertToNepaliNumbers((timeRemaining).toString())}s',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.040,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                      onPressed: onBackPressed,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.7,
                          child: Stack(
                            children: [
                              Maze(
                                backgroundImage: 'assets/images/map.jpeg',
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
                                    _isPaused = true;
                                  });
                                  storeData();
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

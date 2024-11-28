import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/puzzle_paradise_model.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/gameover_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/widgets/puzzle/jigsaw_widget.dart';
import 'package:mindgames/widgets/puzzle/puzzle_image_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuzzleWidget extends ConsumerStatefulWidget {
  const PuzzleWidget({super.key});

  @override
  PuzzleWidgetState createState() => PuzzleWidgetState();
}

class PuzzleWidgetState extends ConsumerState<PuzzleWidget> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  bool _isPaused = false;
  bool _isStarted = false;
  Timer? timer;
  int timeTaken = 0;
  int timeLimit = 0;
  int timeRemaining = 0;
  final AudioPlayer player = AudioPlayer();
  final GlobalKey<JigsawWidgetState> jigKey = GlobalKey<JigsawWidgetState>();
  final _random = math.Random();
  late String imageSelected;
  bool _showGame = false;
  late Difficulty _selectedDifficulty;

  int numberOfColumns = 0;
  int numberOfRows = 0;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    int imageIndex = _random.nextInt(imageList.length);
    imageSelected = imageList[imageIndex];
    _loadSettings().then((_) {
      final selectedChild = ref.read(selectedChildDataProvider);
      selectedChildUserId = selectedChild!.childId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _showDifficultyDialog();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    player.dispose();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true; // Default: true
      // Update SoundManager with the new sound setting
      SoundManager.isSoundEnabled = _soundEnabled;
    });
  }

  void startGame() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to access the currentState safely with a delay in case it's null
      Future.delayed(const Duration(milliseconds: 500), () async {
        await jigKey.currentState?.generateJigsawCropImage();
      });

      startTimer();
      setState(() {
        _isStarted = true;
      });
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
              startGame();
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
        numberOfColumns = 2;
        numberOfRows = 1;
        timeLimit = 3600;
      } else if (difficulty == Difficulty.medium) {
        numberOfColumns = 2;
        numberOfRows = 2;
        timeLimit = 120;
      } else if (difficulty == Difficulty.hard) {
        numberOfColumns = 2;
        numberOfRows = 3;
        timeLimit = 180;
      }
      timeRemaining = timeLimit;
    });
  }

  void storeData() async {
    cloudStoreService.addPuzzleParadiseData(PuzzleParadiseModel(
      userId: selectedChildUserId,
      sessionId: sessionId,
      level: 'Puzzle Paradise',
      status: timeRemaining == 0 ? 'Not completed' : 'Completed',
      difficulty: _selectedDifficulty,
      imageName: imageSelected.split('/')[2],
      timeTaken: timeTaken,
    ));
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
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
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MotorskillsPage()));
            setState(() {
              // You can reset the state here if needed.
            });
          },
        );
      },
    );
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
                    builder: (context) => const MotorskillsPage()));
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
      onWillPop: onBackPressed,
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
                    if (_selectedDifficulty != Difficulty.easy)
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenWidth * 0.02,
                          left: screenWidth * 0.02,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            height: baseSize * 0.13,
                            width: baseSize * 0.13,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/timer_container.svg',
                                  fit: BoxFit.cover,
                                  colorFilter: const ColorFilter.mode(
                                      Color.fromARGB(255, 21, 173, 184),
                                      BlendMode.srcIn),

                                  // Ensure the image covers the entire area of the Container
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight * 0.018,
                                      left: screenWidth * 0.03),
                                  child: Text(
                                    '${convertToNepaliNumbers((timeRemaining).toString())}s',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
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
                                    onPressed: onBackPressed,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            bottom: screenWidth * 0.02,
                          ),
                          child: JigsawWidget(
                            xSplitCount: numberOfColumns,
                            ySplitCount: numberOfRows,
                            callbackFinish: () {
                              log('Time taken: $timeTaken');
                              setState(() {
                                _isPaused = true;
                              });
                              showCongratsDialog();
                              storeData();
                            },
                            callbackSuccess: () {
                              log("callbackSuccess");
                              // lets fix error size
                            },
                            key: jigKey,
                            // set container for our jigsaw image
                            child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage(imageSelected),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isStarted,
                          child: Image.asset(imageSelected,
                              height: screenWidth * 0.2,
                              width: screenWidth * 0.2),
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

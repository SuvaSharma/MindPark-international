import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/jungle_jingles_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/jungle_jingles/animals_data.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class JungleJinglesPage extends ConsumerStatefulWidget {
  const JungleJinglesPage({super.key});

  @override
  ConsumerState<JungleJinglesPage> createState() => _JungleJinglesPageState();
}

class _JungleJinglesPageState extends ConsumerState<JungleJinglesPage>
    with SingleTickerProviderStateMixin {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  bool isPaused = false;
  bool _vibrationEnabled = false;
  bool _answered = false;
  bool _isStarted = false;
  bool shouldDisplayAnimation = false;
  Map<String, String>? _selectedOption;
  int _currentAnimalIndex = 0;
  late List<Map<String, String>> randomOptions;
  final AudioPlayer player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  Difficulty _selectedDifficulty = Difficulty.easy; // Default hai Vhidu!
  List<Map<String, String>> animalData = [];
  int numOptions = 2;
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );
  late final Animation<Offset> offsetAnimation;
  int score = 0;
  String? feedbackImage;
  String animalImage = '';

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();

    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;

    offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // page load huda difficulty dialog dekhauni
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultyDialog();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: DifficultyDialog(
            onDifficultySelected: (difficulty) {
              Navigator.pop(context); //band karde tera yeh dialog
              _startGameWithDifficulty(
                  difficulty); // difficulty anusar game start huncha
            },
            onBackPressed: () {},
          ),
        );
      },
    );
  }

  void _onDifficultySelected(Difficulty difficulty) {
    _startGameWithDifficulty(difficulty);
  }

  void _startGameWithDifficulty(Difficulty difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _isStarted = true;
    });
    _setGameParameters(_selectedDifficulty);
  }

  void _setGameParameters(Difficulty difficulty) {
    setState(() {
      if (difficulty == Difficulty.easy) {
        animalData = easyAnimals;
        numOptions = 2;
      } else if (difficulty == Difficulty.medium) {
        animalData = mediumAnimals;
        numOptions = 3;
      } else if (difficulty == Difficulty.hard) {
        animalData = hardAnimals;
        numOptions = 4;
      }
      animalData.shuffle();
      animalImage = animalData[_currentAnimalIndex]['image']!;
      populateRandomOptions();
      _startAnimation();
    });
  }

  void startGame(Difficulty difficulty) {
    setState(() {
      _isStarted = true;
    });
  }

  void _startAnimation() {
    _animationController.forward();
    _playSound(
        'animal_sounds/${animalData[_currentAnimalIndex >= animalData.length ? 0 : _currentAnimalIndex]['sound']}',
        player);
  }

  Future<void> fadeAnimation() async {
    await _animationController.reverse();
  }

  void populateRandomOptions() {
    final correctOption = animalData[
        _currentAnimalIndex >= animalData.length ? 0 : _currentAnimalIndex];
    final options = <Map<String, String>>[];
    options.add(correctOption);

    while (options.length < numOptions) {
      final randomOption = animalData[math.Random().nextInt(animalData.length)];

      if (!options.contains(randomOption)) {
        options.add(randomOption);
      }
    }
    options.shuffle();

    randomOptions = options;
  }

  Future<bool> onBackPressed() async {
    _playSound('PauseTap.mp3', player1);
    bool? result;

    setState(() {
      shouldDisplayAnimation = false;
    });

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
            quitDestinationPage: const SocialskillsPage(),
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

      if (shouldDisplayAnimation) {
        shouldDisplayAnimation = false;

        _startAnimation();
        animalImage = animalData[_currentAnimalIndex >= animalData.length
            ? 0
            : _currentAnimalIndex]['image']!;
        populateRandomOptions();
      }
    });

    return result ?? false;
  }

  void _selectOption(Map<String, String> option) {
    setState(() {
      _selectedOption = option;
      _answered = false;
    });
    _playSound('animal_sounds/${option['sound']}', player);
  }

  void _checkAnswer() async {
    setState(() {
      _answered = true;
    });

    bool isCorrect = _selectedOption ==
        animalData[
            _currentAnimalIndex >= animalData.length ? 0 : _currentAnimalIndex];

    if (isCorrect) {
      if (_vibrationEnabled) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 10,
        );
      }
      _playSound('task_completed.mp3', player);
      setState(() {
        score += 1;
        feedbackImage = 'assets/images/25.png';
      });
    } else {
      _playSound('mistake.mp3', player);
      setState(() {
        feedbackImage = 'assets/images/54.png';
      });
    }

    await Future.delayed(const Duration(seconds: 1), () async {
      await fadeAnimation();
      setState(() {
        _selectedOption = null;
        _answered = false;
        if (_currentAnimalIndex < animalData.length - 1) {
          _currentAnimalIndex++;
          if (!isPaused) {
            _startAnimation();
            animalImage = animalData[_currentAnimalIndex >= animalData.length
                ? 0
                : _currentAnimalIndex]['image']!;
            populateRandomOptions();
          } else {
            setState(() {
              shouldDisplayAnimation = true;
            });
          }
        } else {
          _currentAnimalIndex++;
          storeData();
          showCongratsDialog();
          isPaused = true;
        }
      });
    });
  }

  void storeData() {
    final accuracy = score / animalData.length * 100;
    cloudStoreService.addJungleJinglesData(JungleJinglesModel(
      userId: selectedChildUserId,
      level: 'Jungle Jingles',
      difficulty: _selectedDifficulty,
      sessionId: sessionId,
      score: accuracy,
    ));
  }

  void _playSound(String fileName, AudioPlayer player) async {
    SoundManager.playSound(fileName);
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
                    builder: (context) => const SocialskillsPage()));
            setState(() {});
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
            if (_isStarted)
              SafeArea(
                child: Stack(
                  children: [
                    if (!_isStarted) ...[
                      DifficultyDialog(
                        onDifficultySelected: _onDifficultySelected,
                        onBackPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ] else ...[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.02),
                          child: SizedBox(
                            width: screenWidth * 0.20,
                            height: screenWidth * 0.20,
                            child: CircularChart(
                              chartData: ChartData(
                                  'Voiceloon',
                                  _currentAnimalIndex / animalData.length * 100,
                                  Colors.black),
                              fontSize: screenWidth * 0.035,
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
                                  isPaused = true; // Trigger the pause menu
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
                          SlideTransition(
                            position: offsetAnimation,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(23),
                                        child: Image.asset(
                                          "assets/images/animals/$animalImage",
                                          height: screenWidth * 0.5,
                                          width: screenWidth * 0.5,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            _playSound(
                                                'animal_sounds/${animalData[_currentAnimalIndex >= animalData.length ? 0 : _currentAnimalIndex]['sound']}',
                                                player);
                                          },
                                          icon: Icon(
                                            Icons.volume_up_rounded,
                                            size: screenWidth * 0.08,
                                          ))
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.18),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                                  itemCount: randomOptions.length,
                                  itemBuilder: (context, index) {
                                    Map<String, String> option =
                                        randomOptions[index];
                                    bool isSelected = _selectedOption == option;
                                    bool isCorrect = option ==
                                        animalData[_currentAnimalIndex >=
                                                animalData.length
                                            ? 0
                                            : _currentAnimalIndex];
                                    bool showFeedback = _answered;

                                    return GestureDetector(
                                      onTap: () => _answered
                                          ? null
                                          : _selectOption(option),
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: showFeedback
                                              ? isCorrect
                                                  ? Colors.green
                                                  : isSelected
                                                      ? Colors.red
                                                      : Colors.blue
                                              : Colors.blue,
                                          border: Border.all(
                                            color: isSelected && !showFeedback
                                                ? const Color.fromARGB(
                                                    137, 1, 17, 85)
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.1),
                                        ),
                                        child: Text(
                                          option['name']!.tr,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                if (_answered)
                                  Image.asset(
                                    feedbackImage!,
                                    height: screenWidth * 0.2,
                                    width: screenWidth * 0.2,
                                  ),
                                Visibility(
                                  visible: !_answered,
                                  child: AnimatedButton(
                                    height: screenHeight * 0.09,
                                    width: screenWidth * 0.5,
                                    color: Colors.green,
                                    onPressed: _selectedOption != null
                                        ? _checkAnswer
                                        : () {}, // Disable if no option is selected
                                    child: Text(
                                      "Check Answer".tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.06,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/jungle_jingles_page.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:mindgames/utils/jungle_jingles/animals_data.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class JungleJinglesDemoPage extends ConsumerStatefulWidget {
  const JungleJinglesDemoPage({super.key});

  @override
  ConsumerState<JungleJinglesDemoPage> createState() =>
      _JungleJinglesDemoPageState();
}

class _JungleJinglesDemoPageState extends ConsumerState<JungleJinglesDemoPage>
    with SingleTickerProviderStateMixin {
  bool isPaused = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _answered = false;
  bool _isStarted = false;
  Map<String, String>? _selectedOption;
  int _currentAnimalIndex = 0;
  List<Map<String, String>> randomOptions = [];
  final AudioPlayer player = AudioPlayer();
  final player1 = AudioPlayer();

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );
  late final Animation<Offset> offsetAnimation;
  int score = 0;
  String? feedbackImage;
  int animalCount = 3;

  @override
  void initState() {
    _loadSettings();
    _loadVibrationSetting();
    super.initState();
    easyAnimals.shuffle();
    offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _playSound('playbutton.mp3', player);
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void startGame() {
    setState(() {
      _isStarted = true;
      populateRandomOptions();
      _startAnimation();
    });
  }

  void _startAnimation() {
    _animationController.forward();
    _playSound(
        'animal_sounds/${easyAnimals[_currentAnimalIndex]['sound']}', player);
  }

  Future<void> fadeAnimation() async {
    await _animationController.reverse();
  }

  void populateRandomOptions() {
    final correctOption = easyAnimals[_currentAnimalIndex];
    final options = <Map<String, String>>[];
    options.add(correctOption);

    int numOptions = 2;

    while (options.length < numOptions) {
      final randomOption =
          easyAnimals[math.Random().nextInt(easyAnimals.length)];

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

    bool isCorrect = _selectedOption == easyAnimals[_currentAnimalIndex];

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
        if (_currentAnimalIndex < animalCount - 1) {
          _currentAnimalIndex++;
          _startAnimation();
          populateRandomOptions();
        } else {
          _currentAnimalIndex++;
          showCongratsDialog();
          isPaused = true;
        }
      });
    });
  }

  void _playSound(String fileName, AudioPlayer player) async {
    // if (player.state == PlayerState.playing) {
    //   await player.stop();
    // }

    // await player.play(AssetSource(fileName));
    SoundManager.playSound(fileName);
  }

  void showCongratsDialog() async {
    _playSound('GameOverDialog.mp3', player);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const JungleJinglesPage()));
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

    String animalImage = easyAnimals[
        _currentAnimalIndex >= animalCount ? 0 : _currentAnimalIndex]['image']!;

    return WillPopScope(
      onWillPop: () async {
        if (_isStarted) {
          bool result = await onBackPressed();
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
              "assets/images/balloon_background.jpeg",
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
                                  "Jungle Jingles".tr,
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
                                        'assets/images/jungle_jingles.jpeg',
                                        width: baseSize * 0.5,
                                        height: baseSize * 0.5,
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
                                                  const JungleJinglesPage()));
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
                                    _currentAnimalIndex / animalCount * 100,
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
                                      borderRadius: BorderRadius.circular(
                                          baseSize * 0.03),
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
                            SizedBox(height: screenHeight * 0.05),
                            SlideTransition(
                              position: offsetAnimation,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(23),
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
                                                  'animal_sounds/${easyAnimals[_currentAnimalIndex]['sound']}',
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
                                        horizontal: screenWidth * 0.15),
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
                                      bool isSelected =
                                          _selectedOption == option;
                                      bool isCorrect = option ==
                                          easyAnimals[_currentAnimalIndex];
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
                                              fontSize: screenWidth * 0.05,
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

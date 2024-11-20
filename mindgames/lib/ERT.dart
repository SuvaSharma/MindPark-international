import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/config/easy_ert_config.dart';
import 'package:mindgames/config/hard_ert_config.dart';
import 'package:mindgames/config/medium_ert_config.dart';
import 'package:mindgames/ert_result.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/ert_enum.dart';
import 'package:mindgames/utils/ert_imagepath.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/emotions_buttons.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

TimerType _currentTimerType = TimerType.None;

class ERTpage extends ConsumerStatefulWidget {
  const ERTpage({super.key});

  @override
  ConsumerState<ERTpage> createState() => _ERTpageState();
}

class _ERTpageState extends ConsumerState<ERTpage>
    with SingleTickerProviderStateMixin {
  late final String selectedChildUserId;
  bool showStartButton = true;
  bool isStarted = false;
  bool showFixationPoint = false;
  bool showContainer = false;
  double containerOpacity = 0.0;
  bool showImage = false;
  bool showNoise = false;
  int currentImageIndex = 0;
  bool showEmotionButtons = false;
  bool showcorrectFeedbackImage = false;
  bool showincorrectFeedbackImage = false;
  int score = 0;
  bool isGameOver = false; // Add this flag
  DateTime sessionId = DateTime.now();
  int _fixationStartTime = 0;
  int _fixationEndTime = 0;
  int _imageStartTime = 0;
  int _imageEndTime = 0;
  int _optionStartTime = 0;
  int _optionEndTime = 0;
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool showDifficultyDialog = true;
  late List<String> images = [];
  late int numberofimages = 0;
  late Difficulty _selectedDifficulty;
  late AnimationController _animationController;
  late Animation<Offset> _leftButtonAnimation;
  late Animation<Offset> _rightButtonAnimation;

  late Timer containerTimer;
  late Timer fixationTimer;
  late Timer imageTimer;
  late Timer noiseTimer;
  late Timer optionTimer;
  late Timer feedbackTimer;
  late Timer resetTimer;
  CloudStoreService _cloudStoreService = CloudStoreService();

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // // Shuffle the images list
    // images.shuffle();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _leftButtonAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rightButtonAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    // _showDifficultyDialog();

    _loadVibrationSetting();
    _preloadAudio();
    _loadSettings().then((_) {
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 2));
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
      'Instruction_Swipe.mp3'
    ]);
  }

  void _playSound(String fileName, AudioPlayer player) {
    SoundManager.playSound(fileName);
  }

  void _displayContainer() {
    print('container shown');
    _currentTimerType = TimerType.Container;
    setState(() {
      showContainer = true;
      containerOpacity = 0;
    });

    containerTimer = Timer(Duration(milliseconds: 10), () {
      setState(() {
        containerOpacity = 1.0;
      });
    });
    _displayFixation();
  }

  void _displayFixation() {
    print('fixation shown');
    _fixationStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Fixation;
    setState(() {
      showFixationPoint = true;
    });
    fixationTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        showFixationPoint = false;
      });
      _displayImage();
    });
  }

  void _displayImage() {
    print('image shown');
    _imageStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Image;
    setState(() {
      showImage = true;
    });
    imageTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        showImage = false;
      });
      _displayNoise();
    });
  }

  void _displayNoise() {
    print('noise shown');
    _currentTimerType = TimerType.Noise;
    setState(() {
      showNoise = true;
    });
    noiseTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        showNoise = false;
      });
      _displayOption();
    });
  }

  void _displayOption() {
    print('option shown');
    _optionStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Option;
    setState(() {
      showEmotionButtons = true;
      showContainer = false;
      _animationController.forward();
    });

    optionTimer = Timer(Duration(milliseconds: 5000), () {
      setState(() {
        showEmotionButtons = false;
      });
      _onEmotionButtonPressed('');
    });
  }

  void _startAnimation() {
    _displayContainer();
  }

  void _onEmotionButtonPressed(String emotion) {
    // Cancel all timers to stop ongoing displays
    containerTimer.cancel();
    fixationTimer.cancel();
    imageTimer.cancel();
    noiseTimer.cancel();
    optionTimer.cancel();

    setState(() {
      showEmotionButtons = false;
    });

    if (isGameOver) {
      return;
    }

    String currentImage = images[currentImageIndex];
    String correctEmotion = imageToEmotion[currentImage]!;

    if (emotion == correctEmotion) {
      print("Correct! The emotion is $emotion.");
      if (_vibrationEnabled) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 10,
        );
      }
      setState(() {
        showcorrectFeedbackImage = true;
        _playSound('right.mp3', player1);

        score++;
      });

      feedbackTimer = Timer(Duration(milliseconds: 500), () {
        setState(() {
          showcorrectFeedbackImage = false;
        });

        if (currentImageIndex == images.length - 1) {
          setState(() {
            currentImageIndex = (currentImageIndex + 1);
            //  % images.length;
            // _animationController.reset();
          });
          _showGameOverDialog();
          isGameOver = true;
        } else {
          Future.delayed(Duration(milliseconds: 10), () {
            setState(() {
              currentImageIndex = (currentImageIndex + 1) % images.length;
              _animationController.reset();
            });
            _displayContainer();
          });
        }
      });
    } else {
      print("Incorrect! Try again.");
      setState(() {
        showincorrectFeedbackImage = true;
        _playSound('wrong.mp3', player);
      });

      feedbackTimer = Timer(Duration(milliseconds: 500), () {
        setState(() {
          showincorrectFeedbackImage = false;
        });

        if (currentImageIndex == images.length - 1) {
          setState(() {
            currentImageIndex = (currentImageIndex + 1);
            //  % images.length;
            // _animationController.reset();
          });
          _showGameOverDialog();
          isGameOver = true;
        } else {
          Future.delayed(Duration(milliseconds: 10), () {
            setState(() {
              currentImageIndex = (currentImageIndex + 1) % images.length;
              print('animation was reset');
              _animationController.reset();
            });
            _displayContainer();
          });
        }
      });
    }
  }

  Future<bool> _onBackPressed() async {
    print('I was triggered');
    _playSound('PauseTap.mp3', player);

    bool? result;

    Future<bool?> displayPauseMenu() async {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: PauseMenu(
            onResume: () => Navigator.pop(context, false),
            onQuit: () {
              Navigator.pop(context, true);
            },
            quitDestinationPage: const SocialskillsPage(),
          ),
        ),
      );
    }

    if (_currentTimerType == TimerType.Fixation) {
      print('paused when fixation was shown');
      fixationTimer.cancel();
      _fixationEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedFixationTime = _fixationEndTime - _fixationStartTime;

      result = await displayPauseMenu();

      if (result == false) {
        fixationTimer =
            Timer(Duration(milliseconds: 500 - elapsedFixationTime), () {
          setState(() {
            showFixationPoint = false;
          });
          _displayImage();
        });
      }
    } else if (_currentTimerType == TimerType.Image) {
      print('paused when image was shown');
      imageTimer.cancel();
      _imageEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedImageTime = _imageEndTime - _imageStartTime;

      result = await displayPauseMenu();

      if (result == false) {
        imageTimer = Timer(Duration(milliseconds: 500 - elapsedImageTime), () {
          setState(() {
            showImage = false;
          });
          _displayNoise();
        });
      }
    } else if (_currentTimerType == TimerType.Option) {
      print('paused when option was shown');
      optionTimer.cancel();
      _optionEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedOptionTime = _optionEndTime - _optionStartTime;

      result = await displayPauseMenu();

      if (result == false) {
        optionTimer =
            Timer(Duration(milliseconds: 5000 - elapsedOptionTime), () {
          setState(() {
            showEmotionButtons = false;
          });

          if (currentImageIndex == images.length - 1) {
            _showGameOverDialog();
            isGameOver = true;
          } else {
            currentImageIndex++;
            _displayContainer();
          }
        });
      }
    }

    return result ?? false;
  }

  void _showGameOverDialog() async {
    _confettiController.play();

    _playSound('GameOverDialog.mp3', player);

    _cloudStoreService.addERTResult(
      ERTResult(
        userId: selectedChildUserId,
        level: 'ERT',
        difficulty: _selectedDifficulty,
        sessionId: sessionId,
        accuracy: score / images.length * 100,
        score: score,
      ),
    );
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on outside tap
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            _playSound('playbutton.mp3', player);
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SocialskillsPage(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    containerTimer.cancel();
    fixationTimer.cancel();
    imageTimer.cancel();
    noiseTimer.cancel();
    optionTimer.cancel();
    feedbackTimer.cancel();
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showDifficultyDialog() {
    _playSound('bounce.mp3', player);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: _onBackPressed,
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

  void _startGame() {
    _playSound('playbutton.mp3', player);
    _startAnimation();
    setState(() {
      showStartButton = false;
      isStarted = true;
    });
  }

  void _startGameWithDifficulty(Difficulty difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _setGameParameters(_selectedDifficulty);
    _playSound('playbutton.mp3', player);
    _startGame();
  }

  void _setGameParameters(Difficulty difficulty) {
    setState(() {
      if (difficulty == Difficulty.easy) {
        images = easyImages;
      } else if (difficulty == Difficulty.medium) {
        images = mediumImages;
      } else if (difficulty == Difficulty.hard) {
        images = hardImages;
      }
      images.shuffle();
      numberofimages = images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/balloon_background.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Visibility(
                      visible: isStarted,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: screenWidth * 0.20,
                            width: screenWidth * 0.20,
                            child: CircularChart(
                                chartData: ChartData(
                                    'ERT',
                                    currentImageIndex / images.length * 100,
                                    Colors.black),
                                fontSize: screenWidth * 0.03),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: screenWidth * 0.05),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {});
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
                                        onPressed: _onBackPressed,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Mood Magic'.tr,
                        style: TextStyle(
                          fontSize: baseSize * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize * 0.05),
                    // GestureDetector(
                    //   onTap: _showDifficultyDialog,
                    //   child: Container(
                    //       width: MediaQuery.of(context).size.width * 0.3,
                    //       height: MediaQuery.of(context).size.width * 0.15,
                    //       child: Stack(
                    //         children: [],
                    //       )),
                    // ),
                  ],
                ),
                if (showContainer)
                  Center(
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Material(
                        elevation: 15,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          width: screenSize.height * 0.37,
                          height: screenSize.height * 0.37,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (showFixationPoint)
                                  Center(
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                if (showImage)
                                  Image.asset(
                                    images[currentImageIndex],
                                    fit: BoxFit.cover,
                                  ),
                                if (showNoise)
                                  Image.asset(
                                    'assets/images/noise.gif',
                                    fit: BoxFit.cover,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showEmotionButtons)
                  EmotionButtons(
                    leftButtonAnimation: _leftButtonAnimation,
                    rightButtonAnimation: _rightButtonAnimation,
                    onEmotionButtonPressed: _onEmotionButtonPressed,
                    difficulty: _selectedDifficulty,
                  ),
                if (showcorrectFeedbackImage)
                  Center(
                    child: Container(
                      width: screenSize.width * 0.5,
                      height: screenSize.height * 0.25,
                      child: Image.asset(
                        'assets/images/25.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (showincorrectFeedbackImage)
                  Center(
                    child: Container(
                      width: screenSize.width * 0.5,
                      height: screenSize.height * 0.25,
                      child: Image.asset(
                        'assets/images/54.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

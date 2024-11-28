import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/ERT.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

enum TimerType {
  Container,
  Fixation,
  Image,
  Noise,
  Option,
  Feedback,
  Reset,
  None,
}

TimerType _currentTimerType = TimerType.None;

class ERTdemo extends StatefulWidget {
  const ERTdemo({super.key});

  @override
  State<ERTdemo> createState() => _ERTdemoState();
}

class _ERTdemoState extends State<ERTdemo> with SingleTickerProviderStateMixin {
  bool showStartButton = true;
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

  final List<String> images = [
    'assets/images/angry/angry_1.jpg',
    'assets/images/fear/fear_1.jpg',
    'assets/images/happy/happy_1.jpg',
    'assets/images/neutral/neutral_1.jpg',
    'assets/images/sad/sad_1.jpg',
    'assets/images/surprise/surprise_1.jpg',
  ];

  final Map<String, String> imageToEmotion = {
    'assets/images/angry/angry_1.jpg': "Angry",
    'assets/images/fear/fear_1.jpg': "Fear",
    'assets/images/happy/happy_1.jpg': "Happy",
    'assets/images/neutral/neutral_1.jpg': "Neutral",
    'assets/images/sad/sad_1.jpg': "Sad",
    'assets/images/surprise/surprise_1.jpg': "Surprise",
  };

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

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _leftButtonAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rightButtonAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadSoundSetting();
    _loadVibrationSetting();
    _preloadAudio();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _preloadAudio() {
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      log('Sound pre-initialized');
    });
    _audioCache.load('verbalgood.mp3').then((_) {
      log('verbal good sound pre-loaded');
    });
    _audioCache.load('wrong.mp3').then((_) {
      log('wrong sound pre-loaded');
    });
    _audioCache.load('GameOverDialog.mp3').then((_) {
      log('gameover sound pre-loaded');
    });
    _audioCache.load('PauseTap.mp3').then((_) {
      log('Pause sound pre-loaded');
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  void _displayContainer() {
    log('container shown');
    _currentTimerType = TimerType.Container;
    setState(() {
      showContainer = true;
      containerOpacity = 0;
    });

    containerTimer = Timer(const Duration(milliseconds: 10), () {
      setState(() {
        containerOpacity = 1.0;
      });
    });
    _displayFixation();
  }

  void _displayFixation() {
    log('fixation shown');
    _fixationStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Fixation;
    setState(() {
      showFixationPoint = true;
    });
    fixationTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        showFixationPoint = false;
      });
      _displayImage();
    });
  }

  void _displayImage() {
    log('image shown');
    _imageStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Image;
    setState(() {
      showImage = true;
    });
    imageTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        showImage = false;
      });
      _displayNoise();
    });
  }

  void _displayNoise() {
    log('noise shown');
    _currentTimerType = TimerType.Noise;
    setState(() {
      showNoise = true;
    });
    noiseTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        showNoise = false;
      });
      _displayOption();
    });
  }

  void _displayOption() {
    log('option shown');
    _optionStartTime = DateTime.now().millisecondsSinceEpoch;
    _currentTimerType = TimerType.Option;
    setState(() {
      showEmotionButtons = true;
      showContainer = false;
      _animationController.forward();
    });

    optionTimer = Timer(const Duration(milliseconds: 5000), () {
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
      log("Correct! The emotion is $emotion.");
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

      feedbackTimer = Timer(const Duration(milliseconds: 500), () {
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
          Future.delayed(const Duration(milliseconds: 10), () {
            setState(() {
              currentImageIndex = (currentImageIndex + 1);
              //  % images.length;
              _animationController.reset();
            });
            _displayContainer();
          });
        }
      });
    } else {
      log("Incorrect! Try again.");
      setState(() {
        showincorrectFeedbackImage = true;
        _playSound('wrong.mp3', player);
      });

      feedbackTimer = Timer(const Duration(milliseconds: 500), () {
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
          Future.delayed(const Duration(milliseconds: 10), () {
            setState(() {
              currentImageIndex = (currentImageIndex + 1);
              //% images.length;
              log('animation was reset');
              _animationController.reset();
            });
            _displayContainer();
          });
        }
      });
    }
  }

  Future<bool> _onBackPressed() async {
    log('I was triggered');
    _playSound('PauseTap.mp3', player);

    bool? result;

    Future<bool?> displayQuitDialog() async {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: PauseMenu(
            onResume: () {
              Navigator.pop(context, false);
            },
            onQuit: () {
              Navigator.pop(context, true);
            },
            quitDestinationPage: const SocialskillsPage(),
          ),
        ),
      );
    }

    if (_currentTimerType == TimerType.Fixation) {
      log('paused when fixation was shown');
      fixationTimer.cancel();
      _fixationEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedFixationTime = _fixationEndTime - _fixationStartTime;

      result = await displayQuitDialog();

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
      log('paused when image was shown');
      imageTimer.cancel();
      _imageEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedImageTime = _imageEndTime - _imageStartTime;

      result = await displayQuitDialog();

      if (result == false) {
        imageTimer = Timer(Duration(milliseconds: 500 - elapsedImageTime), () {
          setState(() {
            showImage = false;
          });
          _displayNoise();
        });
      }
    } else if (_currentTimerType == TimerType.Option) {
      log('paused when option was shown');
      optionTimer.cancel();
      _optionEndTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedOptionTime = _optionEndTime - _optionStartTime;

      result = await displayQuitDialog();

      if (result == false) {
        optionTimer =
            Timer(Duration(milliseconds: 5000 - elapsedOptionTime), () {
          setState(() {
            showEmotionButtons = false;
          });

          if (currentImageIndex == images.length - 1) {
            // Show game over dialog
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
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on outside tap
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return WillPopScope(
          // Prevent dialog from closing on back button press
          onWillPop: () async => false,
          child: Dialog(
            child: GestureDetector(
              onTap:
                  () {}, // Prevents tapping outside the dialog from closing it
              child: Container(
                width: screenWidth * 0.6,
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ConfettiWidget(
                        blastDirectionality: BlastDirectionality.explosive,
                        maxBlastForce: 15,
                        confettiController: _confettiController,
                        blastDirection: 170,
                        particleDrag: 0.05,
                        emissionFrequency: 0.05,
                        numberOfParticles: 20,
                        gravity: 0.2,
                        shouldLoop: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Congratulations!'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'You nailed it!'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: const Color(0xFF309092),
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/prize.png',
                        width: screenWidth * 0.2,
                      ),
                      Text(
                        'Score: '.tr + '$score'.tr,
                        // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          _playSound('playbutton.mp3', player);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ERTpage()), // Navigate to LevelScreen
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff309092),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: screenWidth * 0.07,
                            ),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     _playSound('playbutton.mp3');

                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) =>
                      //               ERTpage()), // Navigate to LevelScreen
                      //     );
                      //   },
                      //   child: Container(
                      //     width: screenWidth * 0.25,
                      //     // height: MediaQuery.of(context).size.width * 0.25,
                      //     child: Stack(
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/Play.png', // Replace with your image path
                      //           fit: BoxFit.cover,
                      //         ),
                      //         Center(
                      //           child: Text("Next".tr,
                      //               style: TextStyle(
                      //                 fontSize: screenWidth * 0.07,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.white,
                      //               )),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ]),
              ),
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: () async {
        if (!showStartButton) {
          log("Went to pause menu.");
          bool result = await _onBackPressed();
          return result;
        } else {
          log("Went to social skills menu");
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SocialskillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/balloon_background.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: showStartButton
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
                                "Mood Magic".tr,
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
                                    borderRadius:
                                        BorderRadius.circular(baseSize * 0.05),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(baseSize * 0.05),
                                    child: Image.asset(
                                      'assets/images/ert.png',
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
                                    _startAnimation();
                                    setState(() {
                                      showStartButton = false;
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
                                                const ERTpage()));
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
                          Row(
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
                              showStartButton
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.07),
                                      child: AnimatedButton(
                                        height: screenHeight * 0.05,
                                        width: screenWidth * 0.15,
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ERTpage()),
                                          );
                                        },
                                        child: Center(
                                          child: Text(
                                            'Skip'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.05),
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
                                                  BorderRadius.circular(
                                                      baseSize * 0.03),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          baseSize * 0.03),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.pause),
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
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Mood Magic Demo'.tr,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF309092),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                              onTap: () {
                                _playSound('playbutton.mp3', player);
                                _startAnimation();
                                setState(() {
                                  showStartButton = false;
                                });
                              },
                              child: Visibility(
                                visible: showStartButton,
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              15), // Optionally add border radius
                                          child: Image.asset(
                                            'assets/images/mainbutton.png',
                                            fit: BoxFit
                                                .cover, // Ensure the image covers the entire area of the Container
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            child: Text(
                                              "Start".tr,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              )),
                        ],
                      ),
                      if (showContainer)
                        Center(
                          child: AnimatedOpacity(
                            opacity: containerOpacity,
                            duration: const Duration(milliseconds: 500),
                            child: Material(
                              elevation: 15,
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                width: screenSize.height * 0.37,
                                height: screenSize.height * 0.37,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      screenSize.width * 25),
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
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SlideTransition(
                                    position: _leftButtonAnimation,
                                    child: AnimatedButton(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.3,
                                      color: Colors.blue,
                                      onPressed: () =>
                                          _onEmotionButtonPressed('Happy'),
                                      child: Text(
                                        'Happy'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  SlideTransition(
                                    position: _rightButtonAnimation,
                                    child: AnimatedButton(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.3,
                                      color: Colors.yellow,
                                      onPressed: () =>
                                          _onEmotionButtonPressed('Angry'),
                                      child: Text(
                                        'Angry'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenWidth * 0.019),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: SlideTransition(
                                      position: _leftButtonAnimation,
                                      child: AnimatedButton(
                                        height: screenWidth * 0.1,
                                        width: screenWidth * 0.3,
                                        color: Colors.green,
                                        onPressed: () =>
                                            _onEmotionButtonPressed('Surprise'),
                                        child: Text(
                                          'Surprise'.tr,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.07,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  SlideTransition(
                                    position: _rightButtonAnimation,
                                    child: AnimatedButton(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.3,
                                      color: Colors.orange,
                                      onPressed: () =>
                                          _onEmotionButtonPressed('Neutral'),
                                      child: Text(
                                        'Neutral'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenWidth * 0.019),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SlideTransition(
                                    position: _leftButtonAnimation,
                                    child: AnimatedButton(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.3,
                                      color: Colors.red,
                                      onPressed: () =>
                                          _onEmotionButtonPressed('Sad'),
                                      child: Text(
                                        'Sad'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  SlideTransition(
                                    position: _rightButtonAnimation,
                                    child: AnimatedButton(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.3,
                                      color: Colors.purple,
                                      onPressed: () =>
                                          _onEmotionButtonPressed('Fear'),
                                      child: Text(
                                        'Fear'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (showcorrectFeedbackImage)
                        Center(
                          child: SizedBox(
                            width: screenSize.width * 0.5,
                            height: screenSize.height * 0.25,
                            child: Image.asset(
                              'assets/images/25.png', // Add your feedback image here
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (showincorrectFeedbackImage)
                        Center(
                          child: SizedBox(
                            width: screenSize.width * 0.5,
                            height: screenSize.height * 0.25,
                            child: Image.asset(
                              'assets/images/54.png', // Add your feedback image here
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

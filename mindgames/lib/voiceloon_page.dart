import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/voiceloon_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/verbalskills.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/difficulty_dialog.dart';
import 'package:mindgames/widgets/gameover_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class VoiceloonPage extends ConsumerStatefulWidget {
  const VoiceloonPage({super.key});

  @override
  _VoiceloonPageState createState() => _VoiceloonPageState();
}

class _VoiceloonPageState extends ConsumerState<VoiceloonPage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  int balloonRaiseCount = 0;
  int counter = 0;
  double threshold = 0.0;
  int numberOfTrials = 0;
  bool showWellDoneText = false;
  late ConfettiController _confettiController;
  Random random = Random();
  final AudioPlayer player = AudioPlayer();
  bool _isPaused = false;
  bool _vibrationEnabled = false;
  Timer? timer;
  int timePlayed = 0;
  late final String selectedChildUserId;
  DateTime sessionId = DateTime.now();
  late Difficulty _selectedDifficulty;
  double promptTextOpacity = 1.0;
  bool _showGame = false;

  int timeTaken = 0;
  int timeLimit = 0;
  int timeRemaining = 0;
  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultyDialog();
    });
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    player.dispose();
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    _noiseSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
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
              start();
              startTimer();
              disappearText();
              _playSound('blow_the_balloon.mp3', player);
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
        threshold = 65.0;
        numberOfTrials = 3;
        timeLimit = 3600;
      } else if (difficulty == Difficulty.medium) {
        threshold = 70.0;
        numberOfTrials = 5;
        timeLimit = 120;
      } else if (difficulty == Difficulty.hard) {
        threshold = 75.0;
        numberOfTrials = 8;
        timeLimit = 180;
      }
      timeRemaining = timeLimit;
    });
  }

  void disappearText() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      promptTextOpacity = 0.0;
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          timePlayed += 1;
          timeRemaining -= 1;
        });
      }
      if (timeRemaining == 0) {
        timer.cancel();
        setState(() {
          _isPaused = true;
          storeData();
          _showGameOverDialog();
        });
      }
    });
  }

  void stopTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
  }

  void onData(NoiseReading noiseReading) {
    if (_isPaused) {
      stop();
    }
    setState(() {
      _latestReading = noiseReading;

      // Increment the counter if the mean decibel level exceeds the threshold.
      if (_latestReading?.meanDecibel != null) {
        if (_latestReading!.meanDecibel >= threshold && counter < 30) {
          counter++;
        } else if (_latestReading!.meanDecibel < threshold && counter > 0) {
          counter--;
        }
      }
    });

    // Check if the balloon has reached the top
    if (counter >= 27) {
      if (_vibrationEnabled) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 10,
        );
      }
      showWellDoneText = true;
      _confettiController.play();
      _playSound('task_completed.mp3', player);
      setState(() {
        balloonRaiseCount += 1;
      });
      Timer timer = Timer.periodic(const Duration(milliseconds: 185), (timer) {
        setState(() {
          if (counter > 0) {
            counter -= 1;
          } else {
            timer.cancel();
          }
        });
      });
      stop();

      // Hide the text after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          timer.cancel();
          showWellDoneText = false;
          start();
        });
      });

      if (balloonRaiseCount == numberOfTrials) {
        setState(() {
          _isPaused = true;
        });
        storeData();
        showCongratsDialog();
        stop();
      }
    }
  }

  void storeData() async {
    double accuracy = balloonRaiseCount / numberOfTrials * 100;
    await cloudStoreService.addVoiceloonData(VoiceloonModel(
      userId: selectedChildUserId,
      level: 'Voiceloon',
      difficulty: _selectedDifficulty,
      sessionId: sessionId,
      score: balloonRaiseCount,
      accuracy: accuracy,
      status: timeRemaining == 0 ? 'Not completed' : 'Completed',
      responseTime: timePlayed,
    ));
  }

  void onError(Object error) {
    print(error);
    stop();
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
                builder: (context) => const VerbalskillsPage(),
              ),
            );
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
                builder: (context) => const VerbalskillsPage(),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  Future<void> start() async {
    noiseMeter ??= NoiseMeter();
    if (!(await checkPermission())) await requestPermission();
    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
  }

  void stop() {
    _noiseSubscription?.cancel();
  }

  void _playSound(String fileName, AudioPlayer player) {
    player.play(AssetSource(fileName));
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
              print("Resumed");
              Navigator.pop(context, false);
              start();
              _resumeGame();
            },
            onQuit: () {},
            quitDestinationPage: const VerbalskillsPage(),
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

  void _resumeGame() {}

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    double balloonHeight = screenHeight * 0.07;

    // Corrected calculation: The balloon starts at the bottom and moves upward as the counter increases.
    double balloonPosition = (counter / 30) * (screenHeight - balloonHeight);

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.15),
                        child: SizedBox(
                          width: screenWidth * 0.20,
                          height: screenWidth * 0.20,
                          child: CircularChart(
                            chartData: ChartData(
                                'Voiceloon',
                                balloonRaiseCount / numberOfTrials * 100,
                                Colors.black),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
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
                                borderRadius:
                                    BorderRadius.circular(baseSize * 0.03),
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
                    Align(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        opacity: promptTextOpacity,
                        duration: const Duration(seconds: 2),
                        child: Text(
                          'Blow to make the balloon fly!'.tr,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Smooth animation duration
                      curve: Curves.easeInOut, // Smooth animation curve
                      bottom: balloonPosition,
                      left: MediaQuery.of(context).size.width / 2 -
                          balloonHeight / 2, // Center the balloon horizontally
                      child: Image.asset('assets/images/balloon.png',
                          width: balloonHeight),
                    ),
                    if (showWellDoneText) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Well done!',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.blue[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfettiWidget(
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
                      ),
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

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/voiceloon_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/verbalskills.dart';
import 'package:mindgames/voiceloon_page.dart';
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

class VoiceloonDemoPage extends ConsumerStatefulWidget {
  const VoiceloonDemoPage({super.key});

  @override
  _VoiceloonDemoPageState createState() => _VoiceloonDemoPageState();
}

class _VoiceloonDemoPageState extends ConsumerState<VoiceloonDemoPage> {
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  int balloonRaiseCount = 0;
  int counter = 0;
  double threshold = 65.0;
  int numberOfTrials = 1;
  bool showWellDoneText = false;
  late ConfettiController _confettiController;
  final AudioPlayer player = AudioPlayer();
  bool _isPaused = false;
  bool _vibrationEnabled = false;
  double promptTextOpacity = 1.0;
  bool _showGame = false;
  @override
  void initState() {
    super.initState();
    _loadVibrationSetting();
    _playSound('playbutton.mp3', player);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    player.dispose();
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

  void startGame() {
    setState(() {
      _showGame = true;
    });
    start();

    disappearText();
    _playSound('blow_the_balloon.mp3', player);
  }

  void disappearText() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      promptTextOpacity = 0.0;
    });
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

        showCongratsDialog();
        stop();
      }
    }
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const VoiceloonPage()));
            setState(() {
              // You can reset the state here if needed.
            });
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
      onWillPop: () async {
        if (_showGame) {
          bool result = await _onBackPressed();
          return result;
        } else {
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerbalskillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
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
                                  "Voiceloon".tr,
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
                                        'assets/images/voiceloon.jpeg',
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
                                                  const VoiceloonPage()));
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
                              balloonHeight /
                                  2, // Center the balloon horizontally
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
                              blastDirectionality:
                                  BlastDirectionality.explosive,
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

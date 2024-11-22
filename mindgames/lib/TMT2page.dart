import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/Levels_screen.dart';
import 'package:mindgames/TMTResult.dart';
import 'package:mindgames/TMTinfoscreen.dart';
import 'package:mindgames/TMTnode.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/config/easy_tmt_B_config.dart';
import 'package:mindgames/config/hard_tmt_B_config.dart';
import 'package:mindgames/config/medium_tmt_B_config.dart';
import 'package:mindgames/config/tmt_B_config.dart';
import 'package:mindgames/motorskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class TMTpage2 extends ConsumerStatefulWidget {
  final Difficulty difficulty;
  final int secondsElapsedTaskA;
  final int wrongNodeImageCountTaskA;
  final int correctNodeCountTaskA;
  final String status;
  final DateTime sessionId;
  final double accuracyTaskA;
  const TMTpage2(
      {super.key,
      required this.difficulty,
      required this.secondsElapsedTaskA,
      required this.wrongNodeImageCountTaskA,
      required this.correctNodeCountTaskA,
      required this.status,
      required this.sessionId,
      required this.accuracyTaskA});

  @override
  ConsumerState<TMTpage2> createState() => _TMTpage2State();
}

class _TMTpage2State extends ConsumerState<TMTpage2> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  bool showPartBText = true;
  bool showNodes = false;
  bool gameStarted = false;
  List<int> tappedNodes = [];
  List<Offset> linePoints = [];
  List<bool> nodeTappedCorrectly = List<bool>.generate(25, (index) => false);
  List<Color> textColors =
      List<Color>.generate(25, (index) => Colors.white); // Default text color
  List<Color> nodeColors =
      List<Color>.generate(25, (index) => const Color(0xFF309092));
  // Variables for image overlay
  bool showOverlay = false;
  double overlayLeft = 0;
  double overlayTop = 0;
  final Random _random = Random();
  int correctNodeCount = 0;
  int timeLimit = 300;
  Timer? gameTimer;
  int secondsElapsed = 0;

  int wrongNodeImageCount = 0; // Added variable to count wrong node image shown

  List<Map<String, dynamic>> gameData = [];

  final AudioCache _audioCache = AudioCache();

  final player = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  late ConfettiController _confettiController;

  late List<Map<String, dynamic>> nodeList;

  @override
  void initState() {
    super.initState();
    // Start a timer to hide the "PART A" text after 1 second
    Timer(const Duration(seconds: 1), () {
      setState(() {
        showPartBText = false;
        showNodes =
            true; // Assuming nodes should appear after PART A text hides
        // startGameTimer();
      });
    });

    gameData.add({
      'part': 'A',
      'status': widget.status,
      'correctNodeTapped': widget.correctNodeCountTaskA,
      'incorrectNodeTapped': widget.wrongNodeImageCountTaskA,
      'timeTaken': widget.secondsElapsedTaskA,
      'accuracy': widget.accuracyTaskA
    });

    _loadSoundSetting();
    _loadVibrationSetting();
    _preloadAudio();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    _setGameParameters(widget.difficulty);
  }

  void _setGameParameters(Difficulty difficulty) {
    setState(() {
      if (difficulty == Difficulty.easy) {
        nodeList = easyNodeList[_random.nextInt(easyNodeList.length)];
      } else if (difficulty == Difficulty.medium) {
        nodeList = mediumNodeList[_random.nextInt(mediumNodeList.length)];
      } else if (difficulty == Difficulty.hard) {
        nodeList = hardNodeList[_random.nextInt(hardNodeList.length)];
      }
    });
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  void _preloadAudio() {
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      print('Sound pre-initialized');
    });
  }

  void _playSound(String fileName) {
    if (_soundEnabled) {
      _playSound(fileName);
    }
  }

  void showGameCompletedDialog() {
    _confettiController.play();
    showDialog(
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
                height: screenWidth * 0.4,
                width: screenHeight * 0.6,
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
                            fontSize: screenWidth * 0.030,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "You nailed it!".tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.028,
                            color: const Color(0xFF309092),
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/prize.png',
                        width: screenWidth * 0.08,
                      ),
                      Text(
                        'Response Time: '.tr +
                            convertToNepaliNumbers('$secondsElapsed ') +
                            ' sec'.tr,
                        // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                // _playSound('playbutton.mp3');
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MotorskillsPage()), // Navigate to Motor skills page
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff309092),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: screenWidth * 0.03),
                                  )),
                            ),
                          ])
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
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
                height: screenWidth * 0.4,
                width: screenHeight * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Game Over!'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.030,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "Time's up".tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.028,
                            color: const Color(0xFF309092),
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/prize.png',
                        width: screenWidth * 0.08,
                      ),
                      Text(
                        'Response Time: '.tr +
                            convertToNepaliNumbers('$secondsElapsed'),
                        // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                // _playSound('playbutton.mp3');
                                Navigator.pop(context, true);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MotorskillsPage()), // Navigate to Motor skills page
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff309092),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: screenWidth * 0.03),
                                  )),
                            ),
                          ])
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }

  List<TMTNode> generateNodes(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<TMTNode> listOfNodes = nodeList.map((node) {
      int index = nodeList.indexOf(node);
      return TMTNode(
        number: node["number"],
        text: convertToNepaliNumbers(node["text"]),
        xPosition: screenWidth * node["xPosition"],
        yPosition: screenHeight * node["yPosition"],
        onTap: handleTap,
        color: nodeColors[index],
        textcolor: textColors[index],
      );
    }).toList();

    return listOfNodes;
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
      if (secondsElapsed >= timeLimit) {
        stopGameTimer();
        double accuracy =
            (correctNodeCount - wrongNodeImageCount) / nodeList.length * 100;
        gameData.add({
          'part': 'B',
          'status': 'Not completed',
          'correctNodeTapped': correctNodeCount,
          'incorrectNodeTapped': wrongNodeImageCount,
          'timeTaken': secondsElapsed,
          'accuracy': accuracy,
        });
        cloudStoreService.addTMTResult(TMTResult(
          userId: selectedChildUserId,
          level: 'TMT',
          difficulty: widget.difficulty,
          sessionId: widget.sessionId,
          accuracy: (widget.accuracyTaskA + accuracy) / 2,
          averageTime: (widget.secondsElapsedTaskA + secondsElapsed) / 2,
          gameData: gameData,
        ));
        showGameOverDialog();
      }
    });
  }

  void stopGameTimer() {
    gameTimer?.cancel();
  }

  Widget _buildOptionRow(IconData icon, String text, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
        margin: const EdgeInsets.symmetric(
            vertical: 4), // Add vertical margin for spacing between option rows
        decoration: BoxDecoration(
          color: const Color(0xFF309092),
          borderRadius: BorderRadius.circular(25),
          // Example border color, you can change it
        ),
        child: AnimatedButton(
          height: screenHeight * 0.12,
          width: screenWidth * 0.3,
          color: const Color(0xFF309092),
          onPressed: () {
            if (text == 'Resume'.tr) {
              Navigator.pop(context, false);
            } else if (text == 'Sound'.tr) {
              print('Change sound');
            } else if (text == 'Instructions'.tr) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TMTinfoscreen(
                    shownWhen: 'in-game',
                  ),
                ),
              );
            } else if (text == 'Quit'.tr) {
              Navigator.pop(context, true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MotorskillsPage()),
              );
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.027,
                    fontWeight: FontWeight.bold,
                  ), // Set text color to white
                ),
                Icon(
                  icon,
                  color: Colors.white,
                  size: screenWidth * 0.04, // Set text color to white
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> _onBackPressed() async {
    double screenWidth = MediaQuery.of(context).size.width;

    gameTimer!.cancel();
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
          side: const BorderSide(
            color: Colors.black,
            width: 4.0,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pause Menu'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF309092),
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildOptionRow(Icons.play_arrow, 'Resume'.tr, context),
              _buildOptionRow(Icons.volume_up, 'Sound'.tr, context),
              _buildOptionRow(Icons.info, 'Instructions'.tr, context),
              _buildOptionRow(Icons.exit_to_app, 'Quit'.tr, context),
            ],
          ),
        ),
      ),
    );

    if (result == false) {
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          secondsElapsed++;
        });
        if (secondsElapsed >= timeLimit) {
          stopGameTimer();
          // Show game over dialog when time reaches 100 seconds
          showGameOverDialog();
        }
      });
    }

    // pause the timer based on when the game is paused, and resume it back when we press the resume game button
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // Use MediaQuery to get screen width and height
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;

          // Adjust UI elements based on screen size
          double nodeSize =
              screenWidth * 0.05; // Node size relative to screen width
          double nodeSpacing = screenWidth *
              0.02; // Spacing between nodes relative to screen width
          return OrientationBuilder(
            builder: (context, orientation) {
              print('switching to landscape tmt2');
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
              return Stack(children: [
                Image.asset(
                  'assets/images/balloon_background.jpeg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      // Display Start button and Text
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (showPartBText)
                              Center(
                                child: Text(
                                  'PART B'.tr,
                                  style: TextStyle(
                                    color: const Color(0xFF309092),
                                    fontSize: screenWidth * 0.030,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (showNodes)
                        Stack(children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: ClipRRect(
                              child: SvgPicture.asset(
                                'assets/images/timer_container.svg',
                                fit: BoxFit.cover,
                                width: screenWidth * 0.06,
                                colorFilter: const ColorFilter.mode(
                                    Color.fromARGB(255, 21, 173, 184),
                                    BlendMode.srcIn),
                                // Ensure the image covers the entire area of the Container
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenHeight * 0.03,
                                  left: screenWidth * 0.010),
                              child: Text(
                                '${convertToNepaliNumbers((timeLimit - secondsElapsed).toString())}s',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.016,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]),

                      if (showNodes)
                        Positioned.fill(
                          child: Stack(
                            children: [
                              ...drawLines(),
                              ...generateNodes(context),
                            ],
                          ),
                        ),
                      if (showOverlay)
                        Positioned(
                          left: overlayLeft,
                          top: overlayTop,
                          child: Image.asset(
                            'assets/images/54.png', // Change this to your image path
                            width: screenWidth * 0.1, // Adjust width as needed
                            height:
                                screenWidth * 0.1, // Adjust height as needed
                          ),
                        ),
                      Visibility(
                        visible: true,
                        child: Positioned(
                          right: 20,
                          child: AnimatedButton(
                            height: screenWidth * 0.06,
                            width: screenWidth * 0.06,
                            color: Colors.white,
                            onPressed: () {
                              _onBackPressed();
                            },
                            enabled: true,
                            shadowDegree: ShadowDegree.light,
                            child: const Icon(
                              Icons.pause,
                              color: Colors.black,
                              size: 25.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            },
          );
        }),
      ),
    );
  }

  // void handleTap(int nodeNumber) {
  //   // Check if the tapped node is the first node or the next in the sequence
  //   if ((tappedNodes.isEmpty && nodeNumber == 1) ||
  //       (tappedNodes.isNotEmpty && nodeNumber == tappedNodes.last + 1)) {
  //     // Start the timer when the first node is tapped
  //     if (tappedNodes.isEmpty && nodeNumber == 1) {
  //       if (_vibrationEnabled) {
  //         Vibration.vibrate(
  //           duration: 100,
  //           amplitude: 10,
  //         );
  //       }
  //       startGameTimer();
  //       setState(() {
  //         gameStarted = true;
  //       });
  //     }

  //     setState(() {
  //       tappedNodes.add(nodeNumber);
  //       print('Tapped Nodes: $tappedNodes');

  //       // Add line points only if more than one node is tapped
  //       if (tappedNodes.length > 1) {
  //         int lastNode = tappedNodes[tappedNodes.length - 2];
  //         linePoints.add(Offset(getXPosition(nodeList[lastNode - 1]),
  //             getYPosition(nodeList[lastNode - 1]))); // Add start point
  //         linePoints.add(Offset(getXPosition(nodeList[nodeNumber - 1]),
  //             getYPosition(nodeList[nodeNumber - 1]))); // Add end point
  //         print('Line Points: $linePoints');
  //       }

  //       // Check if all nodes are tapped
  //       if (tappedNodes.length == nodeList.length) {
  //         stopGameTimer();
  //         // Show game over dialog
  //         double accuracy =
  //             (nodeList.length - wrongNodeImageCount) / nodeList.length * 100;
  //         gameData.add({
  //           'part': 'B',
  //           'status': 'Completed',
  //           'correctNodeTapped': nodeList.length,
  //           'incorrectNodeTapped': wrongNodeImageCount,
  //           'timeTaken': secondsElapsed,
  //           'accuracy': accuracy,
  //         });

  //         cloudStoreService.addTMTResult(TMTResult(
  //           userId: selectedChildUserId,
  //           level: 'TMT',
  //           difficulty: widget.difficulty,
  //           sessionId: widget.sessionId,
  //           accuracy: (widget.accuracyTaskA + accuracy) / 2,
  //           averageTime: (widget.secondsElapsedTaskA + secondsElapsed) / 2,
  //           gameData: gameData,
  //         ));
  //         showGameCompletedDialog();
  //       }
  //     });
  //   } else {
  //     // Wrong node tapped, show error message
  //     print('Wrong node tapped');
  //     // Increment the count of wrong node image shown
  //     setState(() {
  //       wrongNodeImageCount++;
  //     });

  //     // Display image overlay
  //     setState(() {
  //       showOverlay = true;
  //       overlayLeft =
  //           getXPosition(nodeList[nodeNumber - 1]) - 12; // Adjust as needed
  //       overlayTop =
  //           getYPosition(nodeList[nodeNumber - 1]) - 12; // Adjust as needed
  //     });

  //     // Hide image overlay after 500 milliseconds
  //     Future.delayed(const Duration(milliseconds: 200), () {
  //       setState(() {
  //         showOverlay = false;
  //       });
  //     });
  //   }

  //   // Check if the tapped node is correct and print a message
  //   if (!showOverlay) {
  //     print('Correct node tapped');
  //     if (_vibrationEnabled) {
  //       Vibration.vibrate(
  //         duration: 100,
  //         amplitude: 10,
  //       );
  //     }
  //     nodeColors[nodeNumber - 1] = Colors.white;
  //     textColors[nodeNumber - 1] = const Color(0xFF309092);
  //     setState(() {
  //       correctNodeCount++;
  //     });
  //   }
  // }

  void handleTap(int nodeNumber) {
    // Check if the tapped node is the first node or the next in the sequence
    if ((tappedNodes.isEmpty && nodeNumber == 1) ||
        (tappedNodes.isNotEmpty && nodeNumber == tappedNodes.last + 1)) {
      // Start the timer when the first node is tapped
      if (tappedNodes.isEmpty && nodeNumber == 1) {
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }
        startGameTimer();
        setState(() {
          gameStarted = true;
        });
      }

      setState(() {
        tappedNodes.add(nodeNumber);
        print('Tapped Nodes: $tappedNodes');

        // Add line points only if more than one node is tapped
        if (tappedNodes.length > 1) {
          int lastNode = tappedNodes[tappedNodes.length - 2];
          linePoints.add(Offset(getXPosition(nodeList[lastNode - 1]),
              getYPosition(nodeList[lastNode - 1]))); // Add start point
          linePoints.add(Offset(getXPosition(nodeList[nodeNumber - 1]),
              getYPosition(nodeList[nodeNumber - 1]))); // Add end point
          print('Line Points: $linePoints');
        }

        // Check if all nodes are tapped
        if (tappedNodes.length == nodeList.length) {
          stopGameTimer();
          // Show game over dialog
          double accuracy =
              (nodeList.length - wrongNodeImageCount) / nodeList.length * 100;
          gameData.add({
            'part': 'B',
            'status': 'Completed',
            'correctNodeTapped': nodeList.length,
            'incorrectNodeTapped': wrongNodeImageCount,
            'timeTaken': secondsElapsed,
            'accuracy': accuracy,
          });

          cloudStoreService.addTMTResult(TMTResult(
            userId: selectedChildUserId,
            level: 'TMT',
            difficulty: widget.difficulty,
            sessionId: widget.sessionId,
            accuracy: (widget.accuracyTaskA + accuracy) / 2,
            averageTime: (widget.secondsElapsedTaskA + secondsElapsed) / 2,
            gameData: gameData,
          ));
          showGameCompletedDialog();
        }
      });
    } else {
      // Check if the tapped node is part of a drawn line
      bool isNodeConnected = false;

      // Loop through the linePoints and check if the node is part of the connected lines
      for (int i = 0; i < linePoints.length; i += 2) {
        // linePoints are pairs, check if the node is in the start or end point of any line
        if (linePoints[i].dx == getXPosition(nodeList[nodeNumber - 1]) &&
                linePoints[i].dy == getYPosition(nodeList[nodeNumber - 1]) ||
            linePoints[i + 1].dx == getXPosition(nodeList[nodeNumber - 1]) &&
                linePoints[i + 1].dy ==
                    getYPosition(nodeList[nodeNumber - 1])) {
          isNodeConnected = true;
          break;
        }
      }

      // If the node is not connected to a line, show the error overlay
      if (!isNodeConnected) {
        // Wrong node tapped, show error message
        print('Wrong node tapped');
        // Increment the count of wrong node image shown
        setState(() {
          wrongNodeImageCount++;
        });

        // Display image overlay
        setState(() {
          showOverlay = true;
          overlayLeft =
              getXPosition(nodeList[nodeNumber - 1]) - 12; // Adjust as needed
          overlayTop =
              getYPosition(nodeList[nodeNumber - 1]) - 12; // Adjust as needed
        });

        // Hide image overlay after 500 milliseconds
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            showOverlay = false;
          });
        });
      }
    }

    // Check if the tapped node is correct and print a message
    if (!showOverlay) {
      print('Correct node tapped');
      if (_vibrationEnabled) {
        Vibration.vibrate(
          duration: 100,
          amplitude: 10,
        );
      }
      nodeColors[nodeNumber - 1] = Colors.white;
      textColors[nodeNumber - 1] = const Color(0xFF309092);
      setState(() {
        correctNodeCount++;
      });
    }
  }

  List<Widget> drawLines() {
    List<Widget> lines = [];
    for (int i = 0; i < tappedNodes.length - 1; i++) {
      int currentNode = tappedNodes[i];
      int nextNode = tappedNodes[i + 1];
      double startX = getXPosition(nodeList[currentNode - 1]) +
          20; // Adjusted for circle radius
      double startY = getYPosition(nodeList[currentNode - 1]) +
          20; // Adjusted for circle radius
      double endX = getXPosition(nodeList[nextNode - 1]) +
          20; // Adjusted for circle radius
      double endY = getYPosition(nodeList[nextNode - 1]) +
          20; // Adjusted for circle radius

      lines.add(Positioned(
        top: 0,
        left: 0,
        child: CustomPaint(
          painter: LinePainter(Offset(startX, startY), Offset(endX, endY)),
        ),
      ));
    }
    return lines;
  }

  double getXPosition(Map<String, dynamic> node) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth * node['xPosition'];
  }

  double getYPosition(Map<String, dynamic> node) {
    double screenHeight = MediaQuery.of(context).size.height;

    return screenHeight * node['yPosition'];
  }

  @override
  void dispose() {
    print('switching to portrait');
    _confettiController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF309092)
      ..strokeWidth = 3;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/DSTDataModel.dart';
import 'package:mindgames/DSTResult.dart';
import 'package:mindgames/LevelCompletionHandler.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/widgets/gradient_text.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class EasyPage extends ConsumerStatefulWidget {
  const EasyPage({Key? key}) : super(key: key);

  @override
  _EasyPageState createState() => _EasyPageState();
}

class _EasyPageState extends ConsumerState<EasyPage> {
  late final String selectedChildUserId;
  CloudStoreService cloudStoreService = CloudStoreService();
  LevelCompletionHandler? levelCompletionHandler;
  List<DSTData> dataList = [];
  bool showStartButton = true;
  bool showEndGameDialog = false;
  bool _showPopup = false;
  bool showCharactersContainer = false;
  bool showMemorizeText = false;
  List<String> characters = [];
  int currentCharacterIndex = 0;
  late Timer timer;
  late Timer renderTimer;
  late DateTime inputStartTime;
  Set<int> selectedNumbers = <int>{};
  List<int> selectedNumbersList = [];
  List<String> results = []; // To store results
  String _popupText = '';
  int sequenceLength = 2;
  int quitdialogStartTime = 0;
  int quitdialogEndTime = 0;
  int accumulatedDialogTime = 0;
  int characterShowTime = 0;
  int characterEndTime = 0;
  DateTime sessionId = DateTime.now();

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  late ConfettiController _confettiController;

  EasyPage() {
    // Preload the audio file during app initialization
    _audioCache.load('correct.mp3').then((_) {
      print(
          'right sound pre-initialized'); // Log a message when preloading is complete
    });
    _audioCache.load('wrong.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('GameOverDialog.mp3').then((_) {
      print('gameover sound pre-loaded');
    });
    _audioCache.load('PauseTap.mp3').then((_) {
      print('Pause sound pre-loaded');
    });
  }

  int maxSequenceLength = 10;
  int trialId = 0;
  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
    _loadVibrationSetting();
    _preloadAudio();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
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

  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    _confettiController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    print('I was triggered');
    _playSound('PauseTap.mp3', player);
    bool? result;
    // Function to display the quit dialog
    Future<bool?> displayQuitDialog() async {
      bool? result = await showDialog<bool>(
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
            quitDestinationPage: const ExecutiveskillsPage(),
          ),
        ),
      );
      return result;
    }

    // Cancel timers if they are active
    if (timer.isActive) {
      timer.cancel();
    }
    if (renderTimer.isActive) {
      renderTimer.cancel();
    }

    // Check for different scenarios where the game can be paused
    if (showMemorizeText) {
      print('Paused at prompt');
      result = await displayQuitDialog();
      if (result == false) {
        renderTimer = Timer(const Duration(milliseconds: 500), () {
          showMemorizeText = false;
          characters = generateRandomCharacters(sequenceLength);
          currentCharacterIndex = 0;
          startTimer();
          showCharactersContainer = true;
        });
      }
    } else if (showCharactersContainer) {
      print('Paused while characters were being shown');
      characterEndTime = DateTime.now().millisecondsSinceEpoch;

      result = await displayQuitDialog();
      if (result == false) {
        print('Digit time Start: $characterShowTime');
        print('Digit time End: $characterEndTime');
        print(
            'Character was paused at: ${characterEndTime - characterShowTime}');
        startTimer();
      }
    } else if (!showStartButton && !_showPopup) {
      print('Paused while taking input');
      quitdialogStartTime = DateTime.now().millisecondsSinceEpoch;
      result = await displayQuitDialog();
      if (result == false) {
        quitdialogEndTime = DateTime.now().millisecondsSinceEpoch;
        accumulatedDialogTime += quitdialogEndTime - quitdialogStartTime;
      }
    }

    // Return the result
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: screenWidth * 0.18,
                          width: screenWidth * 0.18,
                          child: CircularChart(
                              chartData: ChartData(
                                  'DST',
                                  (sequenceLength - 2) /
                                      (maxSequenceLength - 2) *
                                      100,
                                  Colors.black),
                              fontSize: screenWidth * 0.029),
                        ), // Placeholder for alignment
                        GestureDetector(
                          onTap: () {
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8),
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
                                    onPressed: _onBackPressed,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    //title
                    Visibility(
                      visible: !showEndGameDialog && showStartButton,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Digit Dazzle'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF309092),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showStartButton)
                      GestureDetector(
                        onTap: () {
                          RenderSequence();
                        },
                        child: Container(
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/mainbutton.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  child: Text("Start".tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                    //memorize text
                    if (showMemorizeText)
                      Visibility(
                        visible: !showEndGameDialog,
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenWidth * 0.35,
                          child: Center(
                            child: Text(
                              'Memorize the digits!'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.075,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF309092),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!showStartButton && showCharactersContainer)
                      Visibility(
                        visible: !showEndGameDialog,
                        child: Align(
                          alignment: Alignment.center,
                          child: Material(
                            elevation: 15,
                            borderRadius: BorderRadius.circular(25),
                            child: AnimatedOpacity(
                              duration: const Duration(seconds: 1),
                              opacity: showCharactersContainer ? 1.0 : 0.0,
                              child: Container(
                                width: baseSize * 0.8,
                                height: baseSize * 0.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: Color(0xFF37B197), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: GradientText(
                                    text: characters[currentCharacterIndex].tr,
                                    fontSize: screenWidth * 0.6,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF37B197),
                                        Color(0xFF309092),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // number pad
                    if (!showStartButton &&
                        !showCharactersContainer &&
                        !showMemorizeText &&
                        !_showPopup &&
                        !showEndGameDialog)
                      Container(
                        width: screenWidth * 0.6,
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          children: List.generate(9, (index) {
                            int digit = index + 1;
                            return NumberBuilder(digit);
                          })
                            ..addAll([
                              NumberBuilder(-1),
                              NumberBuilder(0),
                              NumberBuilder(-2)
                            ]),
                        ),
                      ),

                    // Flexible(
                    //   child: SizedBox(height: screenHeight * 0.015),
                    // ),

                    // Wrap containing the chips

                    SizedBox(height: screenHeight * 0.055),
                    Container(
                      width: screenWidth,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5.0, // Horizontal space between avatars
                        runSpacing:
                            3.0, // Vertical space between rows of avatars
                        children: selectedNumbersList.map((number) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade600,
                                  offset: Offset(4, 4),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-1, -1),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: screenWidth *
                                  0.04, // Adjust radius as needed for avatar size
                              backgroundColor: Colors.white,
                              child: Text(
                                '$number'.tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    Visibility(
                      visible: selectedNumbersList.length > 0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          onPressed: checkAnswer,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF309092),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Submit'.tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_showPopup)
                      Center(
                        child: AnimatedOpacity(
                          opacity: _showPopup ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Center(
                            child: Image.asset(
                              _popupText == 'CORRECT'.tr
                                  ? 'assets/images/25.png'
                                  : 'assets/images/54.png',
                              height: screenHeight * 0.3,
                            ),
                          ),
                        ),
                      ),
                  ]),
            ),
          ),
        ));
  }

  Visibility NumberBuilder(int digit) {
    double screenWidth = MediaQuery.of(context).size.width;

    double circleSize = screenWidth * 0.08; // 15% of screen width
    double borderRadius = circleSize / 0.5;

    return Visibility(
      visible: digit != -1 && digit != -2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selectedNumbers.contains(digit)) {
              selectedNumbers.remove(digit);
              selectedNumbersList.remove(digit);
            } else {
              selectedNumbers.add(digit);
              selectedNumbersList.add(digit);
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(borderRadius),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              alignment: Alignment.center,
              height: circleSize,
              width: circleSize,
              decoration: BoxDecoration(
                gradient: selectedNumbers.contains(digit)
                    ? LinearGradient(
                        colors: [Color(0xFF309092), Color(0xFF50B8B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selectedNumbers.contains(digit) ? null : Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: selectedNumbers.contains(digit)
                    ? Border.all(color: Colors.white, width: 2.0)
                    : Border.all(color: Colors.transparent),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$digit'.tr,
                    style: TextStyle(
                      fontSize: screenWidth *
                          0.08, // Responsive font size based on screen width
                      fontWeight: FontWeight.bold,
                      color: selectedNumbers.contains(digit)
                          ? Colors.grey[200]
                          : Color(0xFF309092),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> generateRandomCharacters(int size) {
    if (size <= 0 || size > 10) {
      throw ArgumentError('Size must be between 1 and 10');
    }

    List<String> numbers = List.generate(9, (index) => index.toString());
    numbers.shuffle();
    return numbers.sublist(0, size);
  }

  void startTimer() {
    int index = currentCharacterIndex;
    print('Characters: $characters');
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // if the
        if (index < characters.length) {
          characterShowTime = DateTime.now().millisecondsSinceEpoch;
          print('Character was shown at $characterShowTime');
          print('showing ${characters[index]}');
          currentCharacterIndex = index++;
        } else {
          timer.cancel();
          showCharactersContainer = false;
          inputStartTime = DateTime.now();
          quitdialogEndTime = 0;
          quitdialogStartTime = 0;
        }
      });
    });
  }

  // Check if selected numbers match the displayed sequence
  void checkAnswer() async {
    if (quitdialogStartTime == 0 || quitdialogEndTime == 0) {
      accumulatedDialogTime = 0;
    }
    int elapsedTime = DateTime.now().difference(inputStartTime).inMilliseconds -
        accumulatedDialogTime;
    print('Accumulated pause time: $accumulatedDialogTime');
    print('time taken for input: $elapsedTime');
    setState(() {
      trialId++;
      _showPopup = true;
      // if correct response is provided
      if (selectedNumbersList.join() == characters.join()) {
        _playSound('right.mp3', player1);
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }
        results.add("Correct!");
        _popupText = 'CORRECT'.tr;
      }
      // if incorrect response is provided
      else {
        _playSound('wrong.mp3', player);
        _popupText = 'WRONG'.tr;

        results.add("Incorrect!"); // Add "Incorrect!" message to results list
      }

      DSTData dstData = DSTData(
        userId: selectedChildUserId,
        sessionId: sessionId,
        trialId: trialId,
        sequenceGiven: characters.join(),
        sequenceEntered: selectedNumbersList.join(),
        result: selectedNumbersList.join() == characters.join()
            ? 'Correct'
            : 'Incorrect',
        responseTime: elapsedTime,
      );

      dataList.add(dstData);
    });

    // show another sequence of numbers

    selectedNumbers.clear(); // Clear selected numbers
    selectedNumbersList.clear(); // Clear selected numbers list

    // now check for majority
    if (results.length == 2 || results.length == 3) {
      String mostCommonResult =
          mostCommonString(results); // Find most common result
      print("Most common result: $mostCommonResult");

      // move to next level
      if (mostCommonResult == "Correct!") {
        setState(() {
          _showPopup = true;
          sequenceLength++;
        });

        // if all levels have been played, quit the game
        if (sequenceLength == maxSequenceLength) {
          Timer(const Duration(milliseconds: 500), () {
            _showGameOverDialog();
          });
        }
        results = [];
      }
      // game over
      else if (mostCommonResult == "Incorrect!") {
        setState(() {
          _showPopup = true;
        });
        // If most common result is incorrect, show game over dialog
        Timer(const Duration(milliseconds: 500), () {
          _showGameOverDialog();
        });
      }
    }
    Timer(const Duration(milliseconds: 500), () {
      RenderSequence();
    });
  }

  void RenderSequence() {
    setState(() {
      showStartButton = false;
      showMemorizeText = true;
      _showPopup = false;
      renderTimer = Timer(const Duration(milliseconds: 500), () {
        showMemorizeText = false;
        characters = generateRandomCharacters(sequenceLength);
        currentCharacterIndex = 0;
        startTimer();
        showCharactersContainer = true;
      });
    });
  }

  void _showGameOverDialog() async {
    _confettiController.play();
    _playSound('GameOverDialog.mp3', player);
    // _databaseHelper.insertDSTData(dataList);
    // List<Map<String, dynamic>> data = dataList.map((e) => e.toMap()).toList();
    // levelCompletionHandler!.createMindParkDirectoryAndSaveCSV(data).then((_) {
    //   print('Level completion data saved to CSV.');
    // });
    cloudStoreService.addDSTData(dataList);
    double spanPercentage = (sequenceLength - 1) / 7 * 100;
    cloudStoreService.addDSTResult(DSTResult(
      userId: selectedChildUserId,
      level: 'DST',
      sessionId: sessionId,
      score: sequenceLength == 2 ? 0 : sequenceLength - 1,
      span: sequenceLength == 2
          ? 0
          : spanPercentage >= 100
              ? 100
              : spanPercentage,
    ));
    setState(() {
      showEndGameDialog = true;
    });
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
                        padding: const EdgeInsets.all(10.0),
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
                        '${'Score: '.tr}${sequenceLength == 2 ? convertToNepaliNumbers('0') : convertToNepaliNumbers('${sequenceLength - 1}')}', // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                _playSound('playbutton.mp3', player);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ExecutiveskillsPage()), // Navigate to LevelScreen
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xff309092),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: screenWidth * 0.07),
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
}

String mostCommonString(List<String> strings) {
  if (strings.isEmpty) {
    return 'Equal';
  }

  Map<String, int> count = {};

  // Count occurrences of each string
  strings.forEach((string) {
    count[string] = (count[string] ?? 0) + 1;
  });

  int correctCount = count['Correct!'] ?? 0;
  int incorrectCount = count['Incorrect!'] ?? 0;

  if (correctCount > incorrectCount) {
    return 'Correct!';
  } else if (incorrectCount > correctCount) {
    return 'Incorrect!';
  } else {
    return 'Equal';
  }
}

import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedBuzzer.dart';
import 'package:mindgames/CPTDataModel.dart';
import 'package:mindgames/CPTResult.dart';
import 'package:mindgames/LevelCompletionHandler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

enum TimerType {
  Fixation,
  Words,
  None,
}

class CPTPage extends ConsumerStatefulWidget {
  const CPTPage({super.key});

  @override
  ConsumerState<CPTPage> createState() => _CPTPageState();
}

class _CPTPageState extends ConsumerState<CPTPage> {
  late final String selectedChildUserId;
  CloudStoreService cloudStoreService = CloudStoreService();
  LevelCompletionHandler? levelCompletionHandler;
  List<CPTData> dataList = [];
  String _popupText = '';
  bool _showStartButton = true;
  bool _showFixation = true;
  int _currentWordIndex = 0;
  late Timer _fixationTimer;
  late Timer _wordsTimer;
  bool _isDialogVisible = false;
  bool _showPopup = false;
  final int _totalWords = 50;
  int score = 0;
  double proportions = 0.2;
  bool _isPopupVisible = false;
  bool _buzzerEnabled = false;
  int _fixationStartTime = 0;
  int _fixationEndTime = 0;
  int _elapsedFixationTime = 0;
  int _wordsStartTime = 0;
  int _wordsEndTime = 0;
  int _elapsedWordsTime = 0;

  int dialogBoxAppearTime = 0;
  int dialogBoxDisappearTime = 0;
  int pauseTime = 0;

  int commissionErrorCount = 0;
  int omissionErrorCount = 0;
  DateTime sessionId = DateTime.now();

  TimerType _currentTimerType = TimerType.None;

  late List<String>? characters;

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  late ConfettiController _confettiController;

  CPTPage() {
    // Preload the audio file during app initialization
    _audioCache.load('correct.mp3').then((_) {
      print(
          'right sound pre-initialized'); // Log a message when preloading is complete
    });
    _audioCache.load('wrong.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('GaneOverDialog.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('PauseTap.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('playbutton.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('verbalgood.mp3').then((_) {
      print('verbal good sound pre-loaded');
    });
  }

  List<String> generateListWithProportion(int length, double proportion) {
    if (proportion < 0 || proportion > 1) {
      throw ArgumentError('Proportion must be between 0 and 1.');
    }

    int numberOfX = (length * proportion).round();

    List<String> list = [];

    for (int i = 0; i < numberOfX; i++) {
      list.add('X');
    }

    for (int i = numberOfX; i < length; i++) {
      String randomChar;
      do {
        randomChar = String.fromCharCode(Random().nextInt(26) + 65);
      } while (randomChar == 'X');

      list.add(randomChar);
    }

    list.shuffle(Random());

    return list;
  }

  @override
  void initState() {
    super.initState();
    characters = generateListWithProportion(_totalWords, proportions);
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
    _confettiController.dispose();
    super.dispose();
  }

  void _changeWord() {
    print(characters);
    _displayFixation();
  }

  void _displayFixation() {
    _fixationStartTime = DateTime.now().millisecondsSinceEpoch;
    dialogBoxAppearTime = 0;
    dialogBoxDisappearTime = 0;
    _elapsedFixationTime = 0;
    _currentTimerType = TimerType.Fixation;

    print("display Fixation");
    if (_isDialogVisible) {
      return; // Do nothing if dialog is visible
    }
    const halfSecond = Duration(milliseconds: 500);
    setState(() {
      _showFixation = true;
    });
    _fixationTimer = Timer(halfSecond, () {
      setState(() {
        _showFixation = false;
        _buzzerEnabled = true;
      });
      _displayWords();
    });
  }

  int? wordDisplayStartTime;
  List<int> notXDurations = [];

  void _displayWords() {
    _showPopup = false;
    dialogBoxAppearTime = 0;
    dialogBoxDisappearTime = 0;
    _elapsedWordsTime = 0;
    _currentTimerType = TimerType.Words;
    _wordsStartTime = DateTime.now().millisecondsSinceEpoch;

    print("display Words");
    if (_isDialogVisible) {
      return; // Do nothing if dialog is visible
    }

    wordDisplayStartTime = DateTime.now().millisecondsSinceEpoch;
    const twoSecond = Duration(seconds: 2);
    _wordsTimer = Timer(twoSecond, () {
      setState(() {
        _showPopup = true;
        _buzzerEnabled = false;

        String currentLetter = characters![_currentWordIndex];
        if (currentLetter == 'X') {
          _popupText = 'CORRECT'.tr;
          _playSound('right.mp3', player1);
          if (_vibrationEnabled) {
            Vibration.vibrate(
              duration: 100,
              amplitude: 10,
            );
          }

          score++; // Increment score
        } else {
          // other letters are shown and no input is given, hence omission error
          _popupText = 'WRONG'.tr;
          _playSound('wrong.mp3', player);
          omissionErrorCount++;
        }

        CPTData cptData = CPTData(
            userId: selectedChildUserId,
            sessionId: sessionId,
            trialId: _currentWordIndex + 1,
            letter: currentLetter,
            result: currentLetter == 'X' ? 'Correct' : 'Incorrect',
            responseTime: 2000);
        print('Adding to cpt data');
        dataList.add(cptData);
      });

      if (_currentWordIndex == _totalWords - 1) {
        const halfSecond = Duration(milliseconds: 500);
        Timer(halfSecond, () {
          _showGameOverDialog();
          _playSound('GameOverDialog.mp3', player);
          setState(() {
            _showPopup = false;
          });
        });
        // Corrected condition
        // Display "Game Over" popup after all words are shown
      }

      if (_currentWordIndex < _totalWords - 1) {
        _currentWordIndex = (_currentWordIndex + 1);
        // Adjusted condition
        // Continue the game if not reached the total number of words

        _displayFixation();
      }
    });
  }

  void _checkAnswer() async {
    if (_isDialogVisible || _showFixation || !_buzzerEnabled) {
      return; // Don't check the answer if dialog is visible, fixation is displayed, or buzzer is disabled
    }

    _fixationTimer.cancel();
    _wordsTimer.cancel();
    setState(() {
      String letter = characters![_currentWordIndex];
      final correctBuzzerTappedTime = DateTime.now().millisecondsSinceEpoch;
      if (dialogBoxAppearTime > 0 && dialogBoxDisappearTime > 0) {
        pauseTime = dialogBoxDisappearTime - dialogBoxAppearTime;
      } else {
        pauseTime = 0;
      }
      print('this is being deducted from the pause time: ' +
          pauseTime.toString());
      final duration =
          correctBuzzerTappedTime - wordDisplayStartTime! - pauseTime;
      if (letter != 'X') {
        score++;
        _popupText = 'CORRECT'.tr;
        _playSound('right.mp3', player1);
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }

        if (wordDisplayStartTime != null) {
          notXDurations.add(duration);
          print('Time taken to tap the buzzer: $duration milliseconds');
        } else {
          print('Error: wordDisplayStartTime is null.');
        }
      } else {
        commissionErrorCount++;
        _popupText = 'WRONG'.tr;
        _playSound('wrong.mp3', player);
      }
      CPTData cptData = CPTData(
          userId: selectedChildUserId,
          sessionId: sessionId,
          trialId: _currentWordIndex + 1,
          letter: letter,
          result: letter != 'X' ? 'Correct' : 'Incorrect',
          responseTime: duration);
      print('Adding to cpt data');
      dataList.add(cptData);
      _showPopup = true;
      _isPopupVisible = true;
      _buzzerEnabled = false;
    });

    await Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {
        _showPopup = false;
        _isPopupVisible = false;
        // Show fixation point and then words
      });
      _displayFixation();
    });
    _currentWordIndex++;
    if (_currentWordIndex == _totalWords) {
      // Corrected condition
      // Display "Game Over" popup after all words are shown
      _showGameOverDialog();
      _playSound('GameOverDialog.mp3', player);
    }
  }

  Future<bool> _onBackPressed() async {
    _playSound('PauseTap.mp3', player);
    print('back press was triggered');
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
            quitDestinationPage: const ExecutiveskillsPage(),
          ),
        ),
      );
    }

    if (_currentTimerType == TimerType.Fixation) {
      _fixationTimer.cancel();
      _fixationEndTime = DateTime.now().millisecondsSinceEpoch;
      _elapsedFixationTime = _fixationEndTime - _fixationStartTime;
      print('Elapsed time fixation: ' + _elapsedFixationTime.toString());

      _isDialogVisible = true;
      result = await displayQuitDialog();
      _isDialogVisible = false;

      if (result == false) {
        _fixationTimer = Timer(
          Duration(milliseconds: 500 - _elapsedFixationTime),
          () {
            setState(() {
              _showFixation = false;
              _buzzerEnabled = true;
            });
            _displayWords();
          },
        );
        _currentTimerType = TimerType.Words;
      }
    } else if (_currentTimerType == TimerType.Words) {
      dialogBoxAppearTime = DateTime.now().millisecondsSinceEpoch;
      _wordsTimer.cancel();
      _wordsEndTime = DateTime.now().millisecondsSinceEpoch;
      _elapsedWordsTime = _wordsEndTime - _wordsStartTime;
      _isDialogVisible = true;
      result = await displayQuitDialog();
      _isDialogVisible = false;

      if (result == false) {
        print('Word resumed');

        dialogBoxDisappearTime = DateTime.now().millisecondsSinceEpoch;
        _wordsTimer = Timer(
          Duration(milliseconds: 2000 - _elapsedWordsTime),
          () {
            print('Word count: ${_currentWordIndex},  ${_totalWords - 1}');
            setState(() {
              _showPopup = false;
              _buzzerEnabled = false;
              CPTData cptData = CPTData(
                  userId: selectedChildUserId,
                  sessionId: sessionId,
                  trialId: _currentWordIndex + 1,
                  letter: characters![_currentWordIndex],
                  result: characters![_currentWordIndex] == 'X'
                      ? 'Correct'
                      : 'Incorrect',
                  responseTime: 2000);
              print('Adding to cpt data');
              dataList.add(cptData);

              if (_currentWordIndex == _totalWords - 1) {
                _showGameOverDialog();
                _playSound('GameOverDialog.mp3', player);
              }
            });

            if (_currentWordIndex < _totalWords - 1) {
              _currentWordIndex++;
              _displayFixation();
            }
          },
        );
        _currentTimerType = TimerType.Fixation;
      }
    }

    return result ?? false;
  }

  void _showGameOverDialog() async {
    _confettiController.play();
    // _databaseHelper.insertCPTData(dataList);
    // List<Map<String, dynamic>> data = dataList.map((e) => e.toMap()).toList();
    // levelCompletionHandler!.createMindParkDirectoryAndSaveCSV(data).then((_) {
    //   print('Level completion data saved to CSV.');
    //});
    cloudStoreService.addCPTData(dataList);

    print('CPT Data list: ${dataList.length}');
    print('CPT Data list: $dataList');
    print(notXDurations);
    double response_time = notXDurations.isNotEmpty
        ? notXDurations.reduce((a, b) => a + b) / notXDurations.length
        : 0;
    double accuracy = (score / _totalWords * 100);
    print('Omitted letters: $omissionErrorCount');
    print('80% of letters: ${0.8 * _totalWords}');
    cloudStoreService.addCPTResult(
      CPTResult(
        userId: selectedChildUserId,
        level: 'CPT',
        sessionId: sessionId,
        accuracy: accuracy,
        responseTime: response_time,
        commissionError: (commissionErrorCount / (0.2 * _totalWords) * 100),
        omissionError: (omissionErrorCount / (0.8 * _totalWords) * 100),
        inhibitoryControl:
            100 - (commissionErrorCount / (0.2 * _totalWords) * 100),
      ),
    );
    // Show the game over dialog

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
                height: screenHeight * 0.6,
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
                            color: Color(0xFF309092),
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
                            color: Color(0xFF309092),
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/prize.png',
                        width: screenWidth * 0.2,
                      ),
                      Text(
                        'Accuracy: '.tr +
                            convertToNepaliNumbers(
                                '${accuracy.toStringAsFixed(0)}%'), // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Response Time: '.tr +
                            convertToNepaliNumbers(
                                '${response_time.toStringAsFixed(0)} ms'), // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Commission Error: '.tr +
                            convertToNepaliNumbers(
                                '${(commissionErrorCount / (0.2 * _totalWords) * 100).toStringAsFixed(0)}%'), // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Omission Error: '.tr +
                            convertToNepaliNumbers(
                                '${(omissionErrorCount / (0.8 * _totalWords) * 100).toStringAsFixed(0)}%'), // Display the score
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
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: screenWidth * 0.07,
                                    ),
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: screenWidth * 0.20,
                        width: screenWidth * 0.20,
                        child: CircularChart(
                            chartData: ChartData(
                                'CPT',
                                (_currentWordIndex) / _totalWords * 100,
                                Colors.black),
                            fontSize: screenWidth * 0.03),
                      ),
                      Visibility(
                          visible: !_showStartButton,
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
                          )),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Alert Alphas'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF309092),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        _playSound('playbutton.mp3', player);
                        _changeWord();
                        setState(() {
                          _showStartButton = false;
                        });
                      },
                      child: Visibility(
                        visible: _showStartButton,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.15,
                            child: Stack(
                              children: [
                                Center(
                                  child: ClipRRect(
                                      child: Image.asset(
                                    'assets/images/mainbutton.png',
                                    fit: BoxFit.cover,
                                  )),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    child: Text("Start".tr,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.05,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                  ),
                                )
                              ],
                            )),
                      )),
                  Center(
                    child: Container(
                      width: screenSize.height * 0.25,
                      height: screenSize.height * 0.25,
                      child: Material(
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.05),
                        elevation: 15,
                        child: Container(
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(screenSize.width * 0.05),
                          ),
                          child: _showFixation
                              ? Center(
                                  child: Visibility(
                                  visible: !_showStartButton,
                                  child: Text("+",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.095,
                                        color: Colors.black,
                                      )),
                                ))
                              : Center(
                                  child: Visibility(
                                    visible: !_showStartButton,
                                    child: Text(
                                      _isPopupVisible
                                          ? ''
                                          : characters![
                                              _currentWordIndex >= _totalWords
                                                  ? 0
                                                  : _currentWordIndex],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenSize.width * 0.095,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_showStartButton,
                    child: AnimatedBuzzer(
                      height: screenWidth * 0.35,
                      width: screenWidth * 0.35,
                      shape: BoxShape.circle,
                      color: Colors.green,
                      child: Text(
                        'PRESS'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _checkAnswer();
                      },
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height *
                        0.15, // Fixed height to prevent shifting
                    child: _showPopup
                        ? AnimatedOpacity(
                            opacity: _showPopup ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 0),
                            child: Center(
                              child: Image.asset(
                                _popupText == 'CORRECT'.tr
                                    ? 'assets/images/25.png'
                                    : 'assets/images/54.png',
                                height: screenSize.height * 0.15,
                              ),
                            ),
                          )
                        : SizedBox(),
                  )
                ],
              ))),
    );
  }
}

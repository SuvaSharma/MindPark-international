import 'package:animated_button/animated_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/StroopResult.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:developer';
import 'package:mindgames/word_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

enum TimerType {
  Fixation,
  Words,
  None,
}

TimerType _currentTimerType = TimerType.None;

class StroopTest extends ConsumerStatefulWidget {
  const StroopTest({super.key});

  @override
  ConsumerState<StroopTest> createState() => _StroopTestState();
}

class _StroopTestState extends ConsumerState<StroopTest> {
  late final String selectedChildUserId;
  CloudStoreService cloudStoreService = CloudStoreService();

  List<Word> wordList = [];
  bool _isMounted = true;
  int _currentWordIndex = 0;
  int _totalWords = 40;
  bool _showFixation = false;
  bool _isPopupVisible = false;
  bool _colorOptionsEnabled = false; // Flag to enable/disable color options

  bool _showStartButton = true;

  bool _showPopup = false;
  String _popupText = '';
  late Timer _fixationTimer;
  late Timer _wordsTimer;
  bool _isDialogVisible = false;
  int _fixationStartTime = 0;
  int _fixationEndTime = 0;
  int _elapsedFixationTime = 0;
  int _wordsStartTime = 0;
  int _wordsEndTime = 0;
  int _elapsedWordsTime = 0;
  int correctResponse = 0;
  int dialogBoxAppearTime = 0;
  int dialogBoxDisappearTime = 0;
  int pauseTime = 0;
  DateTime sessionId = DateTime.now();

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  late ConfettiController _confettiController;
  StroopTest() {
    // Preload the audio file during app initialization
    _audioCache.load('correct.mp3').then((_) {
      log('right sound pre-initialized'); // Log a message when preloading is complete
    });
    _audioCache.load('verbalgood.mp3').then((_) {
      log('verbal good sound pre-loaded');
    });
    _audioCache.load('wrong.mp3').then((_) {
      log('wrong sound pre-loaded');
    });
    _audioCache.load('GaneOverDialog.mp3').then((_) {
      log('wrong sound pre-loaded');
    });
    _audioCache.load('PauseTap.mp3').then((_) {
      log('wrong sound pre-loaded');
    });
    _audioCache.load('playbutton.mp3').then((_) {
      log('wrong sound pre-loaded');
    });
  }

  TimerType _currentTimerType = TimerType.None;

  List<Color> colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green
  ];

  @override
  void initState() {
    List<Map<String, dynamic>> wordArray = createWordArray();
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
      log('Sound pre-initialized');
    });
  }

  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  String getColorName(Color color) {
    final colorNames = {
      Colors.red: 'Red',
      Colors.blue: 'Blue',
      Colors.yellow: 'Yellow',
      Colors.green: 'Green',
    };

    return colorNames[color] ?? 'Unknown';
  }

  List<Map<String, dynamic>> compatibleWords = [
    {"word": "Red", "color": Colors.red},
    {"word": "Blue", "color": Colors.blue},
    {"word": "Yellow", "color": Colors.yellow},
    {"word": "Green", "color": Colors.green}
  ];

  List<Map<String, dynamic>> incompatibleWords = [
    {
      "word": "Blue",
      "colors": [Colors.red]
    },
    {
      "word": "Blue",
      "colors": [Colors.yellow]
    },
    {
      "word": "Blue",
      "colors": [Colors.green]
    },
    {
      "word": "Red",
      "colors": [Colors.blue]
    },
    {
      "word": "Red",
      "colors": [Colors.yellow]
    },
    {
      "word": "Red",
      "colors": [Colors.green]
    },
    {
      "word": "Green",
      "colors": [Colors.red]
    },
    {
      "word": "Green",
      "colors": [Colors.blue]
    },
    {
      "word": "Green",
      "colors": [Colors.yellow]
    },
    {
      "word": "Yellow",
      "colors": [Colors.red]
    },
    {
      "word": "Yellow",
      "colors": [Colors.blue]
    },
    {
      "word": "Yellow",
      "colors": [Colors.green]
    }
  ];

  List<Map<String, dynamic>> wordArray = [];

  List<Map<String, dynamic>> generateSamples(
      List<Map<String, dynamic>> words, int count) {
    List<Map<String, dynamic>> samples = [];
    math.Random random = math.Random();

    for (int i = 0; i < count; i++) {
      int randomIndex = random.nextInt(words.length);
      Map<String, dynamic> selectedWord = words[randomIndex];

      if (selectedWord.containsKey('colors')) {
        List<Color> colors = List.from(selectedWord['colors']);
        samples.add({
          "word": selectedWord['word'],
          "color": colors[random.nextInt(colors.length)],
          "type": "incompatible"
        });
      } else {
        samples.add({
          "word": selectedWord['word'],
          "color": selectedWord['color'],
          "type": "compatible"
        });
      }
    }

    return samples;
  }

  List<Map<String, dynamic>> createWordArray() {
    wordArray = [];
    List<Map<String, dynamic>> combinedWords = [];
    combinedWords.addAll(generateSamples(compatibleWords, _totalWords ~/ 2));
    combinedWords.addAll(generateSamples(incompatibleWords, _totalWords ~/ 2));

    combinedWords.shuffle();

    wordArray.addAll(combinedWords);

    return wordArray;
  }

  void _changeWord() {
    _displayFixation();
  }

  void _displayFixation() {
    _fixationStartTime = DateTime.now().millisecondsSinceEpoch;
    dialogBoxAppearTime = 0;
    dialogBoxDisappearTime = 0;
    _elapsedFixationTime = 0;
    _currentTimerType = TimerType.Fixation;

    log("display Fixation");
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
        _colorOptionsEnabled = true; // Enable color options after fixation
      });
      _displayWords();
    });
  }

  int? wordDisplayStartTime;
  //Variable lai declare gardeko tap duration track grana lai(informal comment coz i m boreddddd)
  List<int> compatibleDurations = [];
  List<int> incompatibleDurations = [];

  void _displayWords() {
    dialogBoxAppearTime = 0;
    dialogBoxDisappearTime = 0;
    _elapsedWordsTime = 0;
    _currentTimerType = TimerType.Words;
    _wordsStartTime = DateTime.now().millisecondsSinceEpoch;
    log("display Words");
    if (_isDialogVisible) {
      return; // Do nothing if dialog is visible
    }
    // Start the timer when the word is displayed
    wordDisplayStartTime = DateTime.now().millisecondsSinceEpoch;
    // Print the type of word being displayed
    String wordType = wordArray[_currentWordIndex]['type'] == "compatible"
        ? "Compatible"
        : "Incompatible";

    const twoSecond = Duration(seconds: 2);
    _wordsTimer = Timer(twoSecond, () {
      log('Word count: $_currentWordIndex,  ${_totalWords - 1}');
      setState(() {
        _showPopup = false;
        _colorOptionsEnabled =
            false; // Disable color options after word display

        Word wordData = Word(
          userId: selectedChildUserId, // Set the user ID as needed
          sessionId: sessionId, // Set the session ID as needed
          trialId: _currentWordIndex + 1, // Set the trial ID as needed
          word: wordArray[_currentWordIndex]['word'], // Set the word
          color: getColorName(wordArray[_currentWordIndex >= _totalWords
              ? 0
              : _currentWordIndex]['color']), // Set the color
          type: wordArray[_currentWordIndex]['type'],
          result: 'Unattempted', // Set the type as needed
          responseTime: 2000, // Set the response time
        );
        log('adding to word list');
        wordList.add(wordData);
        if (_currentWordIndex == _totalWords - 1) {
          // Corrected condition
          // Display "Game Over" popup after all words are shown
          _showGameOverDialog();
          _playSound('GameOverDialog.mp3', player);
        }
      });

      if (_currentWordIndex < _totalWords - 1) {
        _currentWordIndex = (_currentWordIndex + 1);
        // Adjusted condition
        // Continue the game if not reached the total number of words
        _displayFixation();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer(Color selectedColor) async {
    if (_isDialogVisible || _showFixation || !_colorOptionsEnabled) {
      return; // Don't check the answer if dialog is visible, fixation is displayed, or color options are disabled
    }

    Color correctColor =
        wordArray[_currentWordIndex >= _totalWords ? 0 : _currentWordIndex]
            ['color'];

    _fixationTimer.cancel();
    _wordsTimer.cancel();
    setState(() {
      final correctColorTappedTime = DateTime.now().millisecondsSinceEpoch;
      if (dialogBoxAppearTime > 0 && dialogBoxDisappearTime > 0) {
        pauseTime = dialogBoxDisappearTime - dialogBoxAppearTime;
      } else {
        pauseTime = 0;
      }
      log('this is being deducted from the pause time: $pauseTime');
      final duration =
          correctColorTappedTime - wordDisplayStartTime! - pauseTime;
      // user chooses correct color
      if (selectedColor.value == correctColor.value) {
        correctResponse++;
        _popupText = 'CORRECT'.tr;
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }
        _playSound('right.mp3', player1);

        log('User tapped the correct color option.');

        // Calculate duration and add it to the appropriate list based on word type
        if (wordDisplayStartTime != null) {
          if (wordArray[_currentWordIndex]['type'] == "compatible") {
            compatibleDurations.add(duration);
          } else {
            incompatibleDurations.add(duration);
          }
          log('Time taken to tap correct color option: $duration milliseconds');
        } else {
          log('Error: wordDisplayStartTime is null.');
        }
        //if user chooses the wrong color
      } else {
        _popupText = 'WRONG'.tr;
        _playSound('wrong.mp3', player);

        log('User tapped the wrong color option.');
      }
      Word wordData = Word(
        userId: selectedChildUserId, // Set the user ID as needed
        sessionId: sessionId, // Set the session ID as needed
        trialId: _currentWordIndex + 1, // Set the trial ID as needed
        word: wordArray[_currentWordIndex]['word'], // Set the word
        color: getColorName(correctColor), // Set the color
        type: wordArray[_currentWordIndex]['type'],
        result: selectedColor.value == correctColor.value
            ? 'Correct'
            : 'Incorrect', // Set the type as needed
        responseTime: duration, // Set the response time
      );
      log('adding to word list');
      wordList.add(wordData);
      _showPopup = true;
      _isPopupVisible = true;
      _colorOptionsEnabled =
          false; // Disable color options after answer selection
    });

    // Delay for 500 milliseconds to show the popup
    await Future.delayed(const Duration(milliseconds: 500), () async {
      if (_isMounted) {
        setState(() {
          _showPopup = false;
          _isPopupVisible = false;
          // Show fixation point and then words
        });
        _displayFixation();
      }
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
      log('Elapsed time fixation: $_elapsedFixationTime');

      _isDialogVisible = true;
      result = await displayQuitDialog();
      _isDialogVisible = false;

      if (result == false) {
        _fixationTimer = Timer(
          Duration(milliseconds: 500 - _elapsedFixationTime),
          () {
            setState(() {
              _showFixation = false;
              _colorOptionsEnabled = true;
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
        log('Word resumed');
        int timeRemaining = 2000 - _elapsedWordsTime;
        log('11111Elapsed word time: $_elapsedWordsTime');
        log('11111Remaining word time: $timeRemaining');
        dialogBoxDisappearTime = DateTime.now().millisecondsSinceEpoch;
        _wordsTimer = Timer(
          Duration(milliseconds: 2000 - _elapsedWordsTime),
          () {
            log('Word count: $_currentWordIndex,  ${_totalWords - 1}');
            setState(() {
              _showPopup = false;
              _colorOptionsEnabled = false;
              Word wordData = Word(
                userId: selectedChildUserId,
                sessionId: sessionId,
                trialId: _currentWordIndex + 1,
                word: wordArray[_currentWordIndex]['word'],
                color: getColorName(wordArray[_currentWordIndex >= _totalWords
                    ? 0
                    : _currentWordIndex]['color']),
                type: wordArray[_currentWordIndex]['type'],
                result: 'Unattempted',
                responseTime: 2000,
              );
              log('adding to word list');
              wordList.add(wordData);
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
    // _databaseHelper.insertWords(wordList);
    // List<Map<String, dynamic>> data = wordList.map((e) => e.toMap()).toList();
    // levelCompletionHandler!.createMindParkDirectoryAndSaveCSV(data).then((_) {
    //   log('Level completion data saved to CSV.');
    // });
    cloudStoreService.addStroopData(wordList);
    log('Word list: ${wordList.length}');
    log('Word list: $wordList');
    // Calculate average durations for tapping correct color option for both compatible and incompatible word types
    double compatibleAverageDuration = compatibleDurations.isNotEmpty
        ? compatibleDurations.reduce((a, b) => a + b) /
            compatibleDurations.length
        : 0;
    double incompatibleAverageDuration = incompatibleDurations.isNotEmpty
        ? incompatibleDurations.reduce((a, b) => a + b) /
            incompatibleDurations.length
        : 0;

    // Calculate the Stroop effect
    double stroopEffect =
        incompatibleAverageDuration - compatibleAverageDuration;

    cloudStoreService.addStroopResult(StroopResult(
      userId: selectedChildUserId,
      level: 'Stroop',
      sessionId: sessionId,
      compatible: compatibleAverageDuration,
      incompatible: incompatibleAverageDuration,
      stroopScore: stroopEffect,
      correctResponse: correctResponse,
      incorrectResponse: _totalWords - correctResponse,
      accuracy: correctResponse / _totalWords * 100,
    ));

    log('Average duration for tapping correct color option (Compatible): ${compatibleAverageDuration.toStringAsFixed(2)} milliseconds');
    log('Average duration for tapping correct color option (Incompatible): ${incompatibleAverageDuration.toStringAsFixed(2)} milliseconds');
    log('The Stroop Effect: ${stroopEffect.toStringAsFixed(2)} milliseconds');

    final screenSize = MediaQuery.of(context).size;
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
                        'Your speed in trials:'.tr, // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${'Compatible: '.tr}${convertToNepaliNumbers(compatibleAverageDuration.toStringAsFixed(2))} ms', // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${'Incompatible: '.tr}${convertToNepaliNumbers(incompatibleAverageDuration.toStringAsFixed(2))} ms', // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${'Stroop Score: '.tr}${convertToNepaliNumbers(stroopEffect.toStringAsFixed(2))} ms', // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF309092),
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
                                    color: const Color(0xff309092),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/balloon_background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: screenWidth * 0.22,
                  width: screenWidth * 0.22,
                  child: CircularChart(
                      chartData: ChartData(
                          'Stroop',
                          (_currentWordIndex) / _totalWords * 100,
                          Colors.black),
                      fontSize: screenWidth * 0.04),
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
                    )),
              ],
            ),
            Text(
              'Color Clash'.tr,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF309092),
              ),
            ),
            Column(
              children: [
                _showStartButton
                    ? GestureDetector(
                        onTap: () {
                          _playSound('playbutton.mp3', player);
                          _changeWord();
                          setState(() {
                            _showStartButton = false;
                          });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.15,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    15), // Optionally add border radius
                                child: Image.asset(
                                  'assets/images/mainbutton.png',
                                  fit: BoxFit
                                      .cover, // Ensure the image covers the entire area of the Container
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  child: Text(
                                    "Start".tr,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                Center(
                  child: SizedBox(
                    width: screenSize.width * 0.55,
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
                                child: Text(
                                  "+",
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.095,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : Center(
                                child: Visibility(
                                  visible: !_showStartButton,
                                  child: Text(
                                    _isPopupVisible
                                        ? ''
                                        : '${wordArray[_currentWordIndex >= _totalWords ? 0 : _currentWordIndex]['word']}'
                                            .tr,
                                    style: TextStyle(
                                      color: wordArray[
                                          _currentWordIndex >= _totalWords
                                              ? 0
                                              : _currentWordIndex]['color'],
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
                SizedBox(
                  height: screenSize.height * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: colorOptions
                      .map(
                        (color) => AnimatedButton(
                          height: screenSize.width * 0.17,
                          width: screenSize.width * 0.17,
                          color: color,
                          enabled: _colorOptionsEnabled,
                          onPressed: () {
                            _checkAnswer(color);
                          },
                          child: Container(
                            width: screenSize.width * 0.17,
                            height: screenSize.width * 0.17,
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.025)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: screenSize.height * 0.05),
                SizedBox(
                  height: screenSize.height *
                      0.10, // Fixed height to prevent shifting
                  child: _showPopup
                      ? AnimatedOpacity(
                          opacity: _showPopup ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 0),
                          child: Center(
                            child: Image.asset(
                              _popupText == 'CORRECT'.tr
                                  ? 'assets/images/25.png'
                                  : 'assets/images/54.png',
                              height: screenSize.height * 0.10,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}

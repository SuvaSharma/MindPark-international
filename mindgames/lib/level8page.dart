import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/DatabaseHelper.dart';
import 'package:mindgames/Level8demopage.dart';
import 'package:mindgames/LevelCompletionHandler.dart';
import 'package:mindgames/Levels_screen.dart';
import 'package:mindgames/SDMTResult.dart';
import 'package:mindgames/Stroopinspage.dart';
import 'package:mindgames/TMTinfoscreen.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mindgames/level8infoscreen.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Level8page extends ConsumerStatefulWidget {
  Level8page({Key? key}) : super(key: key);

  @override
  _Level8pageState createState() => _Level8pageState();
}

class NumberImagePair {
  final int number;
  final String imagePath;

  NumberImagePair(this.number, this.imagePath);
}

class _Level8pageState extends ConsumerState<Level8page>
    with TickerProviderStateMixin {
  late final String selectedChildUserId;
  CloudStoreService cloudStoreService = CloudStoreService();
  LevelCompletionHandler? levelCompletionHandler;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<GameData> gameDataList = [];
  DateTime sessionId = DateTime.now();
  int _trialId = 0; // Initialize trial ID
  DateTime?
      _symbolDisplayTime; // Variable to store the time when the symbol is displayed
  int _score = 0; // Initialize score
  int _incorrectChoice = 0;
  int totalTrials = 0;

  late ConfettiController _confettiController;

  // Call this method each time a trial is completed
  void _insertGameData(bool isCorrect) {
    print(
        'inside insert game data ${DateTime.now().difference(_symbolDisplayTime!).inMilliseconds}');
    _trialId++;

    // Convert boolean result to integer (1 for true, 0 for false)
    int result = isCorrect ? 1 : 0;
    // Calculate response time if the symbol has been displayed
    int responseTime =
        DateTime.now().difference(_symbolDisplayTime!).inMilliseconds;
    // Capture the current time as symbol display time
    DateTime symbolDisplayTime = DateTime.now();

    GameData gameData = GameData(
      userId: selectedChildUserId,
      sessionId: sessionId,
      blockId: 1,
      trialId: _trialId,
      result: result,
      responseTime: responseTime,
      symbolDisplayTime: symbolDisplayTime,
    );

    gameDataList.add(gameData);

    // Update score if the tap was correct
    if (isCorrect) {
      _score++;
    } else {
      _incorrectChoice++;
    }
    // Print statements for debugging
    print('Inserted Game Data:');
    print('User ID: ${gameData.userId}');
    print('Session ID: ${gameData.sessionId}');
    print('Block ID: ${gameData.blockId}');
    print('Trial ID: ${gameData.trialId}');
    print('Result: ${gameData.result}');
    print('Response Time: ${gameData.responseTime} milliseconds');
    print('Symbol Display Time: ${gameData.symbolDisplayTime}');
    // Reset symbol display time for the next trial
  }

  late AnimationController _animationController1;
  late Animation<double> _animation1;

  bool _startButtonVisible = true;
  late Timer _timer;
  int _seconds = 0;

  int _currentSymbolIndex = 0; // Index of the current symbol from Table 1

  List<int> numbers = [];

  List<int?> droppedNumbers = [null, null, null, null, null];
  bool _lastTapCorrect = false;
  int _lastTappedIndex = -1;
  bool _feedbackImageVisible =
      false; // New variable to control feedback image visibility
  int maxDuration = 120;

  // Added boolean variable to control CircleAvatar tapping
  bool _circleAvatarEnabled = true;

  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final AudioPlayer player1 = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  Level8page() {
    // Preload the audio file during app initialization
    _audioCache.load('right.mp3').then((_) {
      print(
          'right sound pre-initialized'); // Log a message when preloading is complete
    });
    _audioCache.load('verbalgood.mp3').then((_) {
      print('verbal good sound pre-loaded');
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
    _audioCache.load('PauseTap.mp3').then((_) {
      print('Pause sound pre-loaded');
    });
  }

  @override
  void initState() {
    super.initState();

    _loadSoundSetting();
    _loadVibrationSetting();
    _preloadAudio();

    // Initialize _currentSymbolIndex randomly
    _currentSymbolIndex = Random().nextInt(allPairs.length);

    _animationController1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation1 =
        Tween<double>(begin: 0.25, end: 1).animate(_animationController1);

    _animationController1.forward();
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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Update symbol every 2 minutes
        if (_seconds % maxDuration == 0) {
          // Stop the timer
          _stopTimer();
          _resetGame();
          // Show end session dialog

          print("gameover");
          _playSound('GameOverDialog.mp3', player);
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _showEndSessionDialog(_score, _incorrectChoice);
  }

  void _resetGame() {
    setState(() {
      _seconds = 0;
      droppedNumbers = [null, null, null, null, null];
    });
  }

  Widget _buildOptionRow(IconData icon, String text, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFF309092),
          borderRadius: BorderRadius.circular(25),
          // Example border color, you can change it
        ),
        child: AnimatedButton(
          height: screenHeight * 0.12,
          width: screenWidth * 0.3,
          color: Color(0xFF309092),
          onPressed: () {
            if (text == 'Resume'.tr) {
              Navigator.pop(context, false);
            } else if (text == 'Sound'.tr) {
              print('Change sound');
            } else if (text == 'Instructions'.tr) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Introduction(shownWhen: 'in-game'),
                ),
              );
            } else if (text == 'Quit'.tr) {
              Navigator.pop(context, true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExecutiveskillsPage()),
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
    double screenHeight = MediaQuery.of(context).size.height;
    _playSound('PauseTap.mp3', player);
    _timer.cancel(); // Stop the timer when back button is pressed
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            side: BorderSide(
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
                    color: Color(0xFF309092),
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
      ),
    );

    if (result == false) {
      _startTimer();
    }
    return result ?? false;
  }

  double calculateMeanReactionTime(List<GameData> gameDataList) {
    double sumOfReactionTime = 0;
    int correctCount = 0;
    for (GameData gameData in gameDataList) {
      if (gameData.result == 1) {
        sumOfReactionTime += gameData.responseTime;
        correctCount++;
      }
    }

    print('--------------------------');
    print(sumOfReactionTime);
    print(correctCount);
    if (correctCount == 0) {
      return 0;
    }

    return sumOfReactionTime / correctCount;
  }

  void _showEndSessionDialog(int score, int incorrectChoice) async {
    _confettiController.play();
    double scorePercentage = score / 45 * 100;
    print('Storing to cloud store');
    cloudStoreService.addSDMTData(gameDataList);
    cloudStoreService.addSDMTResult(
      SDMTResult(
        userId: selectedChildUserId,
        level: 'SDMT',
        sessionId: sessionId,
        score: scorePercentage >= 100 ? 100.0 : scorePercentage,
        incorrectChoice: _incorrectChoice,
        totalTrials: (score + _incorrectChoice),
        accuracy: score == 0 ? 0 : score / (score + incorrectChoice) * 100,
        meanReactionTime: calculateMeanReactionTime(gameDataList),
      ),
    );
    setState(() {
      // Set _startButtonVisible to true to hide the start button
      _startButtonVisible = true;
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
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'You nailed it!'.tr,
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
                        'Score: '.tr + convertToNepaliNumbers('${score}'),
                        // Display the score
                        style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Color(0xFF309092),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                _playSound('playbutton.mp3', player);
                                Navigator.pop(
                                  context,
                                );
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
                                        size: screenWidth * 0.03),
                                  )),
                            ),
                          ])
                      // GestureDetector(
                      //   onTap: () {
                      //     _playSound('playbutton.mp3');

                      //     Navigator.pushAndRemoveUntil(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => const StroopinfoScreen(
                      //               shownWhen:
                      //                   'before-game')), // Navigate to LevelScreen
                      //       (Route<dynamic> route) =>
                      //           false, // Remove all routes from stack
                      //     );
                      //   },
                      //   child: Container(
                      //     width: screenWidth * 0.12,
                      //     // height: MediaQuery.of(context).size.width * 0.25,
                      //     child: Stack(
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/Play.png', // Replace with your image path
                      //           fit: BoxFit.cover,
                      //         ),
                      //         Center(
                      //           child: Text("Exit".tr,
                      //               style: TextStyle(
                      //                 fontSize: screenWidth * 0.025,
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

  List<NumberImagePair> allPairs = [
    NumberImagePair(1, 'assets/images/sdmt_images/cylinder.png'),
    NumberImagePair(2, 'assets/images/sdmt_images/cube.png'),
    NumberImagePair(3, 'assets/images/sdmt_images/torus.png'),
    NumberImagePair(4, 'assets/images/sdmt_images/prism.png'),
    NumberImagePair(5, 'assets/images/sdmt_images/cone.png'),
    NumberImagePair(6, 'assets/images/sdmt_images/sphere.png'),
    NumberImagePair(7, 'assets/images/sdmt_images/trapezoid.png'),
    NumberImagePair(8, 'assets/images/sdmt_images/diamond.png'),
    NumberImagePair(9, 'assets/images/sdmt_images/hexagon.png'),
  ];
  @override
  Widget build(BuildContext context) {
    print('Building page');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: OrientationBuilder(
          builder: (context, orientation) {
            print('switching main build landscape');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            return SafeArea(
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/balloon_background.jpeg',
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(), // Placeholder for alignment
                            Padding(
                              padding: EdgeInsets.only(right: baseSize * 0.05),
                              child: AnimatedButton(
                                height: baseSize * 0.1,
                                width: baseSize * 0.1,
                                child: Icon(
                                  Icons.pause,
                                  color: const Color.fromARGB(255, 66, 62, 62),
                                  size: baseSize * 0.05,
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  _onBackPressed();
                                },
                                enabled: true,
                                shadowDegree: ShadowDegree.light,
                              ),
                            ),
                          ],
                        ),
                        AnimatedBuilder(
                          animation: _animation1,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _animation1.value,
                              child: Material(
                                elevation: 15,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: screenWidth * 0.8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Table(
                                    border: TableBorder.all(
                                      width: 2,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    children: List.generate(2, (rowIndex) {
                                      return TableRow(
                                        children: List.generate(9, (colIndex) {
                                          if (rowIndex == 0) {
                                            return TableCell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Image.asset(
                                                  allPairs[colIndex].imagePath,
                                                  height: baseSize * 0.15,
                                                ),
                                              ),
                                            );
                                          } else if (rowIndex == 1) {
                                            return TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text(
                                                    '${'${allPairs[colIndex].number}'.tr}',
                                                    style: TextStyle(
                                                      fontSize: baseSize * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Fallback'),
                                              ),
                                            );
                                          }
                                        }),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: baseSize * 0.02),
                        Visibility(
                          visible: _startButtonVisible,
                          child: GestureDetector(
                            onTap: () {
                              _playSound('playbutton.mp3', player);
                              setState(() {
                                _startTimer();

                                numbers =
                                    List.generate(9, (index) => index + 1);
                                _startButtonVisible = false;
                                _symbolDisplayTime = DateTime.now();
                              });
                            },
                            child: Container(
                              width: baseSize * 0.3,
                              height: baseSize * 0.15,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.asset('assets/images/Play.png',
                                        width: baseSize * 0.3,
                                        height: baseSize * 0.15,
                                        fit: BoxFit.cover),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: baseSize * 0.03),
                                      child: Text(
                                        'Start'.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: baseSize * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Time: '.tr +
                              convertToNepaliNumbers(
                                  (maxDuration - _seconds).toString()) +
                              ' seconds'.tr,
                          style: TextStyle(
                            fontSize: baseSize * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: !_startButtonVisible,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Visibility(
                                  visible: !_feedbackImageVisible,
                                  child: Image.asset(
                                    allPairs[_currentSymbolIndex].imagePath,
                                    height: baseSize * 0.2,
                                  ),
                                ),
                                Visibility(
                                  visible: _feedbackImageVisible,
                                  child: Container(
                                    height: baseSize * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Image.asset(
                                      _lastTapCorrect
                                          ? 'assets/images/25.png'
                                          : 'assets/images/54.png',
                                      height: baseSize * 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          child: Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 9,
                                mainAxisSpacing: baseSize * 0.006,
                                crossAxisSpacing: baseSize * 0.006,
                              ),
                              itemCount: numbers.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    print(
                                        'This input took ${DateTime.now().difference(_symbolDisplayTime!).inMilliseconds}');
                                    if (_circleAvatarEnabled) {
                                      setState(() {
                                        int tappedNumber = numbers[index];

                                        if (tappedNumber ==
                                            _currentSymbolIndex + 1) {
                                          _lastTapCorrect = true;
                                          print(
                                              'Correct! Tapped number: $tappedNumber');

                                          _playSound('right.mp3', player1);
                                          if (_vibrationEnabled) {
                                            Vibration.vibrate(
                                              duration: 100,
                                              amplitude: 10,
                                            );
                                          }
                                        } else {
                                          _lastTapCorrect = false;
                                          print(
                                              'Wrong! Tapped number: $tappedNumber');
                                          _playSound('incorrect-c.mp3', player);
                                        }

                                        _lastTappedIndex = index;

                                        _changeSymbol();

                                        _circleAvatarEnabled = false;
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(baseSize * 0.008),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Material(
                                            elevation: 15,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: CircleAvatar(
                                              radius: baseSize * 0.07,
                                              backgroundColor:
                                                  Color(0xFF309092),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Text(
                                                    numbers[index]
                                                        .toString()
                                                        .tr,
                                                    style: TextStyle(
                                                      fontSize: baseSize * 0.04,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to change the symbol
  void _changeSymbol() {
    setState(() {
      // Shuffle only the symbols that are currently being displayed
      List<int> displayedSymbols = numbers.toList();
      displayedSymbols.shuffle();

      // Ensure the new symbol is different from the current symbol
      int newSymbol;
      do {
        newSymbol = displayedSymbols.removeAt(0);
      } while (newSymbol == _currentSymbolIndex);

      // Set the feedback image visibility to true
      _feedbackImageVisible = true;

      // Disable CircleAvatar tapping until next symbol is displayed
      _circleAvatarEnabled = false;

      // Insert the game data into the database
      _insertGameData(_lastTapCorrect);

      // Delay for 1 second before hiding the feedback image and updating the symbol
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _feedbackImageVisible = false;
          _currentSymbolIndex = newSymbol - 1; // Adjust for 0-based indexing

          // Enable CircleAvatar tapping for the next symbol
          _circleAvatarEnabled = true;
        });
      });
      _symbolDisplayTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    print('switching main dispose portrait');
    _animationController1.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _confettiController.dispose();
    super.dispose();
  }
}

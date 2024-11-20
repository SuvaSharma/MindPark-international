import 'dart:math';
import 'dart:ui';
import 'package:animated_button/animated_button.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:mindgames/Levels_screen.dart';
import 'package:mindgames/executiveskills.dart';
import 'package:mindgames/level8infoscreen.dart';
import 'package:mindgames/level8page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/widgets/welcome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ssinteractivedemo extends StatefulWidget {
  ssinteractivedemo({Key? key}) : super(key: key);

  @override
  _ssinteractivedemoState createState() => _ssinteractivedemoState();
}

class NumberImagePair {
  final int number;
  final String imagePath;

  NumberImagePair(this.number, this.imagePath);
}

class _ssinteractivedemoState extends State<ssinteractivedemo>
    with TickerProviderStateMixin {
  int _trialId = 0; // Initialize trial ID
  DateTime?
      _symbolDisplayTime; // Variable to store the time when the symbol is displayed
  int _score = 0; // Initialize score

  // Call this method each time a trial is completed
  void _insertGameData(bool isCorrect) {
    _trialId++;

    // Convert boolean result to integer (1 for true, 0 for false)
    int result = isCorrect ? 1 : 0;
    // Calculate response time if the symbol has been displayed
    int responseTime = _symbolDisplayTime != null
        ? DateTime.now().difference(_symbolDisplayTime!).inMilliseconds
        : 0;
    // Capture the current time as symbol display time
    DateTime symbolDisplayTime = DateTime.now();

    // Update score if the tap was correct
    if (isCorrect) {
      _score++;
    }

    _symbolDisplayTime = null;
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

  // Added boolean variable to control CircleAvatar tapping
  bool _circleAvatarEnabled = true;
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  bool _soundEnabled = true;

  int maxDuration = 1;

  late ConfettiController _confettiController;

  Level8demopage() {
    // Preload the audio file during app initialization

    _audioCache.load('incorrect-c.mp3').then((_) {
      print('wrong sound pre-loaded');
    });
    _audioCache.load('GameOverDialog.mp3').then((_) {
      print('gameover sound pre-loaded');
    });
    _audioCache.load('verbalgood.mp3').then((_) {
      print('verbal good sound pre-loaded');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
    _loadSoundSetting();
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
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const WelcomeDialog(
          title: 'Welcome!',
          message: 'Match the symbols with numbers',
          imagePath: 'assets/images/sdmt-intro.gif',
        );
      },
    );
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _preloadAudio() {
    _audioCache.load('Instruction_Swipe.mp3').then((_) {
      print('Sound pre-initialized');
    });
  }

  void _playSound(String fileName) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Update symbol every 2 minutes
        if (_seconds % maxDuration == 120) {
          // Stop the timer
          _stopTimer();
          _resetGame();
          _playSound('GameOverDialog.mp3');
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _showEndSessionDialog(_score);
  }

  void _resetGame() {
    setState(() {
      _seconds = 0;
      droppedNumbers = [null, null, null, null, null];
    });
  }

  void _showEndSessionDialog(int score) async {
    _confettiController.play();
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
        return Dialog(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: screenWidth * 0.4,
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
                        'Demo Completed!'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
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
                          color: Color(0xFF309092),
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/prize.png',
                      width: screenWidth * 0.08,
                    ),
                    GestureDetector(
                      onTap: () {
                        _playSound('playbutton.mp3');
                        // Navigate to the Level8page
                        Navigator.pop(context, true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Level8page()),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.12,
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/Play.png', // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                            Center(
                              child: Text(
                                'Next'.tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.025,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }

  List<NumberImagePair> allPairs = [
    NumberImagePair(1, 'assets/images/cylinder.png'),
    NumberImagePair(2, 'assets/images/cube.png'),
    NumberImagePair(3, 'assets/images/torus.png'),
    NumberImagePair(4, 'assets/images/prism.png'),
    NumberImagePair(5, 'assets/images/cone.png'),
    NumberImagePair(6, 'assets/images/sphere.png'),
    NumberImagePair(7, 'assets/images/trapezoid.png'),
    NumberImagePair(8, 'assets/images/diamond.png'),
    NumberImagePair(9, 'assets/images/hexagon.png'),
  ];

// Import this package

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
    _playSound('PauseTap.mp3');
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

  @override
  Widget build(BuildContext context) {
    final double blurSigma = MediaQuery.of(context).size.shortestSide * 0.09;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: OrientationBuilder(
          builder: (context, orientation) {
            print('switching demo build landscape');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            return SafeArea(
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    if (_startButtonVisible)
                      BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: blurSigma, sigmaY: blurSigma),
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(), // Placeholder for alignment
                              _startButtonVisible
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          right: baseSize * 0.05),
                                      child: AnimatedButton(
                                        height: screenHeight * 0.1,
                                        width: screenWidth * 0.1,
                                        child: Text(
                                          'Skip'.tr,
                                          style: TextStyle(
                                            color: Color(0xFF309092),
                                            fontSize: screenWidth * 0.030,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        color: Colors.white,
                                        onPressed: () {
                                          _playSound('playbutton.mp3');
                                          // Navigate to the Level8page
                                          Navigator.pop(context, true);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Level8page()),
                                          );
                                        },
                                        enabled: true,
                                        shadowDegree: ShadowDegree.light,
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          right: baseSize * 0.05),
                                      child: AnimatedButton(
                                        height: baseSize * 0.05,
                                        width: baseSize * 0.05,
                                        child: Icon(
                                          Icons.pause,
                                          color: const Color.fromARGB(
                                              255, 66, 62, 62),
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
                          Text(
                            'DEMO'.tr,
                            style: TextStyle(
                                color: Color.fromARGB(255, 51, 106, 134),
                                fontSize: screenWidth * 0.023,
                                fontWeight: FontWeight.bold),
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
                                          children:
                                              List.generate(9, (colIndex) {
                                            if (rowIndex == 0) {
                                              return TableCell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Image.asset(
                                                    allPairs[colIndex]
                                                        .imagePath,
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
                                                        fontSize:
                                                            baseSize * 0.06,
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
                          Visibility(
                            visible: _startButtonVisible,
                            child: GestureDetector(
                              onTap: () {
                                _playSound('playbutton.mp3');
                                setState(() {
                                  _startTimer();
                                  numbers =
                                      List.generate(9, (index) => index + 1);
                                  _startButtonVisible = false;
                                });
                              },
                              child: Container(
                                width: baseSize * 0.3,
                                height: baseSize * 0.15,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.asset(
                                        'assets/images/Play.png',
                                        width: baseSize * 0.3,
                                        height: baseSize * 0.15,
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: baseSize * 0.03),
                                        child: Text(
                                          'Start'.tr,
                                          style: TextStyle(
                                              color: Colors
                                                  .white, // Customize the color as needed
                                              fontSize: baseSize * 0.05,
                                              fontWeight: FontWeight
                                                  .bold // Customize the font size as needed
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: baseSize * 0.02),
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
                                      width: baseSize * 0.2,
                                      height: baseSize * 0.2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Image.asset(
                                        _lastTapCorrect
                                            ? 'assets/images/25.png'
                                            : 'assets/images/54.png',
                                        height: baseSize * 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
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
                                    if (_circleAvatarEnabled) {
                                      setState(() {
                                        int tappedNumber = numbers[index];

                                        // Check if the tapped number is correct
                                        if (tappedNumber ==
                                            _currentSymbolIndex + 1) {
                                          // Adjust for 1-based indexing
                                          _lastTapCorrect = true;
                                          print(
                                              'Correct! Tapped number: $tappedNumber');
                                        } else {
                                          _lastTapCorrect = false;
                                          print(
                                              'Wrong! Tapped number: $tappedNumber');
                                          _playSound(('incorrect-c.mp3'));
                                        }

                                        _lastTappedIndex = index;

                                        // Always change the symbol, regardless of correctness
                                        _changeSymbol();

                                        // Disable CircleAvatar tapping until next symbol is displayed
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
                                                      color: Colors.white,
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
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !_startButtonVisible,
                      child: Positioned(
                        right: 20,
                        child: AnimatedButton(
                          height: baseSize * 0.1,
                          width: baseSize * 0.1,
                          child: const Icon(
                            Icons.pause,
                            color: Colors.black,
                            size: 25.0,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            _onBackPressed();
                          },
                          enabled: true,
                          shadowDegree: ShadowDegree.light,
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
    );
  }

  void _changeSymbol() {
    setState(() {
      // Shuffle all symbols
      List<int> shuffledNumbers = numbers.toList()..shuffle();

      // Capture the time when the symbol is displayed
      _symbolDisplayTime = DateTime.now();

      // Set the feedback image visibility to true
      _feedbackImageVisible = true;

      // Disable CircleAvatar tapping until next symbol is displayed
      _circleAvatarEnabled = false;

      // Delay for 1 second before hiding the feedback image and updating the symbol
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _feedbackImageVisible = false;
          _currentSymbolIndex =
              shuffledNumbers[0] - 1; // Adjust for 0-based indexing

          _insertGameData(_lastTapCorrect);

          // Enable CircleAvatar tapping for the next symbol
          _circleAvatarEnabled = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController1.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/simon_says_page.dart';
import 'package:mindgames/socialskills.dart';
import 'package:mindgames/config/easy_simon_says_task.dart';
import 'package:mindgames/widgets/congrats_dialog.dart';
import 'package:mindgames/widgets/pause_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class SimonSaysDemoPage extends StatefulWidget {
  const SimonSaysDemoPage({super.key});

  @override
  State<SimonSaysDemoPage> createState() => _SimonSaysDemoPageState();
}

class _SimonSaysDemoPageState extends State<SimonSaysDemoPage>
    with SingleTickerProviderStateMixin {
  static const timeLimit = 5;
  static int numberOfTasks = 2;
  int timeRemaining = timeLimit;
  Timer? timer;
  int currentTaskNumber = 0;
  bool _isPaused = false;
  bool? isChildMode = false;
  bool _isStarted = false;
  bool _vibrationEnabled = false;
  bool shouldDisplayBottomSheet = false;

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );

  late final Animation<Offset> offsetAnimation;
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();
  final player1 = AudioPlayer();
  bool _soundEnabled = true;

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
    easySimonSaysTasks.shuffle();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _audioCache.load('task_completed.mp3').then((_) {
      print(
          'right sound pre-initialized'); // Log a message when preloading is complete
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    player1.dispose();
    super.dispose();
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

  void startAnimation() {
    _animationController.forward().then((_) {
      _playSound(easySimonSaysTasks[currentTaskNumber]['audio']!, player);
      startTimer();
    });
  }

  Future<void> fadeAnimation() async {
    await _animationController.reverse();
  }

  void _playSound(String fileName, AudioPlayer player) {
    if (_soundEnabled) {
      player.play(AssetSource(fileName));
    }
  }

  void showModeDialog() {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Text("Who's playing the game?".tr,
                style: TextStyle(fontSize: screenWidth * 0.055)),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Child'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.pink[300],
                              )),
                          IconButton(
                            icon: Icon(
                              Icons.child_care,
                              size: screenWidth * 0.15,
                              color: Colors.pink[300],
                            ),
                            onPressed: () {
                              setState(() {
                                isChildMode = true;
                              });
                              Navigator.of(context).pop();
                              startAnimation();
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Guardian'.tr,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.green[300])),
                          IconButton(
                            icon: Icon(
                              Icons.person,
                              size: screenWidth * 0.15,
                              color: Colors.green[300],
                            ),
                            onPressed: () {
                              setState(() {
                                isChildMode = false;
                              });
                              Navigator.of(context).pop();
                              startAnimation();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isPaused) {
        // Check if there's time left for the task
        if (timeRemaining > 0) {
          setState(() {
            timeRemaining -= 1;
          });
        } else {
          // Task time has ended
          _playSound('task_completed.mp3', player);
          timer?.cancel();
          await fadeAnimation();

          // Show bottom sheet only if not paused
          if (!_isPaused) {
            if (!isChildMode!) {
              displayBottomSheet(context);
            } else {
              onTaskComplete(false);
            }
          } else {
            // Set a flag to display the bottom sheet upon resuming
            setState(() {
              shouldDisplayBottomSheet = true;
            });
          }
        }
      }
    });
  }

  void onTaskComplete(bool taskCompleted) {
    // if parents are using the game
    if (!isChildMode!) {
      Navigator.pop(context);
      if (taskCompleted) {
        if (_vibrationEnabled) {
          Vibration.vibrate(
            duration: 100,
            amplitude: 10,
          );
        }
      }
    }
    // if tasks are yet to be completed
    if (currentTaskNumber < numberOfTasks - 1) {
      setState(() {
        currentTaskNumber += 1;
        timeRemaining = timeLimit;
      });
      startAnimation();
    } else {
      setState(() {
        currentTaskNumber += 1;
      });
      showCongratsDialog();
    }
  }

  void showCongratsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CongratsDialog(
          onOkPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const SimonSaysPage()), // Navigate back to LegoGame
            );
          },
        );
      },
    );
  }

  Future displayBottomSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showModalBottomSheet(
      constraints: BoxConstraints(minWidth: screenWidth),
      context: context,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05))),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SizedBox(
            height: screenHeight * 0.25,
            width: screenWidth,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Did your child complete the task?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        onPressed: () => onTaskComplete(true),
                        child: Icon(
                          Icons.check,
                          size: screenWidth * 0.12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        onPressed: () => onTaskComplete(false),
                        child: Icon(
                          Icons.cancel_outlined,
                          size: screenWidth * 0.12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> onBackPressed() async {
    _playSound('PauseTap.mp3', player1);
    bool? result;

    setState(() {
      shouldDisplayBottomSheet = false;
    });

    Future<bool?> displayPauseMenu() async {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: PauseMenu(
            onResume: () {
              Navigator.pop(context, false);
            },
            onQuit: () {},
            quitDestinationPage: const SocialskillsPage(),
          ),
        ),
      );
    }

    setState(() {
      _isPaused = true;
    });

    result = await displayPauseMenu();

    // Handle resuming from pause
    if (result == false) {
      setState(() {
        _isPaused = false;
        if (shouldDisplayBottomSheet) {
          setState(() {
            shouldDisplayBottomSheet = false; // Reset flag
          });
          if (!isChildMode!) {
            displayBottomSheet(context);
          } else {
            onTaskComplete(false);
          }
        }
      });
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

    return WillPopScope(
      onWillPop: () async {
        if (_isStarted) {
          print("Went to pause menu.");
          bool result = await onBackPressed();
          return result;
        } else {
          print("Went to social skills menu");
          // Navigate back to the homepage when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SocialskillsPage()),
          );
          return false; // Prevents the default back button action
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/balloon_background.jpeg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            !_isStarted
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
                                  "Simon Says".tr,
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
                                        'assets/images/simonsays.jpeg',
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
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                              (_) => showModeDialog());
                                      setState(() {
                                        _isStarted = true;
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
                                                  const SimonSaysPage()));
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
                                    currentTaskNumber / numberOfTasks * 100,
                                    Colors.black),
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            right: screenWidth * 0.02,
                          ),
                          child: GestureDetector(
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
                                      borderRadius: BorderRadius.circular(
                                          baseSize * 0.03),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.pause),
                                      iconSize: baseSize * 0.07,
                                      onPressed: onBackPressed,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: offsetAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.08),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.04),
                                  child: Text(
                                    'Simon Says Demo',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.08,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              Container(
                                width: screenWidth * 0.7,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.05),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              screenWidth * 0.045),
                                          topLeft: Radius.circular(
                                              screenWidth * 0.045),
                                        ),
                                        color: Colors.black54,
                                      ),
                                      width: screenWidth * 0.7,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenWidth * 0.01),
                                        child: Text(
                                          '${easySimonSaysTasks[currentTaskNumber >= numberOfTasks ? 0 : currentTaskNumber]['command']}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.06,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      '${easySimonSaysTasks[currentTaskNumber >= numberOfTasks ? 0 : currentTaskNumber]['commandImage']}',
                                      height: screenWidth * 0.5,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              SizedBox(
                                height: screenWidth * 0.2,
                                width: screenWidth * 0.2,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: screenWidth * 0.02,
                                      value: timeRemaining / timeLimit,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.blue[200]),
                                      backgroundColor: Colors.blue[700],
                                    ),
                                    Center(
                                      child: timeRemaining == 0
                                          ? Icon(
                                              Icons.done,
                                              color: Colors.blue[700],
                                              size: screenWidth * 0.12,
                                            )
                                          : Text(
                                              '$timeRemaining',
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.08,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[700]),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

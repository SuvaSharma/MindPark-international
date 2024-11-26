import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/gesture_flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:get/get.dart';
import 'package:mindgames/CognitiveTrainingPage.dart';
import 'package:mindgames/Homepage.dart';
import 'package:mindgames/Level_one_screens.dart';
import 'package:mindgames/Levels_screen.dart';

class CognitiveLevelPage extends StatefulWidget {
  const CognitiveLevelPage({super.key});

  @override
  State<CognitiveLevelPage> createState() => _CognitiveLevelPageState();
}

class _CognitiveLevelPageState extends State<CognitiveLevelPage>
    with SingleTickerProviderStateMixin {
  final GestureFlipCardController _flipController = GestureFlipCardController();
  late AnimationController _controller;
  late Animation<Offset> _leftAnimation;
  late Animation<Offset> _rightAnimation;
  late Animation<Offset> _bottomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _leftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rightAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _bottomAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate container size based on screen width
    final containerSize = screenWidth * 0.5;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(children: [
          Image.asset(
            'assets/images/levelscreen.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _leftAnimation,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: Material(
                          elevation: 15,
                          borderRadius: BorderRadius.circular(25),
                          child: GestureFlipCard(
                            controller: _flipController,
                            axis: FlipAxis.horizontal, // Flip horizontally
                            enableController: true,
                            animationDuration:
                                const Duration(milliseconds: 800),
                            frontWidget: Stack(
                              children: [
                                Container(
                                  width: containerSize,
                                  height: containerSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0.5, -5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          "Level 1",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.06,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF309092),
                                          ),
                                        ),
                                      ),
                                      Align(
                                          alignment: Alignment.bottomCenter,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LevelOnePage(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF309092),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: const Text(
                                              "Play",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () {
                                          _flipController.flipcard();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backWidget: Container(
                              width: containerSize,
                              height: containerSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0.5, -5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Text(
                                      "Level is designed for highly autistic children, tailored to their needs.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LevelOnePage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF309092),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: const Text(
                                          "Play",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  SlideTransition(
                    position: _rightAnimation,
                    child: Align(
                      alignment: Alignment.center,
                      child: Material(
                        elevation: 15,
                        borderRadius: BorderRadius.circular(25),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CognitiveTrainingPage()));
                          },
                          child: Container(
                            width: containerSize,
                            height: containerSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0.5, -5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Level 2".tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF309092),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: _bottomAnimation,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: Material(
                          elevation: 15,
                          borderRadius: BorderRadius.circular(25),
                          child: GestureFlipCard(
                            controller: _flipController,
                            axis: FlipAxis.vertical, // Flip horizontally
                            enableController: true,
                            animationDuration:
                                const Duration(milliseconds: 800),
                            frontWidget: Stack(
                              children: [
                                Container(
                                  width: containerSize,
                                  height: containerSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0.5, -5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          "Level 3",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.06,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF309092),
                                          ),
                                        ),
                                      ),
                                      Align(
                                          alignment: Alignment.bottomCenter,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LevelPage(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF309092),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: const Text(
                                              "Play",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () {
                                          _flipController.flipcard();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backWidget: Container(
                              width: containerSize,
                              height: containerSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0.5, -5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Text(
                                      "Level is designed for children with low levels of autism, featuring minimal structure and gentle challenges.",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LevelPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF309092),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: const Text(
                                          "Play",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/utils/difficulty_enum.dart';

class EmotionButtons extends StatelessWidget {
  final Animation<Offset> _leftButtonAnimation;
  final Animation<Offset> _rightButtonAnimation;
  final void Function(String) _onEmotionButtonPressed;
  final Difficulty difficulty;

  EmotionButtons({
    required Animation<Offset> leftButtonAnimation,
    required Animation<Offset> rightButtonAnimation,
    required void Function(String) onEmotionButtonPressed,
    required this.difficulty,
  })  : _leftButtonAnimation = leftButtonAnimation,
        _rightButtonAnimation = rightButtonAnimation,
        _onEmotionButtonPressed = onEmotionButtonPressed;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Widget> emotionButtons = [
      SlideTransition(
        position: _leftButtonAnimation,
        child: AnimatedButton(
          height: screenWidth * 0.1,
          width: screenWidth * 0.3,
          color: Colors.blue,
          onPressed: () => _onEmotionButtonPressed('Happy'),
          child: Text(
            'Happy'.tr,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.015),
      SlideTransition(
        position: _rightButtonAnimation,
        child: AnimatedButton(
          height: screenWidth * 0.1,
          width: screenWidth * 0.3,
          color: Colors.yellow,
          onPressed: () => _onEmotionButtonPressed('Sad'),
          child: Text(
            'Sad'.tr,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];

    if (difficulty == Difficulty.medium || difficulty == Difficulty.hard) {
      emotionButtons.addAll([
        SizedBox(height: screenWidth * 0.019),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: SlideTransition(
            position: _leftButtonAnimation,
            child: AnimatedButton(
              height: screenWidth * 0.1,
              width: screenWidth * 0.3,
              color: Colors.green,
              onPressed: () => _onEmotionButtonPressed('Surprise'),
              child: Text(
                'Surprise'.tr,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        SlideTransition(
          position: _rightButtonAnimation,
          child: AnimatedButton(
            height: screenWidth * 0.1,
            width: screenWidth * 0.3,
            color: Colors.orange,
            onPressed: () => _onEmotionButtonPressed('Angry'),
            child: Text(
              'Angry'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]);
    }

    if (difficulty == Difficulty.hard) {
      emotionButtons.addAll([
        SizedBox(height: screenWidth * 0.019),
        SlideTransition(
          position: _leftButtonAnimation,
          child: AnimatedButton(
            height: screenWidth * 0.1,
            width: screenWidth * 0.3,
            color: Colors.red,
            onPressed: () => _onEmotionButtonPressed('Fear'),
            child: Text(
              'Fear'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        SlideTransition(
          position: _rightButtonAnimation,
          child: AnimatedButton(
            height: screenWidth * 0.1,
            width: screenWidth * 0.3,
            color: Colors.purple,
            onPressed: () => _onEmotionButtonPressed('Neutral'),
            child: Text(
              'Neutral'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]);
    }

    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: emotionButtons,
      ),
    );
  }
}

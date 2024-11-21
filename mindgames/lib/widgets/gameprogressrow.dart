import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/widgets/circular_progress_indicator.dart';

Widget buildGameProgressRow(String gameName,
    Map<Difficulty, double> difficultyData, BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final double screenWidth = screenSize.width;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildProgressIndicator(
            context,
            'Easy'.tr,
            difficultyData[Difficulty.easy] ?? 0,
            Colors.black.withOpacity(0.1),
            MediaQuery.of(context).size.width),
        SizedBox(
          width: screenWidth * 0.07,
        ),
        buildProgressIndicator(
            context,
            'Medium'.tr,
            difficultyData[Difficulty.medium] ?? 0,
            Colors.black.withOpacity(0.1),
            MediaQuery.of(context).size.width),
        SizedBox(
          width: screenWidth * 0.07,
        ),
        buildProgressIndicator(
            context,
            'Hard'.tr,
            difficultyData[Difficulty.hard] ?? 0,
            Colors.black.withOpacity(0.1),
            MediaQuery.of(context).size.width),
      ],
    ),
  );
}

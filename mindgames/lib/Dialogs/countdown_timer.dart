// timer/countdown_timer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountDownTimer extends StatelessWidget {
  final int seconds;
  final Function onTimerEnd;

  const CountDownTimer({
    super.key,
    required this.seconds,
    required this.onTimerEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'You have '.tr + seconds.toString().tr + ' seconds left'.tr,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 51, 106, 134),
      ),
    );
  }
}

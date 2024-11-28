import 'dart:developer';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class CongratsDialog extends StatefulWidget {
  final VoidCallback onOkPressed;

  const CongratsDialog({
    super.key,
    required this.onOkPressed,
  });

  @override
  State<CongratsDialog> createState() => _CongratsDialogState();
}

class _CongratsDialogState extends State<CongratsDialog> {
  bool vibrationEnabled = false;
  Future<void> loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  @override
  void initState() {
    loadVibrationSetting();
    log('Vibration status: $vibrationEnabled');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the ConfettiController
    final ConfettiController _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));

    // Start the confetti animation
    _confettiController.play();

    log('Vibration status in build: $vibrationEnabled');

    if (vibrationEnabled) {
      Vibration.vibrate(
        duration: 100,
        amplitude: 10,
      );
    }

    return WillPopScope(
      // Prevent dialog from closing on back button press
      onWillPop: () async => false,
      child: Dialog(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.5,
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
                      fontSize: MediaQuery.of(context).size.width * 0.05,
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
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: const Color(0xFF309092),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/victory.png',
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: widget.onOkPressed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff309092),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

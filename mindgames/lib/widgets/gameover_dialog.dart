import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameOverDialog extends StatelessWidget {
  final VoidCallback onOkPressed;

  const GameOverDialog({
    Key? key,
    required this.onOkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the ConfettiController
    final ConfettiController _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));

    // Start the confetti animation
    _confettiController.play();

    return WillPopScope(
      // Prevent dialog from closing on back button press
      onWillPop: () async => false,
      child: Dialog(
        child: GestureDetector(
          onTap: () {}, // Prevents tapping outside the dialog from closing it
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Times up!!'.tr,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Color(0xFF309092),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Better luck next time!'.tr,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: const Color(0xFF309092),
                      // fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/prize.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: onOkPressed,
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
                            size: MediaQuery.of(context).size.width * 0.07,
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SymbolSafariWelcomeDialog extends StatefulWidget {
  final String title;
  final String message;
  final String imagePath;
  final Function onGameQuit;

  const SymbolSafariWelcomeDialog({
    super.key,
    required this.title,
    required this.message,
    required this.imagePath,
    required this.onGameQuit,
  });

  @override
  State<SymbolSafariWelcomeDialog> createState() =>
      _SymbolSafariWelcomeDialogState();
}

class _SymbolSafariWelcomeDialogState extends State<SymbolSafariWelcomeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true); // Bounce effect

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    log('Switching welcome dialog');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        width: width * 0.95,
        constraints: BoxConstraints(
          maxHeight: height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.close_circle,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.portraitUp,
                      ]);
                      widget.onGameQuit();
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                widget.title.tr,
                style: TextStyle(
                  fontSize: width * 0.025,
                  color: const Color(0xFF309092),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.message.tr,
                style: TextStyle(
                  fontSize: width * 0.02,
                  color: const Color(0xFF309092),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Divider(
            //   thickness: 0.3,
            //   indent: 1,
            //   endIndent: 1,
            //   color: Colors.black,
            // ),
            Flexible(
              child: Image.asset(
                widget.imagePath,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            // Divider(
            //   thickness: 0.3,
            //   indent: 1,
            //   endIndent: 1,
            //   color: Colors.black,
            //   height: 2,
            // ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 8.0,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Let's Play!".tr,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: height * 0.03,
            )
          ],
        ),
      ),
    );
  }
}

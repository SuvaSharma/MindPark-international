import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';

class DisclaimerDialog extends StatefulWidget {
  final Function() onConfirmation;

  const DisclaimerDialog({
    super.key,
    required this.onConfirmation,
  });

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            width: screenWidth * 0.8,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(
                width: 4.0,
                color: Colors.blue,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Instructions".tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                BuildBulletPoints(
                  texts: [
                    'Parent and child must be present.'.tr,
                    'Parent holds the phone and starts the game.'.tr,
                    'Maintain eye contact with child until the countdown ends'
                        .tr,
                    "If the child looks away early, press 'Child looked away!' to restart."
                        .tr,
                  ],
                  screenWidth: screenWidth,
                ),
                const SizedBox(height: 16.0),
                AnimatedButton(
                    height: screenHeight * 0.08,
                    color: Colors.blue,
                    onPressed: widget.onConfirmation,
                    child: Text('OK',
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.06)))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

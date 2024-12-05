import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/widgets/built_bullet_points.dart';

class SimonSaysDisclaimerDialog extends StatefulWidget {
  final Function() onConfirmation;

  const SimonSaysDisclaimerDialog({
    super.key,
    required this.onConfirmation,
  });

  @override
  State<SimonSaysDisclaimerDialog> createState() =>
      _SimonSaysDisclaimerDialogState();
}

class _SimonSaysDisclaimerDialogState extends State<SimonSaysDisclaimerDialog>
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
                    'Listen carefully to the instructions provided.',
                    'Observe the example pictures to understand the actions clearly.',
                    'Children should perform the actions themselves.',
                    'Play under parent supervision if needed for guidance.',
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

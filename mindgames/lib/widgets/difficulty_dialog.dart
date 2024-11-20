import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/extensions/string_extensions.dart';
import 'package:mindgames/utils/difficulty_enum.dart';

class DifficultyDialog extends StatefulWidget {
  final Function(Difficulty) onDifficultySelected;

  const DifficultyDialog(
      {Key? key,
      required this.onDifficultySelected,
      required Null Function() onBackPressed})
      : super(key: key);

  @override
  _DifficultyDialogState createState() => _DifficultyDialogState();
}

class _DifficultyDialogState extends State<DifficultyDialog>
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context, screenWidth, screenHeight),
      ),
    );
  }

  Widget _buildDialogContent(
      BuildContext context, double screenWidth, double screenHeight) {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            width: screenWidth * 0.8,
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(25.0),
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
                  "Choose Difficulty".tr,
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildDifficultyButton(context, Difficulty.easy, Colors.green,
                    screenHeight, screenWidth),
                _buildDifficultyButton(context, Difficulty.medium,
                    Colors.orange, screenHeight, screenWidth),
                _buildDifficultyButton(context, Difficulty.hard, Colors.red,
                    screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(BuildContext context, Difficulty difficulty,
      Color color, double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedButton(
          width: screenWidth * 0.3,
          height: screenHeight * 0.08,
          color: color,
          onPressed: () {
            widget.onDifficultySelected(difficulty);
            _controller.reverse().then((_) => Navigator.of(context).pop());
          },
          child: Text(
            difficulty.name.capitalize().tr,
            style: TextStyle(
              fontSize: screenHeight * 0.03,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

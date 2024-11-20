import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkipButton extends StatefulWidget {
  final String buttonText;
  final double elevation;
  final double height;
  final double width;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final Function() onPressed;

  const SkipButton({
    Key? key,
    required this.onPressed,
    this.buttonText = 'Skip',
    this.elevation = 15.0,
    this.height = 50.0,
    this.width = 100.0,
    this.fontSize = 24.0,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: widget.elevation,
          borderRadius: BorderRadius.circular(25),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  widget.buttonText.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

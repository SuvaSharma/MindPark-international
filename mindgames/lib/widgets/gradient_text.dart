import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Gradient gradient;

  const GradientText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Required for ShaderMask to work properly
        ),
      ),
    );
  }
}

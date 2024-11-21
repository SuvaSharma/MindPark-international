import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';

class CustomValueIndicatorShape extends SliderComponentShape {
  final double indicatorWidth;
  final double indicatorHeight;
  final Color labelBackgroundColor;
  final double padding; // Add a padding property

  CustomValueIndicatorShape({
    this.indicatorWidth = 1.0,
    this.indicatorHeight = 1.0,
    this.labelBackgroundColor = Colors.black, // Default label background color
    this.padding = 16.0, // Default padding value
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(indicatorWidth, indicatorHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Paint paint = Paint()
      ..color = sliderTheme.valueIndicatorColor!
      ..style = PaintingStyle.fill;

    final Offset customCenter = Offset(center.dx, center.dy - 40);
    final Rect rect = Rect.fromCenter(
        center: customCenter,
        width: indicatorWidth * 2,
        height: indicatorHeight);

    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(25.0));
    context.canvas.drawRRect(rrect, paint);

    // Paint the label background with padding
    final Paint labelBackgroundPaint = Paint()
      ..color = labelBackgroundColor
      ..style = PaintingStyle.fill;

    final Rect labelRect = Rect.fromCenter(
        center: customCenter,
        width: labelPainter.width + padding * 2, // Add padding around the text
        height: labelPainter.height + padding); // Add padding around the text

    final RRect labelRRect =
        RRect.fromRectAndRadius(labelRect, Radius.circular(8.0));
    context.canvas.drawRRect(labelRRect, labelBackgroundPaint);

    // Paint the label text
    labelPainter.paint(
      context.canvas,
      Offset(customCenter.dx - (labelPainter.width / 2),
          customCenter.dy - (labelPainter.height / 2)),
    );
  }
}

class AutismQuestionSlider extends StatelessWidget {
  final String question;
  final double answer;
  final ValueChanged<double> onChanged;

  const AutismQuestionSlider({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  Color getSliderColor(double value) {
    if (value < 1.0) {
      return Colors.green;
    } else if (value < 2.0) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String getLabelText(double value) {
    switch (value.round()) {
      case 0:
        return "Never".tr;
      case 1:
        return "Sometimes".tr;
      case 2:
        return "Often".tr;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String questionIndex = question.split(". ")[0];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenWidth * 0.08,
                child: Text(
                  convertToNepaliNumbers('$questionIndex.'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.01),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: getSliderColor(answer),
              inactiveTrackColor: getSliderColor(answer).withOpacity(0.5),
              thumbColor: getSliderColor(answer),
              overlayColor: getSliderColor(answer).withOpacity(0.2),
              trackHeight: screenHeight * 0.03,
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: screenHeight * 0.025),
              overlayShape:
                  RoundSliderOverlayShape(overlayRadius: screenHeight * 0.04),
              valueIndicatorShape: CustomValueIndicatorShape(
                labelBackgroundColor: getSliderColor(
                    answer), // Set the background color for the label
                padding: 8.0, // Add padding inside the custom value indicator
              ),
              showValueIndicator: ShowValueIndicator
                  .always, // Ensure value indicator is always shown
              valueIndicatorTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: answer,
              min: 0.0,
              max: 2.0,
              divisions: 2,
              label: getLabelText(answer),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

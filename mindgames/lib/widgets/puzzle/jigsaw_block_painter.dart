import 'package:flutter/material.dart';
import 'package:mindgames/utils/puzzle/get_piece_path.dart';
import 'package:mindgames/widgets/puzzle/image_box.dart';

class JigsawBlockPainter extends CustomPainter {
  ImageBox imageBox;

  JigsawBlockPainter({
    required this.imageBox,
  });
  @override
  void paint(Canvas canvas, Size size) {
    // we make function so later custom painter can use same path
    // yeayyyy
    Paint paint = Paint()
      ..color = imageBox.isDone
          ? Colors.white.withOpacity(0.2)
          : Colors.white //will use later
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
        getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
            imageBox.posSide),
        paint);

    if (imageBox.isDone) {
      Paint paintDone = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      canvas.drawPath(
          getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
              imageBox.posSide),
          paintDone);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

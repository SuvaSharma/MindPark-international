import 'package:flutter/material.dart';
import 'package:mindgames/widgets/puzzle/image_box.dart';
import 'package:mindgames/widgets/puzzle/jigsaw_block_painter.dart';
import 'package:mindgames/widgets/puzzle/puzzle_piece_clipper.dart';

class JigsawBlockWidget extends StatefulWidget {
  ImageBox imageBox;
  JigsawBlockWidget({super.key, required this.imageBox});

  @override
  _JigsawBlockWidgetState createState() => _JigsawBlockWidgetState();
}

class _JigsawBlockWidgetState extends State<JigsawBlockWidget> {
  // lets start clip crop image so show like jigsaw puzzle

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PuzzlePieceClipper(imageBox: widget.imageBox),
      child: CustomPaint(
        foregroundPainter: JigsawBlockPainter(imageBox: widget.imageBox),
        child: widget.imageBox.image,
      ),
    );
  }
}

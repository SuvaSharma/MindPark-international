import 'package:flutter/material.dart';
import 'package:mindgames/widgets/puzzle/class_jigsaw_pos.dart';

class ImageBox {
  Widget image;
  ClassJigsawPos posSide;
  Offset offsetCenter;
  Size size;
  double radiusPoint;
  bool isDone;

  ImageBox({
    required this.image,
    required this.posSide,
    required this.isDone,
    required this.offsetCenter,
    required this.radiusPoint,
    required this.size,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin LandscapeModeMixin on StatelessWidget {
  void enforceLandscapeMode(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void releaseLandscapeMode(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

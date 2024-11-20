import 'dart:ui';

class StroopData {
  int? id;
  String word;
  Color color;
  bool isCompatible;
  String status;

  StroopData({
    this.id,
    required this.word,
    required this.color,
    required this.isCompatible,
    required this.status,
  });

  // Convert a StroopData object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'color': color.value, // store color as an integer
      'isCompatible': isCompatible ? 1 : 0,
      'status': status,
    };
  }
}

import 'package:mindgames/utils/difficulty_enum.dart';

class PuzzleParadiseModel {
  String? id;
  String? userId;
  DateTime sessionId;
  String level;
  String status;
  Difficulty difficulty;
  String imageName;
  int timeTaken;

  PuzzleParadiseModel({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.level,
    required this.status,
    required this.difficulty,
    required this.imageName,
    required this.timeTaken,
  });

  @override
  String toString() {
    return 'userId: $userId, sessionId: $sessionId, level: $level, status: $status, difficulty: $difficulty, imageName: $imageName, timeTaken: $timeTaken';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId,
        'level': level,
        'status': status,
        'difficulty': difficulty,
        'image_name': imageName,
        'time_taken': timeTaken,
      };

  factory PuzzleParadiseModel.fromMap(Map<String, dynamic> map) =>
      PuzzleParadiseModel(
        id: map['id'],
        userId: map['user_id'],
        sessionId: map['session_id'],
        level: map['level'],
        status: map['status'],
        difficulty: map['difficulty'],
        imageName: map['image_name'],
        timeTaken: map['time_taken'],
      );
}

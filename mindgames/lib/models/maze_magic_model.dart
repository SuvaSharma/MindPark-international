import 'package:mindgames/utils/difficulty_enum.dart';

class MazeMagicModel {
  String? id;
  String? userId;
  DateTime sessionId;
  String level;
  String status;
  Difficulty difficulty;
  int timeTaken;

  MazeMagicModel({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.level,
    required this.status,
    required this.difficulty,
    required this.timeTaken,
  });

  @override
  String toString() {
    return 'userId: $userId, sessionId: $sessionId, level: $level, $status: status, difficulty: $difficulty, timeTaken: $timeTaken';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId,
        'level': level,
        'status': status,
        'difficulty': difficulty,
        'time_taken': timeTaken,
      };

  factory MazeMagicModel.fromMap(Map<String, dynamic> map) => MazeMagicModel(
        id: map['id'],
        userId: map['user_id'],
        sessionId: map['session_id'],
        level: map['level'],
        status: map['status'],
        difficulty: map['difficulty'],
        timeTaken: map['time_taken'],
      );
}

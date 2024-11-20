import 'package:mindgames/utils/difficulty_enum.dart';

class NumberCountingModel {
  int? id;
  String? userId;
  String level;
  Difficulty difficulty;
  int score;
  double accuracy;
  DateTime sessionId;

  NumberCountingModel({
    this.id,
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.score,
    required this.accuracy,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, SessionId: $sessionId, score:$score accuracy: $accuracy';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'score': score,
        'accuracy': accuracy,
      };

  factory NumberCountingModel.fromMap(Map<String, dynamic> map) =>
      NumberCountingModel(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        difficulty: map['difficulty'],
        sessionId: map['session_id'],
        score: map['score'],
        accuracy: map['accuracy'],
      );
}

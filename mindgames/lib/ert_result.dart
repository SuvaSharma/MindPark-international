import 'package:mindgames/utils/difficulty_enum.dart';

class ERTResult {
  String? userId;
  String level;
  Difficulty difficulty;
  DateTime sessionId;
  double accuracy;
  int score;

  ERTResult({
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.accuracy,
    required this.score,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, sessionId: $sessionId, accuracy: $accuracy, score: $score';
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'accuracy': accuracy,
        'score': score,
      };

  factory ERTResult.fromMap(Map<String, dynamic> map) {
    return ERTResult(
      userId: map['user_id'],
      level: map['level'],
      difficulty: map['difficulty'],
      sessionId: map['session_id'],
      accuracy: map['accuracy'],
      score: map['score'],
    );
  }
}

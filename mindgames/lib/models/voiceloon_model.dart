import 'package:mindgames/utils/difficulty_enum.dart';

class VoiceloonModel {
  String? userId;
  String level;
  Difficulty difficulty;
  DateTime sessionId;
  int score;
  double accuracy;
  String status;
  int responseTime;

  VoiceloonModel({
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.score,
    required this.accuracy,
    required this.status,
    required this.responseTime,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, sessionId: $sessionId, score: $score, accuracy: $accuracy, responseTime: $responseTime';
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'score': score,
        'accuracy': accuracy,
        'status': status,
        'response_time': responseTime,
      };

  factory VoiceloonModel.fromMap(Map<String, dynamic> map) {
    return VoiceloonModel(
      userId: map['user_id'],
      level: map['level'],
      difficulty: map['difficulty'],
      sessionId: map['session_id'],
      score: map['score'],
      accuracy: map['accuracy'],
      status: map['status'],
      responseTime: map['response_time'],
    );
  }
}

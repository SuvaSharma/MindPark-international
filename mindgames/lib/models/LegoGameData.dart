import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindgames/utils/difficulty_enum.dart';

class LegoGameData {
  String? userId;
  DateTime sessionId;
  String level;
  Difficulty difficulty;
  double accuracy;

  final int elapsedTime;

  LegoGameData({
    required this.userId,
    required this.sessionId,
    required this.level,
    required this.difficulty,
    required this.accuracy,
    required this.elapsedTime,
  });

  @override
  String toString() {
    return 'UserId: $userId, sessionId: $sessionId, level: $level, difficulty: $difficulty, accuracy: $accuracy';
    //  score: $score, timeTaken: $timeTaken';
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'session_id': Timestamp.fromDate(sessionId),
        'level': level,
        'difficulty': difficulty,
        'accuracy': accuracy,
        // 'score': score,
        // 'time_taken': timeTaken.inMilliseconds,
      };

  factory LegoGameData.fromMap(Map<String, dynamic> map) {
    return LegoGameData(
      userId: map['user_id'],
      sessionId: (map['session_id'] as Timestamp).toDate(),
      level: map['level'],
      difficulty: map['difficulty'],
      accuracy: map['accuracy'],
      elapsedTime: map['elapsedTime'],
    );
  }
}

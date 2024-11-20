import 'package:mindgames/utils/difficulty_enum.dart';

class JungleJinglesModel {
  int? id;
  String? userId;
  String level;
  Difficulty difficulty;
  double score;
  DateTime sessionId;

  JungleJinglesModel({
    this.id,
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.score,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, SessionId: $sessionId, score:$score';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'score': score,
      };

  factory JungleJinglesModel.fromMap(Map<String, dynamic> map) =>
      JungleJinglesModel(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        difficulty: map['difficulty'],
        sessionId: map['session_id'],
        score: map['score'],
      );
}

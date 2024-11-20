import 'package:mindgames/utils/difficulty_enum.dart';

class SimonSaysModel {
  int? id;
  String? userId;
  String level;
  Difficulty difficulty;
  double score;
  DateTime sessionId;
  List<Map<String, dynamic>> gameData;

  SimonSaysModel({
    this.id,
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.score,
    required this.gameData,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, SessionId: $sessionId, score:$score, GameData: $gameData';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'score': score,
        'game_data': gameData,
      };

  factory SimonSaysModel.fromMap(Map<String, dynamic> map) => SimonSaysModel(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        difficulty: map['difficulty'],
        sessionId: map['session_id'],
        score: map['score'],
        gameData: map['game_data'],
      );
}

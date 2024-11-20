import 'package:mindgames/utils/difficulty_enum.dart';

class TMTResult {
  int? id;
  String? userId;
  String level;
  Difficulty difficulty;
  double accuracy;
  double averageTime;
  DateTime sessionId;
  List<Map<String, dynamic>> gameData;

  TMTResult({
    this.id,
    required this.userId,
    required this.level,
    required this.difficulty,
    required this.sessionId,
    required this.accuracy,
    required this.averageTime,
    required this.gameData,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, difficulty: $difficulty, SessionId: $sessionId, accuracy:$accuracy, GameData: $gameData';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'difficulty': difficulty,
        'session_id': sessionId,
        'accuracy': accuracy,
        'game_data': gameData,
      };

  factory TMTResult.fromMap(Map<String, dynamic> map) => TMTResult(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        difficulty: map['difficulty'],
        sessionId: map['session_id'],
        accuracy: map['accuracy'],
        averageTime: map['averageTime'],
        gameData: map['game_data'],
      );
}

import 'package:mindgames/utils/difficulty_enum.dart';

class GazeMazeModel {
  String? userId;
  DateTime sessionId;
  String level;
  Difficulty difficulty;
  int score;
  double averageStareTime;
  double accuracy;
  List<Map<String, dynamic>> gameData;

  GazeMazeModel({
    required this.userId,
    required this.sessionId,
    required this.level,
    required this.difficulty,
    required this.score,
    required this.averageStareTime,
    required this.accuracy,
    required this.gameData,
  });

  @override
  String toString() {
    return "userId: $userId, sessionId: $sessionId, level: $level, difficulty: $difficulty, score: $score, averageStareTime: $averageStareTime, accuracy: $accuracy, gameData: $gameData";
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'session_id': sessionId,
        'level': level,
        'difficulty': difficulty,
        'score': score,
        'average_stare_time': averageStareTime,
        'accuracy': accuracy,
        'game_data': gameData,
      };

  factory GazeMazeModel.fromMap(Map<String, dynamic> map) => GazeMazeModel(
        userId: map['user_id'],
        sessionId: map['session_id'],
        level: map['level'],
        difficulty: map['difficulty'],
        score: map['score'],
        averageStareTime: map['average_stare_time'],
        accuracy: map['accuracy'],
        gameData: map['game_data'],
      );
}

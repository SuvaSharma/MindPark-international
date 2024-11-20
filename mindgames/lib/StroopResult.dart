class StroopResult {
  int? id;
  String? userId;
  String level;
  DateTime sessionId;
  double compatible;
  double incompatible;
  double stroopScore;
  int correctResponse;
  int incorrectResponse;
  double accuracy;

  StroopResult({
    this.id,
    required this.userId,
    required this.level,
    required this.sessionId,
    required this.compatible,
    required this.incompatible,
    required this.stroopScore,
    required this.correctResponse,
    required this.incorrectResponse,
    required this.accuracy,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, SessionId: $sessionId, compatible: $compatible, incompatible: $incompatible, stroopScore: $stroopScore, correctResponse: $correctResponse, incorrectResponse: $incorrectResponse, accuracy: $accuracy';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'session_id': sessionId,
        'compatible': compatible,
        'incompatible': incompatible,
        'stroop_score': stroopScore,
        'correct_response': correctResponse,
        'incorrect_response': incorrectResponse,
        'accuracy': accuracy,
      };

  factory StroopResult.fromMap(Map<String, dynamic> map) => StroopResult(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        sessionId: map['session_id'],
        compatible: map['compatible'],
        incompatible: map['incompatible'],
        stroopScore: map['stroop_score'],
        correctResponse: map['correct_response'],
        incorrectResponse: map['incorrect_response'],
        accuracy: map['accuracy'],
      );
}

class Word {
  int? id;
  String? userId;
  DateTime sessionId;
  int trialId;
  String word;
  String color;
  String type;
  String result;
  int responseTime;

  Word({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.trialId,
    required this.word,
    required this.color,
    required this.type,
    required this.result,
    required this.responseTime,
  });

  @override
  String toString() {
    return 'UserId: $userId, SessionId: $sessionId, TrialId: $trialId, word: $word, color: $color, type: $type, result: $result, responseTime: $responseTime';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId.toIso8601String(),
        'trial_id': trialId,
        'word': word,
        'color': color,
        'type': type,
        'result': result,
        'response_time': responseTime,
      };

  factory Word.fromMap(Map<String, dynamic> map) => Word(
        id: map['id'],
        userId: map['user_id'],
        sessionId: DateTime.parse(map['session_id']),
        trialId: map['trial_id'],
        word: map['word'],
        color: map['color'],
        type: map['type'],
        result: map['result'],
        responseTime: map['response_time'],
      );
}

class DSTResult {
  int? id;
  String? userId;
  String level;
  DateTime sessionId;
  int score;
  double span;

  DSTResult({
    this.id,
    required this.userId,
    required this.level,
    required this.sessionId,
    required this.score,
    required this.span,
  });

  @override
  String toString() {
    return 'userId: $userId, level: $level, sessionId: $sessionId, score: $score, span: $span';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'session_id': sessionId,
        'score': score,
        'span': span,
      };

  factory DSTResult.fromMap(Map<String, dynamic> map) => DSTResult(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        sessionId: map['session_id'],
        score: map['score'],
        span: map['span'],
      );
}

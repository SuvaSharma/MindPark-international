class SDMTResult {
  int? id;
  String? userId;
  String level;
  DateTime sessionId;
  double score;
  int incorrectChoice;
  int totalTrials;
  double accuracy;
  double meanReactionTime;

  SDMTResult({
    this.id,
    required this.userId,
    required this.level,
    required this.sessionId,
    required this.score,
    required this.incorrectChoice,
    required this.totalTrials,
    required this.accuracy,
    required this.meanReactionTime,
  });

  @override
  String toString() {
    return 'userId: $userId, level: $level, sessionId: $sessionId, score: $score, incorrectChoice: $incorrectChoice, totalTrials: $totalTrials, accuracy: $accuracy, meanReactionTime: $meanReactionTime';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'session_id': sessionId,
        'score': score,
        'incorrect_choice': incorrectChoice,
        'total_trials': totalTrials,
        'accuracy': accuracy,
        'mean_reaction_time': meanReactionTime,
      };

  factory SDMTResult.fromMap(Map<String, dynamic> map) => SDMTResult(
        id: map['id'],
        userId: map['user_id'],
        level: map['level'],
        sessionId: map['session_id'],
        score: map['score'],
        incorrectChoice: map['incorrect_choice'],
        totalTrials: map['total_trials'],
        accuracy: map['accuracy'],
        meanReactionTime: map['mean_reaction_time'],
      );
}

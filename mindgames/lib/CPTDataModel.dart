class CPTData {
  int? id;
  String? userId;
  DateTime sessionId;
  int trialId;
  String letter;
  String result;
  int responseTime;

  CPTData({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.trialId,
    required this.letter,
    required this.result,
    required this.responseTime,
  });

  @override
  String toString() {
    return 'UserId: $userId, SessionId: $sessionId, TrialId: $trialId, letter: $letter, result: $result, responseTime: $responseTime';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId.toIso8601String(),
        'trial_id': trialId,
        'letter': letter,
        'result': result,
        'response_time': responseTime,
      };

  factory CPTData.fromMap(Map<String, dynamic> map) => CPTData(
        id: map['id'],
        userId: map['user_id'],
        sessionId: DateTime.parse(map['session_id']),
        trialId: map['trial_id'],
        letter: map['letter'],
        result: map['result'],
        responseTime: map['response_time'],
      );
}

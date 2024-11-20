class DSTData {
  int? id;
  String? userId;
  DateTime sessionId;
  int trialId;
  String sequenceGiven;
  String sequenceEntered;
  String result;
  int responseTime;

  DSTData({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.trialId,
    required this.sequenceGiven,
    required this.sequenceEntered,
    required this.result,
    required this.responseTime,
  });

  @override
  String toString() {
    return 'userId: $userId, sessionId: $sessionId, trialId: $trialId, sequenceGiven: $sequenceGiven, sequenceEntered: $sequenceEntered, result: $result, responseTime: $responseTime';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId.toIso8601String(),
        'trial_id': trialId,
        'sequence_given': sequenceGiven,
        'sequence_entered': sequenceEntered,
        'result': result,
        'response_time': responseTime,
      };

  factory DSTData.fromMap(Map<String, dynamic> map) => DSTData(
        id: map['id'],
        userId: map['user_id'],
        sessionId: map['session_id'],
        trialId: map['trial_id'],
        sequenceGiven: map['sequence_given'],
        sequenceEntered: map['sequence_entered'],
        result: map['result'],
        responseTime: map['response_time'],
      );
}

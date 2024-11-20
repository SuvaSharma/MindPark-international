class GameData {
  final int? id;
  final String? userId;
  final DateTime sessionId;
  final int blockId;
  final int trialId;
  final int result;
  final int responseTime;
  final DateTime symbolDisplayTime;

  GameData({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.blockId,
    required this.trialId,
    required this.result,
    required this.responseTime,
    required this.symbolDisplayTime,
  });

  @override
  String toString() {
    return 'UserId: $userId, SessionId: $sessionId, BlockId: $blockId, TrialId: $trialId, result: $result, responseTime: $responseTime, symbolDisplayTime: $symbolDisplayTime';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'block_id': blockId,
      'trial_id': trialId,
      'result': result,
      'response_time': responseTime,
      'symbol_display_time': symbolDisplayTime
          .millisecondsSinceEpoch, // Convert DateTime to milliseconds
    };
  }

  factory GameData.fromMap(Map<String, dynamic> map) {
    return GameData(
      id: map['id'],
      userId: map['user_id'],
      sessionId: map['session_id'],
      blockId: map['block_id'],
      trialId: map['trial_id'],
      result: map['result'],
      responseTime: map['response_time'],
      symbolDisplayTime: map['symbol_display_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['symbol_display_time'])
          : DateTime
              .now(), // You can replace DateTime.now() with any default value you prefer
    );
  }
}

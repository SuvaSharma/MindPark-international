class CPTResult {
  int? id;
  String? userId;
  String level;
  DateTime sessionId;
  double accuracy;
  double responseTime;
  double commissionError;
  double omissionError;
  double inhibitoryControl;

  CPTResult({
    this.id,
    required this.userId,
    required this.level,
    required this.sessionId,
    required this.accuracy,
    required this.responseTime,
    required this.commissionError,
    required this.omissionError,
    required this.inhibitoryControl,
  });

  @override
  String toString() {
    return 'UserId: $userId, level: $level, sessionId: $sessionId, accuracy: $accuracy, responseTime: $responseTime, commissionError: $commissionError, omissionError: $omissionError, inhibitoryControl: $inhibitoryControl';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'session_id': sessionId,
        'accuracy': accuracy,
        'response_time': responseTime,
        'commission_error': commissionError,
        'omission_error': omissionError,
        'inhibitory_control': inhibitoryControl,
      };

  factory CPTResult.fromMap(Map<String, dynamic> map) {
    return CPTResult(
      id: map['id'],
      userId: map['user_id'],
      level: map['level'],
      sessionId: map['sessionId'],
      accuracy: map['accuracy'],
      responseTime: map['response_time'],
      commissionError: map['commission_error'],
      omissionError: map['omission_error'],
      inhibitoryControl: map['inhibitory_control'],
    );
  }
}

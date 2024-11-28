class GameRecordModel {
  int? id;
  String difficulty;
  int charactersCount;
  int incorrectTaps;
  String date;

  GameRecordModel({
    this.id,
    required this.difficulty,
    required this.charactersCount,
    required this.incorrectTaps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'difficulty': difficulty,
      'charactersCount': charactersCount,
      'incorrectTaps': incorrectTaps,
      'date': date,
    };
  }

  static GameRecordModel fromMap(Map<String, dynamic> map) {
    return GameRecordModel(
      id: map['id'],
      difficulty: map['difficulty'],
      charactersCount: map['charactersCount'],
      incorrectTaps: map['incorrectTaps'],
      date: map['date'],
    );
  }
}

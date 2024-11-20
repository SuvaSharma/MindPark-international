class QuestionnaireResponse {
  String userId;
  String childId;
  String category;
  DateTime assessmentDate;
  List<Map<String, dynamic>> response;

  QuestionnaireResponse({
    required this.userId,
    required this.childId,
    required this.category,
    required this.assessmentDate,
    required this.response,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'child_id': childId,
        'category': category,
        'assessment_date': assessmentDate,
        'response': response,
      };

  factory QuestionnaireResponse.fromMap(Map<String, dynamic> map) {
    return QuestionnaireResponse(
        userId: map['user_id'],
        childId: map['child_id'],
        category: map['category'],
        assessmentDate: map['assessment_date'],
        response: map['response']);
  }
}

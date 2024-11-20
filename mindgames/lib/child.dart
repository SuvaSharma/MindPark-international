class Child {
  final String childId;
  final int age;
  final String name;
  final String gender;
  final DateTime createdDate;

  Child({
    required this.childId,
    required this.age,
    required this.name,
    required this.gender,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['childId'] ?? '',
      age: json['age'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
    );
  }
}

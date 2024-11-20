class User {
  String userId;
  String name;
  String email;
  String? gender;
  String? age;
  List<Map<String, dynamic>>? children;

  User({
    required this.userId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'gender': gender,
        'age': age,
        'children': children
      };
}

class Task {
  final int id;
  final String name;
  final int duration;

  Task({
    required this.id,
    required this.name,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
    };
  }
}

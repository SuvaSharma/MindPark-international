class Blog {
  String? id;
  String title;
  String subtitle;
  String author;
  DateTime date;
  String content;
  String posterImgUrl;
  int readTime;
  List<String>? tags;

  Blog({
    required this.title,
    required this.subtitle,
    required this.author,
    required this.date,
    required this.content,
    required this.posterImgUrl,
    required this.readTime,
    this.tags,
  });
}

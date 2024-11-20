class GraphData {
  int year;
  int month;
  double data;

  GraphData({
    required this.year,
    required this.month,
    required this.data,
  });

  @override
  String toString() {
    return '(year: $year, month: $month, data: $data)';
  }
}

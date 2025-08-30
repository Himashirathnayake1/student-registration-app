class Assignment {
  final String title;
  final int marks;
  final String grade;

  Assignment({
    required this.title,
    required this.marks,
    required this.grade,
  });

  factory Assignment.fromMap(Map<String, dynamic> data) {
    return Assignment(
      title: data['title'] ?? '',
      marks: data['marks'] ?? 0,
      grade: data['grade'] ?? '',
    );
  }
}

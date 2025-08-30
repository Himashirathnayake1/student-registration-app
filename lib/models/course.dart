class Course {
  final String id;
  final String name;
  final String description;
  final int credits;
  final String instructor;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.instructor,

  });

  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      credits: data['credits'] ?? 0,
      instructor: data['instructor'] ?? '',
    );
  }
}

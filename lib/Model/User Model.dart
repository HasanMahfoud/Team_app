class AppUser {
  final String name;
  final String email;
  final String studentId;
  final String college;
  final String studyYear;
  final String joinYear;
  final String role;

  AppUser({
    required this.name,
    required this.email,
    required this.studentId,
    required this.college,
    required this.studyYear,
    required this.joinYear,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      college: data['college'] ?? '',
      studyYear: data['studyYear'] ?? '',
      joinYear: data['joinYear'] ?? '',
      role: data['role'] ?? 'user',
    );
  }
}

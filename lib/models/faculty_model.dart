class FacultyModel {
  final String id;
  final String facultyCode;
  final String facultyName;

  FacultyModel({
    required this.id,
    required this.facultyCode,
    required this.facultyName,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'],
      facultyCode: json['faculty_code'],
      facultyName: json['faculty_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_code': facultyCode,
      'faculty_name': facultyName,
    };
  }
}

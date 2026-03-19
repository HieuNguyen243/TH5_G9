import 'faculty_model.dart';

class MajorModel {
  final String id;
  final String majorCode;
  final String majorName;
  final String facultyId;
  final FacultyModel? faculty;

  MajorModel({
    required this.id,
    required this.majorCode,
    required this.majorName,
    required this.facultyId,
    this.faculty,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: json['id'],
      majorCode: json['major_code'],
      majorName: json['major_name'],
      facultyId: json['faculty_id'],
      faculty: json['faculties'] != null ? FacultyModel.fromJson(json['faculties']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'major_code': majorCode,
      'major_name': majorName,
      'faculty_id': facultyId,
    };
  }
}

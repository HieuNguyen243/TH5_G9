import 'major_model.dart';

class StudentModel {
  final String? id;
  final String studentCode;
  final String fullName;
  final String majorId;
  final String? avatarUrl;
  final double? gpa;
  final MajorModel? major;

  StudentModel({
    this.id,
    required this.studentCode,
    required this.fullName,
    required this.majorId,
    this.avatarUrl,
    this.gpa,
    this.major,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      studentCode: json['student_code'],
      fullName: json['full_name'],
      majorId: json['major_id'],
      avatarUrl: json['avatar_url'],
      gpa: json['gpa'] != null ? double.tryParse(json['gpa'].toString()) : null,
      major: json['majors'] != null ? MajorModel.fromJson(json['majors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'student_code': studentCode,
      'full_name': fullName,
      'major_id': majorId,
      'avatar_url': avatarUrl,
      if (gpa != null) 'gpa': gpa,
    };
  }

  StudentModel copyWith({
    String? id,
    String? studentCode,
    String? fullName,
    String? majorId,
    String? avatarUrl,
    double? gpa,
    MajorModel? major,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      majorId: majorId ?? this.majorId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gpa: gpa ?? this.gpa,
      major: major ?? this.major,
    );
  }
}

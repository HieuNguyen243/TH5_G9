import 'class_model.dart';
import 'package:intl/intl.dart';

class StudentModel {
  final String? id;
  final String studentCode;
  final String fullName;
  final String classId; // Changed from majorId
  final String? avatarUrl;
  final double? gpa;
  final String? hometown;
  final DateTime? dateOfBirth;
  final String? academicStatus;
  final ClassModel? studentClass; // Changed from major

  StudentModel({
    this.id,
    required this.studentCode,
    required this.fullName,
    required this.classId,
    this.avatarUrl,
    this.gpa,
    this.hometown,
    this.dateOfBirth,
    this.academicStatus,
    this.studentClass,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      studentCode: json['student_code'],
      fullName: json['full_name'],
      classId: json['class_id'],
      avatarUrl: json['avatar_url'],
      gpa: json['gpa'] != null ? double.tryParse(json['gpa'].toString()) : null,
      hometown: json['hometown'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
      academicStatus: json['academic_status'],
      studentClass: json['classes'] != null ? ClassModel.fromJson(json['classes']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'student_code': studentCode,
      'full_name': fullName,
      'class_id': classId,
      'avatar_url': avatarUrl,
      if (gpa != null) 'gpa': gpa,
      'hometown': hometown,
      'date_of_birth': dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(dateOfBirth!) : null,
      'academic_status': academicStatus,
    };
  }

  StudentModel copyWith({
    String? id,
    String? studentCode,
    String? fullName,
    String? classId,
    String? avatarUrl,
    double? gpa,
    String? hometown,
    DateTime? dateOfBirth,
    String? academicStatus,
    ClassModel? studentClass,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      classId: classId ?? this.classId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gpa: gpa ?? this.gpa,
      hometown: hometown ?? this.hometown,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      academicStatus: academicStatus ?? this.academicStatus,
      studentClass: studentClass ?? this.studentClass,
    );
  }
}

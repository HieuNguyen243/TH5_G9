import 'major_model.dart';

class ClassModel {
  final String id;
  final String classCode;
  final String className;
  final String majorId;
  final MajorModel? major;

  ClassModel({
    required this.id,
    required this.classCode,
    required this.className,
    required this.majorId,
    this.major,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      classCode: json['class_code'],
      className: json['class_name'],
      majorId: json['major_id'],
      major: json['majors'] != null ? MajorModel.fromJson(json['majors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_code': classCode,
      'class_name': className,
      'major_id': majorId,
    };
  }
}

class MajorModel {
  final String id;
  final String majorCode;
  final String majorName;

  MajorModel({
    required this.id,
    required this.majorCode,
    required this.majorName,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: json['id'],
      majorCode: json['major_code'],
      majorName: json['major_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'major_code': majorCode,
      'major_name': majorName,
    };
  }
}

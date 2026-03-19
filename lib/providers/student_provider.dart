import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

final studentServiceProvider = Provider((ref) => StudentService());

final studentListProvider = AsyncNotifierProvider<StudentListNotifier, List<StudentModel>>(() {
  return StudentListNotifier();
});

class StudentListNotifier extends AsyncNotifier<List<StudentModel>> {
  @override
  Future<List<StudentModel>> build() async {
    return _fetch();
  }

  Future<List<StudentModel>> _fetch() async {
    final service = ref.read(studentServiceProvider);
    return await service.fetchStudentsWithHierarchy();
  }

  Future<void> loadStudents() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> addStudent(StudentModel student, Uint8List? fileBytes, String? fileName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(studentServiceProvider);
      String? avatarUrl;
      
      if (fileBytes != null && fileName != null) {
        avatarUrl = await service.uploadAvatar(fileBytes, fileName);
      }
      
      final newStudent = student.copyWith(avatarUrl: avatarUrl);
      await service.createStudent(newStudent);
      
      return _fetch();
    });
  }

  Future<void> updateStudent(
    StudentModel student, {
    Uint8List? newFileBytes,
    String? newFileName,
    bool deleteOldImage = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(studentServiceProvider);
      String? updatedAvatarUrl = student.avatarUrl;

      if ((deleteOldImage || newFileBytes != null) && student.avatarUrl != null) {
        await service.deleteAvatar(student.avatarUrl!);
        updatedAvatarUrl = null;
      }

      if (newFileBytes != null && newFileName != null) {
        updatedAvatarUrl = await service.uploadAvatar(newFileBytes, newFileName);
      }

      final updatedStudent = student.copyWith(avatarUrl: updatedAvatarUrl);
      await service.updateStudent(updatedStudent);
      
      return _fetch();
    });
  }

  Future<void> deleteStudent(StudentModel student) async {
    if (student.id == null) return;
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(studentServiceProvider);
      if (student.avatarUrl != null) {
        await service.deleteAvatar(student.avatarUrl!);
      }
      await service.deleteStudent(student.id!);
      return _fetch();
    });
  }
}

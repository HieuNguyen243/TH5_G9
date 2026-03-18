import 'dart:io';
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
    return await service.fetchStudentsWithMajors();
  }

  Future<void> loadStudents() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> addStudent(StudentModel student, File? imageFile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(studentServiceProvider);
      String? avatarUrl;
      
      if (imageFile != null) {
        avatarUrl = await service.uploadAvatar(imageFile, student.studentCode);
      }
      
      final newStudent = student.copyWith(avatarUrl: avatarUrl);
      await service.createStudent(newStudent);
      
      return _fetch();
    });
  }

  Future<void> updateStudent(
    StudentModel student, {
    File? newImage,
    bool deleteOldImage = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(studentServiceProvider);
      String? updatedAvatarUrl = student.avatarUrl;

      // Xử lý xóa ảnh cũ hoặc thay thế ảnh mới
      if ((deleteOldImage || newImage != null) && student.avatarUrl != null) {
        await service.deleteAvatar(student.avatarUrl!);
        updatedAvatarUrl = null;
      }

      // Upload ảnh mới nếu có
      if (newImage != null) {
        updatedAvatarUrl = await service.uploadAvatar(newImage, student.studentCode);
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
      
      // Xóa avatar trong Storage trước
      if (student.avatarUrl != null) {
        await service.deleteAvatar(student.avatarUrl!);
      }
      
      // Xóa record trong DB
      await service.deleteStudent(student.id!);
      
      return _fetch();
    });
  }
}

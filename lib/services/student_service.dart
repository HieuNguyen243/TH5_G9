import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import 'package:path/path.dart' as p;

class StudentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<StudentModel>> fetchStudentsWithMajors() async {
    final response = await _supabase
        .from('students')
        .select('*, majors(*)')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<void> createStudent(StudentModel student) async {
    await _supabase.from('students').insert(student.toJson());
  }
/// đây la chu thu
  Future<void> updateStudent(StudentModel student) async {
    if (student.id == null) return;
    await _supabase
        .from('students')
        .update(student.toJson())
        .eq('id', student.id!);
  }

  Future<void> deleteStudent(String id) async {
    await _supabase.from('students').delete().eq('id', id);
  }

  Future<String> uploadAvatar(File imageFile, String studentCode) async {
    final extension = p.extension(imageFile.path);
    final fileName = '$studentCode${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = fileName;

    await _supabase.storage.from('student_avatars').upload(path, imageFile);
    
    return _supabase.storage.from('student_avatars').getPublicUrl(path);
  }

  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final uri = Uri.parse(avatarUrl);
      final fileName = p.basename(uri.path);
      await _supabase.storage.from('student_avatars').remove([fileName]);
    } catch (e) {
      // Ignore errors if file doesn't exist or URL is invalid
    }
  }
}

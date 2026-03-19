import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';

class StudentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<StudentModel>> fetchStudentsWithHierarchy() async {
    final response = await _supabase
        .from('students')
        .select('*, classes(*, majors(*, faculties(*)))')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<List<dynamic>> fetchFaculties() async {
    return await _supabase.from('faculties').select().order('faculty_name');
  }

  Future<List<dynamic>> fetchMajors(String facultyId) async {
    return await _supabase
        .from('majors')
        .select()
        .eq('faculty_id', facultyId)
        .order('major_name');
  }

  Future<List<dynamic>> fetchClasses(String majorId) async {
    return await _supabase
        .from('classes')
        .select()
        .eq('major_id', majorId)
        .order('class_name');
  }

  Future<void> createStudent(StudentModel student) async {
    await _supabase.from('students').insert(student.toJson());
  }

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

  Future<String> uploadAvatar(Uint8List fileBytes, String fileName) async {
    final path = fileName;
    final extension = p.extension(fileName).toLowerCase().replaceAll('.', '');

    await _supabase.storage.from('student_avatars').uploadBinary(
      path,
      fileBytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/$extension',
      ),
    );
    
    return _supabase.storage.from('student_avatars').getPublicUrl(path);
  }

  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final uri = Uri.parse(avatarUrl);
      final fileName = p.basename(uri.path);
      await _supabase.storage.from('student_avatars').remove([fileName]);
    } catch (e) {
      // Ignore errors
    }
  }
}

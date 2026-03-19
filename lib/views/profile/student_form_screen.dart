import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentModel? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _studentCodeController;
  late TextEditingController _majorIdController;
  
  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.student?.fullName ?? '');
    _studentCodeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _majorIdController = TextEditingController(text: widget.student?.majorId ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _majorIdController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      // In a full implementation, you'd use a Provider to save to Supabase here.
      // E.g., ref.read(studentProvider.notifier).upsertStudent(newStudent);
      
      final newStudent = StudentModel(
        id: widget.student?.id,
        studentCode: _studentCodeController.text.trim(),
        fullName: _fullNameController.text.trim(),
        majorId: _majorIdController.text.trim(),
        avatarUrl: widget.student?.avatarUrl,
      );

      // Go back to previous screen, optionally returning the new/updated student
      Navigator.of(context).pop(newStudent);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Đã cập nhật sinh viên!' : 'Đã thêm sinh viên mới!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa Sinh viên' : 'Thêm Sinh viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      backgroundImage: widget.student?.avatarUrl != null 
                        ? NetworkImage(widget.student!.avatarUrl!) 
                        : null,
                      child: widget.student?.avatarUrl == null 
                        ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant) 
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: () {
                            // Implement image picking if needed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tính năng chọn ảnh sẽ cập nhật sau.')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _fullNameController,
                label: 'Họ và tên',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _studentCodeController,
                label: 'Mã số SV',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã sinh viên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // For a real app, this should probably be a Dropdown/Select for Major
              CustomTextField(
                controller: _majorIdController,
                label: 'ID Ngành học',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập ngành học';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 48),
              
              CustomButton(
                text: isEditing ? 'Lưu Thay đổi' : 'Thêm Sinh viên',
                onPressed: _saveStudent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

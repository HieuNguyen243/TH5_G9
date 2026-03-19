import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final StudentModel? student;

  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _studentCodeController;
  late TextEditingController _majorIdController;
  late TextEditingController _gpaController;
  
  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.student?.fullName ?? '');
    _studentCodeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _majorIdController = TextEditingController(text: widget.student?.majorId ?? '');
    _gpaController = TextEditingController(text: widget.student?.gpa?.toString() ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _majorIdController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      
      final newStudent = StudentModel(
        id: widget.student?.id,
        studentCode: _studentCodeController.text.trim(),
        fullName: _fullNameController.text.trim(),
        majorId: _majorIdController.text.trim(),
        gpa: double.tryParse(_gpaController.text.trim()),
        avatarUrl: widget.student?.avatarUrl,
      );

      // Call the appropriate provider method
      if (isEditing) {
        ref.read(studentListProvider.notifier).updateStudent(newStudent);
      } else {
        ref.read(studentListProvider.notifier).addStudent(newStudent, null);
      }

      // Go back to previous screen
      if (mounted) {
        context.pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Đã cập nhật sinh viên!' : 'Đã thêm sinh viên mới!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
                  final codeRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                  if (!codeRegex.hasMatch(value.trim())) {
                    return 'Mã SV chỉ chứa chữ, số và dấu gạch dưới';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _gpaController,
                label: 'Điểm GPA',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập điểm GPA';
                  }
                  final gpa = double.tryParse(value.trim());
                  if (gpa == null || gpa < 0.0 || gpa > 4.0) {
                    return 'GPA phải là số từ 0.0 đến 4.0';
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

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/student_service.dart';

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
  late TextEditingController _hometownController;
  late TextEditingController _gpaController;

  String? _selectedFacultyId;
  String? _selectedMajorId;
  String? _selectedClassId;

  List<dynamic> _faculties = [];
  List<dynamic> _majors = [];
  List<dynamic> _classes = [];

  DateTime? _selectedDate;
  String? _selectedAcademicStatus;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  final ImagePicker _picker = ImagePicker();
  
  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.student?.fullName ?? '');
    _studentCodeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _hometownController = TextEditingController(text: widget.student?.hometown ?? '');
    _gpaController = TextEditingController(
      text: widget.student != null ? widget.student!.gpa?.toString() ?? '' : '',
    );
    _selectedDate = widget.student?.dateOfBirth;
    _selectedAcademicStatus = widget.student?.academicStatus ?? 'Đang học';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHierarchy();
    });
  }

  Future<void> _initHierarchy() async {
    final service = ref.read(studentServiceProvider);
    final faculties = await service.fetchFaculties();

    if (!mounted) return;

    setState(() {
      _faculties = faculties;
    });

    if (isEditing && widget.student?.studentClass != null) {
      final sClass = widget.student!.studentClass!;
      final sMajor = sClass.major!;

      setState(() {
        _selectedFacultyId = sMajor.facultyId;
      });

      await _onFacultyChanged(sMajor.facultyId, initial: true);

      setState(() {
        _selectedMajorId = sClass.majorId;
      });

      await _onMajorChanged(sClass.majorId, initial: true);

      setState(() {
        _selectedClassId = widget.student!.classId;
      });
    }
  }

  Future<void> _onFacultyChanged(String? facultyId, {bool initial = false}) async {
    if (facultyId == null) return;

    final service = ref.read(studentServiceProvider);
    final majors = await service.fetchMajors(facultyId);

    if (!mounted) return;

    setState(() {
      if (!initial) {
        _selectedFacultyId = facultyId;
        _selectedMajorId = null;
        _selectedClassId = null;
        _classes = [];
      }
      _majors = majors;
    });
  }

  Future<void> _onMajorChanged(String? majorId, {bool initial = false}) async {
    if (majorId == null) return;

    final service = ref.read(studentServiceProvider);
    final classes = await service.fetchClasses(majorId);

    if (!mounted) return;

    setState(() {
      if (!initial) {
        _selectedMajorId = majorId;
        _selectedClassId = null;
      }
      _classes = classes;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _hometownController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedFileBytes = bytes;
        _selectedFileName = image.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate() && _selectedClassId != null) {
      final newStudent = StudentModel(
        id: widget.student?.id,
        studentCode: _studentCodeController.text.trim(),
        fullName: _fullNameController.text.trim(),
        classId: _selectedClassId!,
        avatarUrl: widget.student?.avatarUrl,
        gpa: double.tryParse(_gpaController.text.trim()),
        hometown: _hometownController.text.trim(),
        dateOfBirth: _selectedDate,
        academicStatus: _selectedAcademicStatus,
      );

      if (isEditing) {
        ref.read(studentListProvider.notifier).updateStudent(
          newStudent, 
          newFileBytes: _selectedFileBytes,
          newFileName: _selectedFileName,
        );
      } else {
        ref.read(studentListProvider.notifier).addStudent(
          newStudent, 
          _selectedFileBytes,
          _selectedFileName,
        );
      }

      context.pop();
    } else if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ Khoa, Ngành và Lớp')),
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _selectedFileBytes != null
                          ? MemoryImage(_selectedFileBytes!)
                          : (widget.student?.avatarUrl != null
                              ? NetworkImage(widget.student!.avatarUrl!) as ImageProvider
                              : null),
                      child: (_selectedFileBytes == null && widget.student?.avatarUrl == null)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
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
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _studentCodeController,
                label: 'Mã số SV',
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mã sinh viên' : null,
              ),
              const SizedBox(height: 16),
              
              // Faculty Dropdown
              DropdownButtonFormField<String>(
                key: const ValueKey('faculty_dropdown'),
                value: _selectedFacultyId,
                decoration: const InputDecoration(labelText: 'Khoa', border: OutlineInputBorder()),
                items: _faculties.map((f) => DropdownMenuItem(value: f['id'].toString(), child: Text(f['faculty_name']))).toList(),
                onChanged: _onFacultyChanged,
                validator: (value) => value == null ? 'Vui lòng chọn Khoa' : null,
              ),
              const SizedBox(height: 16),

              // Major Dropdown
              DropdownButtonFormField<String>(
                key: const ValueKey('major_dropdown'),
                value: _selectedMajorId,
                decoration: const InputDecoration(labelText: 'Ngành', border: OutlineInputBorder()),
                items: _majors.map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text(m['major_name']))).toList(),
                onChanged: _onMajorChanged,
                validator: (value) => value == null ? 'Vui lòng chọn Ngành' : null,
              ),
              const SizedBox(height: 16),

              // Class Dropdown
              DropdownButtonFormField<String>(
                key: const ValueKey('class_dropdown'),
                value: _selectedClassId,
                decoration: const InputDecoration(labelText: 'Lớp', border: OutlineInputBorder()),
                items: _classes.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['class_name']))).toList(),
                onChanged: (val) => setState(() => _selectedClassId = val),
                validator: (value) => value == null ? 'Vui lòng chọn Lớp' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _hometownController,
                label: 'Quê quán',
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày sinh', suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                  child: Text(_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Chọn ngày sinh'),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _gpaController,
                label: 'Điểm GPA (0 - 4.0)',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập GPA';
                  final gpa = double.tryParse(value);
                  if (gpa == null || gpa < 0 || gpa > 4.0) return 'GPA phải từ 0 đến 4.0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedAcademicStatus,
                decoration: const InputDecoration(labelText: 'Tình trạng học tập', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Đang học', child: Text('Đang học')),
                  DropdownMenuItem(value: 'Bảo lưu', child: Text('Bảo lưu')),
                  DropdownMenuItem(value: 'Đình chỉ', child: Text('Đình chỉ')),
                  DropdownMenuItem(value: 'Đã tốt nghiệp', child: Text('Đã tốt nghiệp')),
                ],
                onChanged: (value) => setState(() => _selectedAcademicStatus = value),
              ),
              const SizedBox(height: 32),
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

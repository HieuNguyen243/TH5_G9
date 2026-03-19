import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_model.dart';
import '../../models/faculty_model.dart';
import '../../models/major_model.dart';
import '../../models/class_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/student_list_tile.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? filterParams;

  const DirectoryScreen({super.key, this.filterParams});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 1. Quản lý Trạng thái cấp bậc (Hierarchy State)
  FacultyModel? _selectedFaculty;
  MajorModel? _selectedMajor;
  ClassModel? _selectedClass;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- HELPER METHODS ĐỂ TRÍCH XUẤT DỮ LIỆU ---

  List<FacultyModel> _getUniqueFaculties(List<StudentModel> students) {
    final Map<String, FacultyModel> faculties = {};
    for (var s in students) {
      final faculty = s.studentClass?.major?.faculty;
      if (faculty != null) faculties[faculty.id] = faculty;
    }
    final list = faculties.values.toList();
    list.sort((a, b) => a.facultyName.compareTo(b.facultyName));
    return list;
  }

  List<MajorModel> _getMajorsForFaculty(List<StudentModel> students, String facultyId) {
    final Map<String, MajorModel> majors = {};
    for (var s in students) {
      final major = s.studentClass?.major;
      if (major != null && major.facultyId == facultyId) {
        majors[major.id] = major;
      }
    }
    final list = majors.values.toList();
    list.sort((a, b) => a.majorName.compareTo(b.majorName));
    return list;
  }

  List<ClassModel> _getClassesForMajor(List<StudentModel> students, String majorId) {
    final Map<String, ClassModel> classes = {};
    for (var s in students) {
      final sClass = s.studentClass;
      if (sClass != null && sClass.majorId == majorId) {
        classes[sClass.id] = sClass;
      }
    }
    final list = classes.values.toList();
    list.sort((a, b) => a.className.compareTo(b.className));
    return list;
  }

  List<StudentModel> _getStudentsForClass(List<StudentModel> students, String classId) {
    final list = students.where((s) => s.classId == classId).toList();
    list.sort((a, b) => a.fullName.compareTo(b.fullName));
    return list;
  }

  // --- LOGIC ĐIỀU HƯỚNG NGƯỢC ---
  void _goBack() {
    setState(() {
      if (_selectedClass != null) {
        _selectedClass = null;
      } else if (_selectedMajor != null) {
        _selectedMajor = null;
      } else if (_selectedFaculty != null) {
        _selectedFaculty = null;
      }
    });
  }

  // --- UI COMPONENTS ---

  Widget _buildBreadcrumbs() {
    if (_selectedFaculty == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: _goBack,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _breadcrumbItem("Gốc", () => setState(() {
                        _selectedFaculty = null;
                        _selectedMajor = null;
                        _selectedClass = null;
                      })),
                  _breadcrumbSeparator(),
                  _breadcrumbItem(_selectedFaculty!.facultyName, () => setState(() {
                        _selectedMajor = null;
                        _selectedClass = null;
                      })),
                  if (_selectedMajor != null) ...[
                    _breadcrumbSeparator(),
                    _breadcrumbItem(_selectedMajor!.majorName, () => setState(() {
                          _selectedClass = null;
                        })),
                  ],
                  if (_selectedClass != null) ...[
                    _breadcrumbSeparator(),
                    _breadcrumbItem(_selectedClass!.className, null),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumbItem(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: onTap != null ? Theme.of(context).primaryColor : Colors.grey[600],
          fontWeight: onTap == null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _breadcrumbSeparator() =>
      const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.chevron_right, size: 16, color: Colors.grey));

  Widget _buildFolderItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(Icons.folder, color: iconColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentListAsync = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư mục Sinh viên'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm nhanh tên hoặc mã sinh viên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Hierarchy View
          Expanded(
            child: studentListAsync.when(
              data: (allStudents) {
                final query = _searchController.text.toLowerCase();
                final dashboardFilter = widget.filterParams?['filter'];

                if (query.isNotEmpty || (dashboardFilter != null && dashboardFilter != 'all')) {
                  final filtered = allStudents.where((s) {
                    final matchesSearch = s.fullName.toLowerCase().contains(query) || s.studentCode.toLowerCase().contains(query);
                    if (dashboardFilter == 'excellent') return matchesSearch && (s.gpa ?? 0) >= 3.2;
                    if (dashboardFilter == 'warned') return matchesSearch && ((s.gpa ?? 0) < 1.5 || s.academicStatus == 'Đình chỉ');
                    return matchesSearch;
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => StudentListTile(
                      student: filtered[index],
                      onTap: () => context.go('/directory/student-detail', extra: filtered[index]),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildBreadcrumbs(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: _buildCurrentLevelItems(allStudents),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/directory/student-form'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildCurrentLevelItems(List<StudentModel> allStudents) {
    if (_selectedClass != null) {
      final students = _getStudentsForClass(allStudents, _selectedClass!.id);
      return students
          .map((s) => StudentListTile(
                student: s,
                onTap: () => context.go('/directory/student-detail', extra: s),
              ))
          .toList();
    }

    if (_selectedMajor != null) {
      final classes = _getClassesForMajor(allStudents, _selectedMajor!.id);
      return classes.map((c) {
        final count = allStudents.where((s) => s.classId == c.id).length;
        return _buildFolderItem(
          title: "Lớp: ${c.className}",
          subtitle: "$count sinh viên",
          iconColor: Colors.orangeAccent,
          onTap: () => setState(() => _selectedClass = c),
        );
      }).toList();
    }

    if (_selectedFaculty != null) {
      final majors = _getMajorsForFaculty(allStudents, _selectedFaculty!.id);
      return majors.map((m) {
        final classCount = _getClassesForMajor(allStudents, m.id).length;
        return _buildFolderItem(
          title: "Ngành: ${m.majorName}",
          subtitle: "$classCount lớp hành chính",
          iconColor: Colors.green,
          onTap: () => setState(() => _selectedMajor = m),
        );
      }).toList();
    }

    final faculties = _getUniqueFaculties(allStudents);
    return faculties.map((f) {
      final majorCount = _getMajorsForFaculty(allStudents, f.id).length;
      return _buildFolderItem(
        title: "Khoa: ${f.facultyName}",
        subtitle: "$majorCount ngành đào tạo",
        onTap: () => setState(() => _selectedFaculty = f),
      );
    }).toList();
  }
}

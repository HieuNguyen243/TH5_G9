import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/student_list_tile.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  // Filter states
  String? _selectedMajor;
  String _selectedGpaOption = 'all'; // 'all', 'gte3.2', 'lt3.2'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  /// Debounced search handler (500ms delay)
  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // Trigger rebuild with filtered data
      });
    });
  }

  /// Apply search and filter logic
  List<StudentModel> _applyFilters(List<StudentModel> allStudents) {
    return allStudents.where((student) {
      // Search filter - name and student code
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          student.fullName.toLowerCase().contains(searchQuery) ||
          student.studentCode.toLowerCase().contains(searchQuery);

      if (!matchesSearch) return false;

      // Major filter
      if (_selectedMajor != null && student.major?.majorName != _selectedMajor) {
        return false;
      }

      // GPA filter (placeholder - StudentModel doesn't have GPA field)
      // In a real scenario, you'd use student.gpa
      // For now, we'll skip GPA filtering since the model doesn't have it
      // Uncomment below when GPA field is added to StudentModel
      /*
      if (_selectedGpaOption == 'gte3.2' && (student.gpa ?? 0) < 3.2) {
        return false;
      }
      if (_selectedGpaOption == 'lt3.2' && (student.gpa ?? 0) >= 3.2) {
        return false;
      }
      */

      return true;
    }).toList();
  }

  /// Get unique majors from student list
  List<String> _getMajorsList(List<StudentModel> students) {
    final majorSet = <String>{};
    for (var student in students) {
      if (student.major?.majorName != null) {
        majorSet.add(student.major!.majorName);
      }
    }
    return majorSet.toList()..sort();
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final studentListAsync = ref.watch(studentListProvider);
            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bộ lọc',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Major Filter
                            Text(
                              'Ngành học',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            studentListAsync.when(
                              data: (students) {
                                final majors = _getMajorsList(students);
                                return Column(
                                  children: [
                                    // "All" option
                                    RadioListTile<String?>(
                                      title: const Text('Tất cả'),
                                      value: null,
                                      groupValue: _selectedMajor,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _selectedMajor = value;
                                        });
                                        setState(() {});
                                      },
                                    ),
                                    // Major options
                                    ...majors.map(
                                      (major) => RadioListTile<String?>(
                                        title: Text(major),
                                        value: major,
                                        groupValue: _selectedMajor,
                                        onChanged: (value) {
                                          setModalState(() {
                                            _selectedMajor = value;
                                          });
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading: () => const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, stackTrace) => Text('Error: $error'),
                            ),
                            const SizedBox(height: 16),

                            // GPA Filter
                            Text(
                              'Điểm GPA',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text('Tất cả'),
                                  value: 'all',
                                  groupValue: _selectedGpaOption,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setModalState(() {
                                        _selectedGpaOption = value;
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('≥ 3.2'),
                                  value: 'gte3.2',
                                  groupValue: _selectedGpaOption,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setModalState(() {
                                        _selectedGpaOption = value;
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('< 3.2'),
                                  value: 'lt3.2',
                                  groupValue: _selectedGpaOption,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setModalState(() {
                                        _selectedGpaOption = value;
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _selectedMajor = null;
                                        _selectedGpaOption = 'all';
                                      });
                                      setState(() {});
                                    },
                                    child: const Text('Reset'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Áp dụng'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentListAsync = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search TextField
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or code...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter Button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => _showFilterBottomSheet(context),
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Wrap(
              spacing: 8,
              children: [
                if (_selectedMajor != null)
                  Chip(
                    label: Text('Ngành: $_selectedMajor'),
                    onDeleted: () {
                      setState(() {
                        _selectedMajor = null;
                      });
                    },
                  ),
                if (_selectedGpaOption != 'all')
                  Chip(
                    label: Text('GPA: $_selectedGpaOption'),
                    onDeleted: () {
                      setState(() {
                        _selectedGpaOption = 'all';
                      });
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Student List
          Expanded(
            child: studentListAsync.when(
              data: (students) {
                final filteredStudents = _applyFilters(students);

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return Dismissible(
                      key: Key(student.id ?? student.studentCode),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // In a real app, call a Provider/Service method to delete
                        // E.g., ref.read(studentProvider.notifier).deleteStudent(student.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã xóa sinh viên ${student.fullName}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: StudentListTile(
                        student: student,
                        onTap: () {
                          context.go('/directory/student-detail', extra: student);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load students',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $error',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/directory/student-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

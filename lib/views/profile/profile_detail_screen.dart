import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import 'package:intl/intl.dart';

class ProfileDetailScreen extends ConsumerWidget {
  final StudentModel student;

  const ProfileDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Sinh viên'),
        actions: [
          if (student.id != 'me' && student.id != 'ADMIN_01') ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.go('/directory/student-form', extra: student);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, ref);
              },
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Hero(
              tag: 'avatar_${student.id}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                    ? NetworkImage(student.avatarUrl!)
                    : null,
                child: student.avatarUrl == null || student.avatarUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              student.fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.studentCode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'Mã số SV',
                      value: student.studentCode,
                    ),
                    const Divider(),
                    // Updated Hierarchy Display
                    _buildInfoRow(
                      context,
                      icon: Icons.business_outlined,
                      label: 'Khoa',
                      value: student.studentClass?.major?.faculty?.facultyName ?? 'Chưa xác định',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.school_outlined,
                      label: 'Ngành học',
                      value: student.studentClass?.major?.majorName ?? 'Chưa xác định',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.class_outlined,
                      label: 'Lớp',
                      value: student.studentClass?.className ?? 'Chưa xác định',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Quê quán',
                      value: student.hometown ?? 'Chưa cập nhật',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.cake_outlined,
                      label: 'Ngày sinh',
                      value: student.dateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(student.dateOfBirth!)
                        : 'Chưa cập nhật',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.info_outline,
                      label: 'Tình trạng học tập',
                      value: student.academicStatus ?? 'Đang học',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.grade_outlined,
                      label: 'Điểm trung bình (GPA)',
                      value: student.gpa?.toStringAsFixed(2) ?? 'Chưa cập nhật',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên ${student.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(studentListProvider.notifier).deleteStudent(student);
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa sinh viên thành công')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

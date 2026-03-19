import 'package:flutter/material.dart';
import '../../models/student_model.dart';

class ProfileDetailScreen extends StatelessWidget {
  final StudentModel student;

  const ProfileDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Sinh viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar
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
            
            // Full Name
            Text(
              student.fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Student Code
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

            // Detailed Information Card
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
                    _buildInfoRow(
                      context,
                      icon: Icons.school_outlined,
                      label: 'Ngành học',
                      value: student.major?.majorName ?? student.majorId,
                      // For now, if the major is null, just show the ID
                    ),
                    const Divider(),
                    // Placeholder for future fields
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Quê quán',
                      value: 'Chưa cập nhật', // Can map to real field later
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      icon: Icons.grade_outlined,
                      label: 'Điểm trung bình',
                      value: 'Chưa cập nhật', // Can map to real field later
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

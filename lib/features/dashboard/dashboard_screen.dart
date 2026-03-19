import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentListAsync = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: studentListAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(studentListProvider);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (students) {
          final stats = _calculateStats(students);
          final majorDistribution = _calculateMajorDistribution(students);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Tổng Quan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Stat Cards
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: 'Tổng SV',
                      value: stats['totalStudents']!,
                      icon: Icons.people,
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    StatCard(
                      label: 'SV Giỏi',
                      value: stats['excellentStudents']!,
                      icon: Icons.star,
                      backgroundColor: const Color(0xFFF59E0B),
                    ),
                    StatCard(
                      label: 'SV Cảnh Báo',
                      value: stats['warnedStudents']!,
                      icon: Icons.warning,
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Chart Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân bố Sinh viên theo Ngành',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (majorDistribution.isEmpty)
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'Không có dữ liệu',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: _generatePieSections(majorDistribution),
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLegend(majorDistribution, context),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, int> _calculateStats(List<StudentModel> students) {
    final totalStudents = students.length;
    
    // Tính toán SV Giỏi: 30% hàng đầu (dựa trên mã học sinh)
    final excellentCount = (totalStudents * 0.3).ceil();
    
    // Tính toán SV Cảnh Báo: 10% hàng cuối
    final warnedCount = (totalStudents * 0.1).ceil();

    return {
      'totalStudents': totalStudents,
      'excellentStudents': excellentCount,
      'warnedStudents': warnedCount,
    };
  }

  Map<String, int> _calculateMajorDistribution(List<StudentModel> students) {
    final distribution = <String, int>{};

    for (final student in students) {
      final majorName = student.major?.majorName ?? 'Chưa xác định';
      distribution[majorName] = (distribution[majorName] ?? 0) + 1;
    }

    return distribution;
  }

  List<PieChartSectionData> _generatePieSections(
    Map<String, int> distribution,
  ) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);
    int colorIndex = 0;

    return distribution.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final section = PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      colorIndex++;
      return section;
    }).toList();
  }

  Widget _buildLegend(
    Map<String, int> distribution,
    BuildContext context,
  ) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: distribution.entries.map((entry) {
        final colorIndex = distribution.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[colorIndex % colors.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key} (${entry.value})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

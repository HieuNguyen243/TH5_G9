import 'package:go_router/go_router.dart';
import '../core/widgets/main_layout.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../views/directory/directory_screen.dart';
import '../views/profile/profile_detail_screen.dart';
import '../views/profile/student_form_screen.dart';
import '../models/student_model.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String directory = '/directory';
  static const String profile = '/profile';
  static const String studentDetail = 'student-detail';
  static const String studentForm = 'student-form';

  static final router = GoRouter(
    initialLocation: dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: directory,
            builder: (context, state) {
              final extra = state.extra;
              final filterParams = extra is Map<String, dynamic> ? extra : null;
              return DirectoryScreen(filterParams: filterParams);
            },
            routes: [
              GoRoute(
                path: studentDetail,
                builder: (context, state) {
                  final student = state.extra as StudentModel;
                  return ProfileDetailScreen(student: student);
                },
              ),
              GoRoute(
                path: studentForm,
                builder: (context, state) {
                  final student = state.extra as StudentModel?;
                  return StudentFormScreen(student: student);
                },
              ),
            ],
          ),
          GoRoute(
            path: profile,
            builder: (context, state) {
              return ProfileDetailScreen(
                student: StudentModel(
                  id: 'me',
                  studentCode: 'ADMIN_01',
                  fullName: 'Administrator',
                  classId: 'ADMIN_CLASS', // Updated from majorId: 'IT'
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

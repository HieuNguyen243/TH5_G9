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
            builder: (context, state) => const DirectoryScreen(),
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
              // Placeholder for the main profile tab if needed. Using dummy data for now
              return ProfileDetailScreen(
                student: StudentModel(
                  id: 'me',
                  studentCode: 'TH5_243',
                  fullName: 'Developer',
                  majorId: 'IT',
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

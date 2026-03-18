import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/main_layout.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../views/directory/directory_screen.dart';
import '../features/profile/profile_detail_screen.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String directory = '/directory';
  static const String profile = '/profile';

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
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileDetailScreen(),
          ),
        ],
      ),
    ],
  );
}
